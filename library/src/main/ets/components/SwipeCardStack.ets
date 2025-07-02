/**
 * SwipeCardStack 卡片堆叠滑动容器组件
 * 
 * 提供Tinder风格的卡片滑动交互，支持自定义内容Builder
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import type { 
  CardData, 
  SwipeCardStackConfig, 
  SwipeCardStackConfigUpdate,
  SwipeCardStackCallbacks,
  SwipeCardStackController,
  SwipeEvent,
  Position,
  AnimationConfig,
  ContainerSize
} from '../types/SwipeCardTypes';
import { SwipeDirection, CardState } from '../types/SwipeCardTypes';
import { DEFAULT_SWIPE_CARD_STACK_CONFIG, PERFORMANCE_CONSTANTS } from '../constants/DefaultConfigs';
import { AnimationUtils } from '../utils/AnimationUtils';
import { GestureUtils } from '../utils/GestureUtils';
import type { GestureData, VelocityData } from '../utils/GestureUtils';
import { SwipeCardStackControllerImpl, SwipeCardStackRefImpl } from './SwipeCardStackControllerImpl';
import type { SwipeCardStackRef } from './SwipeCardStackControllerImpl';
import { SwipeCardStackAdapter } from './SwipeCardStackAdapter';

/**
 * 卡片状态数据
 */
@Observed
class CardStateData {
  public translateX: number = 0;
  public translateY: number = 0;
  public rotation: number = 0;
  public scale: number = 1;
  public opacity: number = 1;
  public zIndex: number = 0;
  public state: CardState = CardState.IDLE;
}

/**
 * SwipeCardStack组件
 * 符合arktsV2.mdc规范：struct不能实现接口，使用适配器模式
 */
@Component
export struct SwipeCardStack {
  /** 卡片数据源 */
  @Prop cardDataList: CardData[] = [];
  /** 组件配置 */
  @Prop config: SwipeCardStackConfig = DEFAULT_SWIPE_CARD_STACK_CONFIG;
  /** 事件回调 */
  callbacks: SwipeCardStackCallbacks = {};
  /** 控制器回调 */
  controller?: (controller: SwipeCardStackController) => void;
  /** 内部卡片数据 */
  @State private internalCardList: CardData[] = [];
  /** 卡片状态映射 */
  @State private cardStates: Map<string, CardStateData> = new Map();
  /** 当前拖拽的卡片 */
  @State private draggingCard: CardData | null = null;
  /** 手势数据 */
  private gestureData: GestureData | null = null;
  /** 容器尺寸 */
  @State private containerSize: ContainerSize = { width: 0, height: 0 };
  /** 组件控制器 */
  private readonly internalController: SwipeCardStackController = this.createController();
  /** 卡片内容构建器 */
  @BuilderParam cardContentBuilder: (card: CardData, index: number) => void = this.defaultCardBuilder;

  /**
   * 组件即将出现时的生命周期
   */
  aboutToAppear(): void {
    // ✅ 使用循环替代扩展运算符 (符合arkts-no-spread规范)
    this.internalCardList = [];
    for (let i = 0; i < this.cardDataList.length; i++) {
      this.internalCardList.push(this.cardDataList[i]);
    }
    this.initializeCardStates();
    this.updateStackLayout();
    
    // 调用controller回调
    if (this.controller) {
      this.controller(this.internalController);
    }
  }

  /**
   * 组件即将消失时的生命周期
   */
  aboutToDisappear(): void {
    this.cleanup();
  }

  /**
   * 构建组件UI
   */
  build(): void {
    Stack() {
      ForEach(
        this.internalGetVisibleCards(),
        (card: CardData) => {
          this.buildCard(card);
        },
        (card: CardData): string => card.id
      )
    }
    .width('100%')
    .height('100%')
    .onAreaChange((oldValue: Area, newValue: Area): void => {
      this.onContainerSizeChange(newValue);
    })
  }

  /**
   * 构建单个卡片
   */
  @Builder
  private buildCard(card: CardData): void {
    if (this.cardStates.has(card.id)) {
      Stack() {
        this.cardContentBuilder(card, card.index)
      }
      .width('100%')
      .height('100%')
      .translate({ 
        x: this.cardStates.get(card.id)?.translateX ?? 0, 
        y: this.cardStates.get(card.id)?.translateY ?? 0
      })
      .rotate({ 
        angle: this.cardStates.get(card.id)?.rotation ?? 0,
        centerX: '50%',
        centerY: '50%'
      })
      .scale({ 
        x: this.cardStates.get(card.id)?.scale ?? 1, 
        y: this.cardStates.get(card.id)?.scale ?? 1
      })
      .opacity(this.cardStates.get(card.id)?.opacity ?? 1)
      .zIndex(this.cardStates.get(card.id)?.zIndex ?? 0)
      .gesture(
        PanGesture()
          .onActionStart((event: GestureEvent): void => {
            this.handleDragStart(card, event);
          })
          .onActionUpdate((event: GestureEvent): void => {
            this.handleDragUpdate(card, event);
          })
          .onActionEnd((event: GestureEvent): void => {
            this.handleDragEnd(card, event);
          })
      )
    }
  }

  /**
   * 默认卡片构建器
   */
  @Builder
  private defaultCardBuilder(card: CardData, index: number): void {
    Text(`Card ${index}`)
      .fontSize(24)
      .fontColor(Color.Black)
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .border({ width: 1, color: Color.Gray })
  }

  /**
   * 开始拖拽处理
   */
  private handleDragStart(card: CardData, event: GestureEvent): void {
    if (card !== this.internalGetTopCard()) {
      return;
    }

    this.draggingCard = card;
    const cardState: CardStateData | undefined = this.cardStates.get(card.id);
    if (cardState) {
      cardState.state = CardState.DRAGGING;
    }

    const startPos: Position = { x: event.fingerList[0].localX, y: event.fingerList[0].localY };
    const currentPos: Position = { x: event.fingerList[0].localX, y: event.fingerList[0].localY };
    this.gestureData = {
      startPosition: startPos,
      currentPosition: currentPos,
      startTime: Date.now(),
      currentTime: Date.now()
    };

    this.triggerCallback('onDragStart', card, SwipeDirection.LEFT, 0, 0);
  }

  /**
   * 拖拽更新处理
   */
  private handleDragUpdate(card: CardData, event: GestureEvent): void {
    if (card !== this.draggingCard || !this.gestureData) {
      return;
    }

    const currentPosition: Position = { 
      x: event.fingerList[0].localX, 
      y: event.fingerList[0].localY 
    };

    this.gestureData = {
      startPosition: this.gestureData.startPosition,
      currentPosition: currentPosition,
      startTime: this.gestureData.startTime,
      currentTime: Date.now()
    };

    this.updateCardPosition(card, currentPosition);
    
    const progress: number = this.calculateDragProgress();
    const direction: SwipeDirection = GestureUtils.getSwipeDirection(
      this.gestureData.startPosition, 
      currentPosition
    );

    this.triggerCallback('onDragUpdate', card, direction, progress, 0);
  }

  /**
   * 拖拽结束处理
   */
  private handleDragEnd(card: CardData, event: GestureEvent): void {
    if (card !== this.draggingCard || !this.gestureData) {
      return;
    }

    const velocity: VelocityData = GestureUtils.calculateVelocity(this.gestureData);
    const shouldSwipe: boolean = GestureUtils.shouldTriggerSwipe(this.gestureData, this.config.swipe);
    const direction: SwipeDirection = GestureUtils.getSwipeDirection(
      this.gestureData.startPosition, 
      this.gestureData.currentPosition
    );

    if (shouldSwipe) {
      this.performSwipe(card, direction, true);
    } else {
      this.resetCardPosition(card, true);
    }

    this.triggerCallback('onDragEnd', card, direction, 0, velocity.velocity);
    this.draggingCard = null;
    this.gestureData = null;
  }

  /**
   * 更新卡片位置
   */
  private updateCardPosition(card: CardData, currentPosition: Position): void {
    if (!this.gestureData) {
      return;
    }

    const cardState: CardStateData | undefined = this.cardStates.get(card.id);
    if (!cardState) {
      return;
    }

    const delta: Position = GestureUtils.calculateDelta(this.gestureData.startPosition, currentPosition);
    
    // 更新位移
    cardState.translateX = delta.x;
    cardState.translateY = delta.y;

    // 计算并更新旋转角度
    cardState.rotation = GestureUtils.calculateRotation(
      this.gestureData.startPosition,
      currentPosition,
      this.config.swipe.maxRotation,
      this.containerSize.width
    );

    // 计算并更新透明度
    const progress: number = this.calculateDragProgress();
    cardState.opacity = GestureUtils.calculateOpacity(progress);

    // 更新下层卡片
    this.updateBackgroundCards(progress);
  }

  /**
   * 执行滑动动画
   */
  private async performSwipe(card: CardData, direction: SwipeDirection, animated: boolean): Promise<void> {
    const cardState: CardStateData | undefined = this.cardStates.get(card.id);
    if (!cardState) {
      return;
    }

    cardState.state = CardState.ANIMATING;

    const exitPosition: Position = this.calculateExitPosition(direction);
    const animationConfig: AnimationConfig = this.config.animation;

    if (animated) {
      const animateParam: AnimateParam = AnimationUtils.createAnimateParam(animationConfig);
      
      animateTo(animateParam, (): void => {
        cardState.translateX = exitPosition.x;
        cardState.translateY = exitPosition.y;
        cardState.opacity = 0;
      });

      await this.delay(animationConfig.duration);
    } else {
      cardState.translateX = exitPosition.x;
      cardState.translateY = exitPosition.y;
      cardState.opacity = 0;
    }

    // 移除卡片并更新堆叠
    this.removeCard(card);
    this.triggerCallback('onCardSwiped', card, direction, 1, 0);
    
    if (this.internalCardList.length === 0) {
      this.callbacks.onStackEmpty?.();
    } else {
      this.updateStackLayout();
    }
  }

  /**
   * 重置卡片位置
   */
  private async resetCardPosition(card: CardData, animated: boolean): Promise<void> {
    const cardState: CardStateData | undefined = this.cardStates.get(card.id);
    if (!cardState) {
      return;
    }

    cardState.state = CardState.ANIMATING;

    if (animated) {
      const animateParam: AnimateParam = AnimationUtils.createAnimateParam(this.config.animation);
      
      animateTo(animateParam, (): void => {
        cardState.translateX = 0;
        cardState.translateY = 0;
        cardState.rotation = 0;
        cardState.opacity = 1;
      });

      await this.delay(this.config.animation.duration);
    } else {
      cardState.translateX = 0;
      cardState.translateY = 0;
      cardState.rotation = 0;
      cardState.opacity = 1;
    }

    cardState.state = CardState.IDLE;
    this.triggerCallback('onCardBounced', card, SwipeDirection.LEFT, 0, 0);
    this.updateStackLayout();
  }

  /**
   * 初始化卡片状态
   */
  private initializeCardStates(): void {
    this.cardStates.clear();
    for (let i = 0; i < this.internalCardList.length; i++) {
      const card: CardData = this.internalCardList[i];
      this.cardStates.set(card.id, new CardStateData());
    }
  }

  /**
   * 更新堆叠布局
   */
  private updateStackLayout(): void {
    const visibleCards: CardData[] = this.internalGetVisibleCards();
    
    for (let i = 0; i < visibleCards.length; i++) {
      const card: CardData = visibleCards[i];
      const cardState: CardStateData | undefined = this.cardStates.get(card.id);
      
      if (cardState && cardState.state === CardState.IDLE) {
        // 设置z-index
        cardState.zIndex = visibleCards.length - i;
        
        // 设置偏移和缩放
        const offset: number = i * this.config.stack.cardSpacing;
        cardState.translateY = offset;
        cardState.scale = 1 - (i * this.config.stack.scaleStep);
        cardState.opacity = 1 - (i * this.config.stack.opacityStep);
      }
    }

    this.callbacks.onStackUpdate?.(visibleCards);
  }

  /**
   * 更新背景卡片
   */
  private updateBackgroundCards(progress: number): void {
    const visibleCards: CardData[] = this.internalGetVisibleCards();
    
    for (let i = 1; i < Math.min(visibleCards.length, 2); i++) {
      const card: CardData = visibleCards[i];
      const cardState: CardStateData | undefined = this.cardStates.get(card.id);
      
      if (cardState) {
        // 随着顶部卡片滑动，下层卡片逐渐前移
        const baseOffset: number = i * this.config.stack.cardSpacing;
        const animatedOffset: number = baseOffset * (1 - progress * 0.5);
        cardState.translateY = animatedOffset;
        
        const baseScale: number = 1 - (i * this.config.stack.scaleStep);
        const animatedScale: number = baseScale + (progress * this.config.stack.scaleStep * 0.5);
        cardState.scale = Math.min(1, animatedScale);
      }
    }
  }

  /**
   * 获取可见卡片列表 - 内部实现
   */
  private internalGetVisibleCards(): CardData[] {
    const maxVisible: number = Math.min(
      this.config.stack.visibleCount, 
      PERFORMANCE_CONSTANTS.MAX_VISIBLE_COUNT,
      this.internalCardList.length
    );
    return this.internalCardList.slice(0, maxVisible);
  }

  /**
   * 获取顶部卡片 - 内部实现
   */
  private internalGetTopCard(): CardData | null {
    return this.internalCardList.length > 0 ? this.internalCardList[0] : null;
  }



  /**
   * 移除卡片
   */
  private removeCard(card: CardData): void {
    const index: number = this.internalCardList.findIndex((c: CardData): boolean => c.id === card.id);
    if (index !== -1) {
      this.internalCardList.splice(index, 1);
      this.cardStates.delete(card.id);
      
      if (this.config.enableLoop && this.internalCardList.length > 0) {
        // 循环模式：将卡片添加到末尾
        const newCard: CardData = {
          id: `${card.id}_${Date.now()}`,
          index: this.internalCardList.length,
          visible: true,
          data: card.data
        };
        this.internalCardList.push(newCard);
        this.cardStates.set(newCard.id, new CardStateData());
      }
    }
  }

  /**
   * 计算拖拽进度
   */
  private calculateDragProgress(): number {
    if (!this.gestureData) {
      return 0;
    }
    
    return GestureUtils.calculateSwipeProgress(
      this.gestureData.startPosition,
      this.gestureData.currentPosition,
      this.config.swipe.threshold
    );
  }

  /**
   * 计算退出位置
   */
  private calculateExitPosition(direction: SwipeDirection): Position {
    const multiplier: number = 1.5;
    
    switch (direction) {
      case SwipeDirection.LEFT: {
        const position: Position = { x: -this.containerSize.width * multiplier, y: 0 };
        return position;
      }
      case SwipeDirection.RIGHT: {
        const position: Position = { x: this.containerSize.width * multiplier, y: 0 };
        return position;
      }
      case SwipeDirection.UP: {
        const position: Position = { x: 0, y: -this.containerSize.height * multiplier };
        return position;
      }
      case SwipeDirection.DOWN: {
        const position: Position = { x: 0, y: this.containerSize.height * multiplier };
        return position;
      }
      default: {
        const position: Position = { x: 0, y: 0 };
        return position;
      }
    }
  }

  /**
   * 触发事件回调
   */
  private triggerCallback(
    callbackName: string, 
    card: CardData, 
    direction: SwipeDirection, 
    progress: number, 
    velocity: number
  ): void {
    const defaultPosition: Position = { x: 0, y: 0 };
    const position: Position = this.gestureData?.currentPosition ?? defaultPosition;
    const event: SwipeEvent = {
      card,
      direction,
      progress,
      velocity,
      position
    };

    switch (callbackName) {
      case 'onDragStart':
        this.callbacks.onDragStart?.(event);
        break;
      case 'onDragUpdate':
        this.callbacks.onDragUpdate?.(event);
        break;
      case 'onDragEnd':
        this.callbacks.onDragEnd?.(event);
        break;
      case 'onCardSwiped':
        this.callbacks.onCardSwiped?.(event);
        break;
      case 'onCardBounced':
        this.callbacks.onCardBounced?.(event);
        break;
    }
  }

  /**
   * 容器尺寸变化处理
   */
  private onContainerSizeChange(newValue: Area): void {
    if (newValue.width && newValue.height) {
      const newSize: ContainerSize = {
        width: Number(newValue.width),
        height: Number(newValue.height)
      };
      this.containerSize = newSize;
    }
  }

  /**
   * 延迟函数
   */
  private async delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void): void => {
      setTimeout(resolve, ms);
    });
  }

  /**
   * 创建控制器
   * 符合arktsV2.mdc规范：struct不能实现接口，使用适配器模式
   */
  private createController(): SwipeCardStackController {
    // 创建适配器，连接struct和接口
    const adapter = new SwipeCardStackAdapter(
      (): CardData | null => this.internalGetTopCard(),
      (): CardData[] => this.internalGetVisibleCards(),
      async (card: CardData, direction: SwipeDirection, animated: boolean): Promise<void> => {
        await this.performSwipe(card, direction, animated);
      },
      async (card: CardData, animated: boolean): Promise<void> => {
        await this.resetCardPosition(card, animated);
      },
      (config: SwipeCardStackConfigUpdate): void => {
        this.internalUpdateConfig(config);
      },
      (cards: CardData[]): void => {
        this.internalReload(cards);
      }
    );
    
    // 创建组件引用实现类实例
    const swipeStackRef: SwipeCardStackRef = new SwipeCardStackRefImpl(adapter);
    
    // 创建控制器实现类实例
    return new SwipeCardStackControllerImpl(swipeStackRef);
  }

  /**
   * 内部更新配置方法
   */
  private internalUpdateConfig(newConfig: SwipeCardStackConfigUpdate): void {
    const newConfiguration: SwipeCardStackConfig = {
      stack: newConfig.stack ?? this.config.stack,
      swipe: newConfig.swipe ?? this.config.swipe,
      animation: newConfig.animation ?? this.config.animation,
      enableLoop: newConfig.enableLoop ?? this.config.enableLoop,
      debug: newConfig.debug ?? this.config.debug
    };
    this.config = newConfiguration;
    this.updateStackLayout();
  }

  /**
   * 内部重新加载方法
   */
  private internalReload(cards: CardData[]): void {
    this.internalCardList.splice(0);
    for (let i = 0; i < cards.length; i++) {
      this.internalCardList.push(cards[i]);
    }
    this.initializeCardStates();
    this.updateStackLayout();
  }

  /**
   * 清理资源
   */
  private cleanup(): void {
    this.cardStates.clear();
    this.draggingCard = null;
    this.gestureData = null;
  }
} 