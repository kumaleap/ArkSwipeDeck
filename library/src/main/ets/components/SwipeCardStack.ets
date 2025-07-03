/**
 * 滑动卡片堆叠组件
 *
 * 实现类似Tinder的滑动卡片效果
 *
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import hilog from '@ohos.hilog';
import type {
  CardData,
  SwipeConfig,
  GestureState,
  AnimationParams,
  CardInfo,
  OnCardSwipedCallback,
  OnCardClickedCallback,
  OnStackNearEmptyCallback,
  OnStackEmptyCallback,
  SwipeEventHandler
} from '../types/SwipeCardTypes';
import { SwipeDirection, CardState } from '../types/SwipeCardTypes';
import { mergeSwipeConfig, LayoutConstants } from '../constants/DefaultConfigs';
import { AnimationUtils } from '../utils/AnimationUtils';
import { GestureUtils } from '../utils/GestureUtils';

// 日志标签
const TAG: string = 'ArkSwipeDeck';

/**
 * 滑动卡片堆叠组件
 */
@Component
export struct SwipeCardStack {
  /** 卡片数据列表 */
  @Prop private cardDataList: CardData[] = [];
  /** 滑动配置 */
  @Prop private swipeConfig: SwipeConfig = {};
  /** 事件监听器 */
  @Prop private eventHandler: SwipeEventHandler = {};
  /** 卡片内容构建器 */
  @BuilderParam private cardBuilder?: (data: CardData, index: number) => void;
  /** 当前卡片索引 */
  @State private currentIndex: number = 0;
  /** 卡片状态 */
  @State private cardState: CardState = CardState.IDLE;
  /** 顶层卡片动画参数 */
  @State private topCardAnimation: AnimationParams = {
    translateX: 0,
    translateY: 0,
    rotation: 0,
    scale: 1,
    opacity: 1
  };
  /** 背景卡片跟随动画参数 */
  @State private backgroundCardAnimation: AnimationParams = {
    translateX: 0,
    translateY: 0,
    rotation: 0,
    scale: 1,
    opacity: 1
  };
  /** 当前拖拽进度 (0-1) */
  @State private dragProgress: number = 0;
  /** 组件宽度 */
  @State private componentWidth: number = 0;
  /** 组件高度 */
  @State private componentHeight: number = 0;
  /** 合并后的配置 */
  @State private finalConfig: Required<SwipeConfig> = mergeSwipeConfig({});
  /** 当前手势状态 */
  private currentGestureState: GestureState | null = null;

  aboutToAppear(): void {
    // 初始化配置
    this.finalConfig = mergeSwipeConfig(this.swipeConfig);
    hilog.debug(0x0000, TAG, 'SwipeCardStack初始化配置: %{public}s', JSON.stringify(this.finalConfig));
    hilog.debug(0x0000, TAG, 'cardDataList长度: %{public}d', this.cardDataList.length);
    for (let i = 0; i < this.cardDataList.length; i++) {
      hilog.debug(0x0000, TAG, '卡片 %{public}d: id=%{public}s', i, this.cardDataList[i].id);
    }
  }

  /**
   * 添加新的卡片数据
   * @param newCards - 新的卡片数据数组
   */
  public addCards(newCards: CardData[]): void {
    if (newCards.length === 0) {
      hilog.debug(0x0000, TAG, 'addCards: 没有新卡片需要添加');
      return;
    }
    
    const oldLength: number = this.cardDataList.length;
    
    // 添加新卡片到数组末尾
    for (let i = 0; i < newCards.length; i++) {
      this.cardDataList.push(newCards[i]);
    }
    
    hilog.debug(0x0000, TAG, 'addCards: 添加了%{public}d张新卡片，总数从%{public}d变为%{public}d', 
      newCards.length, oldLength, this.cardDataList.length);
    
    // 输出新添加的卡片信息
    for (let i = 0; i < newCards.length; i++) {
      hilog.debug(0x0000, TAG, '新卡片 %{public}d: id=%{public}s', oldLength + i, newCards[i].id);
    }
  }

  /**
   * 获取当前卡片索引
   */
  public getCurrentIndex(): number {
    return this.currentIndex;
  }

  build(): void {
    Stack() {
      if (this.componentWidth > 0 && this.componentHeight > 0) {
        ForEach(
          this.getVisibleCards(),
          (cardInfo: CardInfo) => {
            this.buildCard(cardInfo.data, cardInfo.index, cardInfo.stackIndex);
          },
          (cardInfo: CardInfo): string => cardInfo.data.id
        )
      } else {
        // 占位符，等待组件尺寸初始化
        Text('加载中...')
          .fontSize(16)
          .fontColor('#999999')
      }
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent) // 让手势事件穿透到子组件
    .onAreaChange((oldValue: Area, newValue: Area): void => {
      const newWidth: number = Number(newValue.width);
      const newHeight: number = Number(newValue.height);
      if (newWidth > 0 && newHeight > 0) {
        this.componentWidth = newWidth;
        this.componentHeight = newHeight;
        hilog.debug(0x0000, TAG, '组件尺寸更新: %{public}d x %{public}d', this.componentWidth, this.componentHeight);
      }
    })
  }

  /**
   * 构建单个卡片
   */
  @Builder
  private buildCard(data: CardData, dataIndex: number, stackIndex: number): void {
    Stack() {
      if (this.cardBuilder) {
        this.cardBuilder(data, dataIndex);
      } else {
        this.buildDefaultCard(data);
      }
    }
    .width(this.componentWidth * LayoutConstants.DEFAULT_CARD_WIDTH_RATIO)
    .height(this.componentHeight * LayoutConstants.DEFAULT_CARD_HEIGHT_RATIO)
    .borderRadius(LayoutConstants.CARD_BORDER_RADIUS)
    .shadow({
      radius: LayoutConstants.CARD_SHADOW_BLUR,
      color: Color.Black,
      offsetX: LayoutConstants.CARD_SHADOW_OFFSET,
      offsetY: LayoutConstants.CARD_SHADOW_OFFSET
    })
    .translate(this.getCardTranslate(stackIndex, dataIndex))
    .scale(this.getCardScale(stackIndex, dataIndex))
    .rotate(this.getCardRotation(stackIndex, dataIndex))
    .opacity(this.getCardOpacity(stackIndex, dataIndex))
    .zIndex(this.getCardZIndex(dataIndex))
    .gesture(
      // 给所有卡片添加手势，但在事件中判断是否响应
      PanGesture({ fingers: 1, direction: PanDirection.All, distance: 1 })
        .onActionStart((event: GestureEvent): void => {
          hilog.debug(0x0000, TAG, '手势触发: cardId=%{public}s, dataIndex=%{public}d, stackIndex=%{public}d, currentIndex=%{public}d', 
            data.id, dataIndex, stackIndex, this.currentIndex);
          
          // 只有当前索引对应的卡片才响应手势
          if (dataIndex !== this.currentIndex) {
            hilog.debug(0x0000, TAG, '非当前卡片，忽略手势: dataIndex=%{public}d, currentIndex=%{public}d', dataIndex, this.currentIndex);
            return;
          }
          
          hilog.debug(0x0000, TAG, '当前卡片拖拽开始: cardId=%{public}s', data.id);
          this.cardState = CardState.DRAGGING;
          // 重置拖拽进度
          this.dragProgress = 0;
        })
        .onActionUpdate((event: GestureEvent): void => {
          // 只有当前索引对应的卡片才响应手势
          if (dataIndex !== this.currentIndex) {
            return;
          }
          
          // 使用PanGesture的offsetX和offsetY获取相对位移
          const deltaX: number = event.offsetX;
          const deltaY: number = event.offsetY;
          hilog.debug(0x0000, TAG, '拖拽更新: deltaX=%{public}d, deltaY=%{public}d', deltaX, deltaY);
          
          // 计算拖拽进度 (基于距离和阈值)
          const distance: number = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
          this.dragProgress = Math.min(distance / this.finalConfig.swipeThreshold, 1.0);
          
          // 更新顶层卡片动画
          const cardWidth: number = this.componentWidth * LayoutConstants.DEFAULT_CARD_WIDTH_RATIO;
          this.topCardAnimation = {
            translateX: deltaX,
            translateY: deltaY,
            rotation: deltaX / cardWidth * this.finalConfig.rotationAngle,
            scale: 1,
            opacity: 1
          };
          
          // 更新背景卡片跟随动画
          this.updateBackgroundCardAnimation();
        })
        .onActionEnd((event: GestureEvent): void => {
          hilog.debug(0x0000, TAG, '手势结束: cardId=%{public}s, dataIndex=%{public}d, currentIndex=%{public}d', data.id, dataIndex, this.currentIndex);
          
          // 只有当前索引对应的卡片才响应手势
          if (dataIndex !== this.currentIndex) {
            hilog.debug(0x0000, TAG, '非当前卡片，忽略手势结束: dataIndex=%{public}d', dataIndex);
            return;
          }
          
          const deltaX: number = event.offsetX;
          const deltaY: number = event.offsetY;
          hilog.debug(0x0000, TAG, '当前卡片拖拽结束: cardId=%{public}s, deltaX=%{public}d, deltaY=%{public}d', data.id, deltaX, deltaY);
          
          // 判断是否达到滑动阈值
          const distance: number = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
          hilog.debug(0x0000, TAG, '拖拽距离: %{public}d, 阈值: %{public}d', distance, this.finalConfig.swipeThreshold);
          
          if (distance >= this.finalConfig.swipeThreshold) {
            // 达到阈值，执行滑出动画
            hilog.debug(0x0000, TAG, '触发滑出动画');
            this.performSwipeOut(deltaX, deltaY, data, dataIndex);
          } else {
            // 未达到阈值，弹回
            hilog.debug(0x0000, TAG, '距离不足，执行弹回');
            this.topCardAnimation = {
              translateX: 0,
              translateY: 0,
              rotation: 0,
              scale: 1,
              opacity: 1
            };
            // 重置背景卡片动画和拖拽进度
            this.dragProgress = 0;
            this.updateBackgroundCardAnimation();
            this.cardState = CardState.IDLE;
          }
        })
    )
  }

  /**
   * 构建默认卡片内容
   */
  @Builder
  private buildDefaultCard(data: CardData): void {
    Column() {
      Text(data.id)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.Blue)
  }

  /**
   * 获取可见卡片列表
   */
  private getVisibleCards(): CardInfo[] {
    const visibleCards: CardInfo[] = [];
    const maxVisible: number = Math.min(this.finalConfig.maxVisibleCards, this.cardDataList.length);

    hilog.debug(0x0000, TAG, 'getVisibleCards: maxVisible=%{public}d, cardDataList.length=%{public}d, currentIndex=%{public}d', 
      maxVisible, this.cardDataList.length, this.currentIndex);

    for (let i = 0; i < maxVisible; i++) {
      const dataIndex: number = this.currentIndex + i;
      if (dataIndex < this.cardDataList.length) {
        const cardInfo: CardInfo = {
          data: this.cardDataList[dataIndex],
          index: dataIndex,
          stackIndex: i
        };
        visibleCards.push(cardInfo);
        hilog.debug(0x0000, TAG, '添加可见卡片: id=%{public}s, dataIndex=%{public}d, stackIndex=%{public}d', 
          cardInfo.data.id, cardInfo.index, cardInfo.stackIndex);
      }
    }

    hilog.debug(0x0000, TAG, 'getVisibleCards返回: %{public}d张卡片', visibleCards.length);
    return visibleCards;
  }

  /**
   * 更新背景卡片跟随动画
   */
  private updateBackgroundCardAnimation(): void {
    // 根据拖拽进度计算背景卡片的动画参数
    // progress为0时，背景卡片在原位；progress为1时，背景卡片接近顶层位置
    const progress: number = this.dragProgress;
    
    // 获取第二张卡片的原始位置（stackIndex=1）
    const originalStackAnimation: AnimationParams = AnimationUtils.calculateStackAnimation(
      1,
      this.finalConfig.scaleRatio,
      this.finalConfig.cardSpacing
    );
    
    // 目标是顶层卡片的位置和大小
    const targetTranslateX: number = 0;
    const targetTranslateY: number = 0;
    const targetScale: number = 1;
    
    // 插值计算当前位置
    this.backgroundCardAnimation = {
      translateX: originalStackAnimation.translateX + (targetTranslateX - originalStackAnimation.translateX) * progress,
      translateY: originalStackAnimation.translateY + (targetTranslateY - originalStackAnimation.translateY) * progress,
      rotation: 0,
      scale: originalStackAnimation.scale + (targetScale - originalStackAnimation.scale) * progress,
      opacity: 1
    };
    
    hilog.debug(0x0000, TAG, 'updateBackgroundCardAnimation: progress=%{public}f, scale=%{public}f', progress, this.backgroundCardAnimation.scale);
  }

  /**
   * 获取卡片位移
   */
  private getCardTranslate(stackIndex: number, dataIndex: number): TranslateOptions {
    if (dataIndex === this.currentIndex) {
      // 当前卡片
      hilog.debug(0x0000, TAG, 'getCardTranslate: 当前卡片 dataIndex=%{public}d, translateX=%{public}d, translateY=%{public}d', 
        dataIndex, this.topCardAnimation.translateX, this.topCardAnimation.translateY);
      const translateOptions: TranslateOptions = {
        x: this.topCardAnimation.translateX,
        y: this.topCardAnimation.translateY,
        z: 0
      };
      return translateOptions;
    } else if (dataIndex === this.currentIndex + 1 && this.dragProgress > 0) {
      // 第二张卡片，且正在拖拽时使用跟随动画
      hilog.debug(0x0000, TAG, 'getCardTranslate: 跟随卡片 dataIndex=%{public}d, translateX=%{public}d, translateY=%{public}d', 
        dataIndex, this.backgroundCardAnimation.translateX, this.backgroundCardAnimation.translateY);
      const translateOptions: TranslateOptions = {
        x: this.backgroundCardAnimation.translateX,
        y: this.backgroundCardAnimation.translateY,
        z: 0
      };
      return translateOptions;
    } else {
      // 其他背景卡片
      const stackAnimation: AnimationParams = AnimationUtils.calculateStackAnimation(
        stackIndex,
        this.finalConfig.scaleRatio,
        this.finalConfig.cardSpacing
      );
      hilog.debug(0x0000, TAG, 'getCardTranslate: 背景卡片 stackIndex=%{public}d, translateX=%{public}d, translateY=%{public}d', 
        stackIndex, stackAnimation.translateX, stackAnimation.translateY);
      const translateOptions: TranslateOptions = {
        x: stackAnimation.translateX,
        y: stackAnimation.translateY,
        z: 0
      };
      return translateOptions;
    }
  }

  /**
   * 获取卡片缩放
   */
  private getCardScale(stackIndex: number, dataIndex: number): ScaleOptions {
    if (dataIndex === this.currentIndex) {
      // 当前卡片
      const scaleOptions: ScaleOptions = {
        x: this.topCardAnimation.scale,
        y: this.topCardAnimation.scale,
        z: 1
      };
      return scaleOptions;
    } else if (dataIndex === this.currentIndex + 1 && this.dragProgress > 0) {
      // 第二张卡片，且正在拖拽时使用跟随动画
      const scaleOptions: ScaleOptions = {
        x: this.backgroundCardAnimation.scale,
        y: this.backgroundCardAnimation.scale,
        z: 1
      };
      return scaleOptions;
    } else {
      // 其他背景卡片
      const stackAnimation: AnimationParams = AnimationUtils.calculateStackAnimation(
        stackIndex,
        this.finalConfig.scaleRatio,
        this.finalConfig.cardSpacing
      );
      const scaleOptions: ScaleOptions = {
        x: stackAnimation.scale,
        y: stackAnimation.scale,
        z: 1
      };
      return scaleOptions;
    }
  }

  /**
   * 获取卡片旋转
   */
  private getCardRotation(stackIndex: number, dataIndex: number): RotateOptions {
    if (dataIndex === this.currentIndex) {
      const rotateOptions: RotateOptions = {
        z: this.topCardAnimation.rotation,
        angle: this.topCardAnimation.rotation
      };
      return rotateOptions;
    } else {
      const rotateOptions: RotateOptions = {
        z: 0,
        angle: 0
      };
      return rotateOptions;
    }
  }

  /**
   * 获取卡片透明度
   */
  private getCardOpacity(stackIndex: number, dataIndex: number): number {
    if (dataIndex === this.currentIndex) {
      return this.topCardAnimation.opacity;
    } else {
      return 1;
    }
  }

  /**
   * 获取卡片层级
   */
  private getCardZIndex(dataIndex: number): number {
    // 确保当前卡片在最上层，后续卡片按顺序递减
    // 使用一个较大的基数来确保正确的层叠顺序
    const baseZIndex: number = 1000;
    const zIndex: number = baseZIndex - (dataIndex - this.currentIndex);
    hilog.debug(0x0000, TAG, 'getCardZIndex: dataIndex=%{public}d, currentIndex=%{public}d, zIndex=%{public}d', 
      dataIndex, this.currentIndex, zIndex);
    return zIndex;
  }

  /**
   * 获取卡片手势
   */
  private getCardGesture(data: CardData, dataIndex: number, stackIndex: number): GestureGroupInterface {
    hilog.debug(0x0000, TAG, 'getCardGesture: cardId=%{public}s, stackIndex=%{public}d, 是否顶层=%{public}s', 
      data.id, stackIndex, stackIndex === 0 ? 'true' : 'false');
    
    // 临时：为所有卡片创建手势来测试
    return this.createCardGesture(data, dataIndex);
  }

  /**
   * 执行滑出动画
   */
  private performSwipeOut(deltaX: number, deltaY: number, data: CardData, dataIndex: number): void {
    this.cardState = CardState.SWIPING;
    
    // 判断滑动方向
    const direction: SwipeDirection = Math.abs(deltaX) > Math.abs(deltaY) 
      ? (deltaX > 0 ? SwipeDirection.RIGHT : SwipeDirection.LEFT)
      : (deltaY > 0 ? SwipeDirection.DOWN : SwipeDirection.UP);
    
    hilog.debug(0x0000, TAG, '滑动方向: %{public}s', direction);
    
    // 计算滑出的最终位置（移动到屏幕外）
    const screenWidth: number = this.componentWidth;
    const finalX: number = deltaX > 0 ? screenWidth : -screenWidth;
    const finalY: number = deltaY * 2; // 保持Y轴方向但加大幅度
    
    // 计算最终旋转角度
    const cardWidth: number = this.componentWidth * LayoutConstants.DEFAULT_CARD_WIDTH_RATIO;
    const finalRotation: number = finalX / cardWidth * this.finalConfig.rotationAngle * 2;
    
    hilog.debug(0x0000, TAG, '滑出目标: finalX=%{public}d, finalY=%{public}d, rotation=%{public}d', 
      finalX, finalY, finalRotation);
    
    // 执行滑出动画
    animateTo({
      duration: this.finalConfig.animationDuration,
      curve: Curve.EaseOut,
      onFinish: (): void => {
        hilog.debug(0x0000, TAG, '滑出动画完成，切换到下一张卡片');
        this.onSwipeComplete(data, dataIndex, direction);
      }
    }, (): void => {
      this.topCardAnimation = {
        translateX: finalX,
        translateY: finalY,
        rotation: finalRotation,
        scale: 0.8,
        opacity: 0.3
      };
    });
  }

  /**
   * 滑动完成处理
   */
  private onSwipeComplete(data: CardData, dataIndex: number, direction: SwipeDirection): void {
    // 移动到下一张卡片
    this.currentIndex++;
    hilog.debug(0x0000, TAG, '切换到下一张卡片，新的currentIndex: %{public}d', this.currentIndex);
    
    // 重置所有动画状态
    this.topCardAnimation = {
      translateX: 0,
      translateY: 0,
      rotation: 0,
      scale: 1,
      opacity: 1
    };
    this.backgroundCardAnimation = {
      translateX: 0,
      translateY: 0,
      rotation: 0,
      scale: 1,
      opacity: 1
    };
    this.dragProgress = 0;
    
    // 输出新的顶层卡片信息
    if (this.currentIndex < this.cardDataList.length) {
      const newTopCard: CardData = this.cardDataList[this.currentIndex];
      hilog.debug(0x0000, TAG, '新顶层卡片: id=%{public}s, currentIndex=%{public}d', newTopCard.id, this.currentIndex);
    } else {
      hilog.debug(0x0000, TAG, '所有卡片已滑完');
    }

    // 触发滑动事件
    if (this.eventHandler.onCardSwiped) {
      hilog.debug(0x0000, TAG, '触发onCardSwiped回调');
      this.eventHandler.onCardSwiped(direction, data, dataIndex);
    }

    // 检查是否接近栈底
    const remainingCount: number = this.cardDataList.length - this.currentIndex;
    if (remainingCount <= this.finalConfig.minStackSize && this.eventHandler.onStackNearEmpty) {
      hilog.debug(0x0000, TAG, '栈接近空了，剩余: %{public}d', remainingCount);
      this.eventHandler.onStackNearEmpty(remainingCount);
    }

    // 检查是否栈空
    if (remainingCount === 0 && this.eventHandler.onStackEmpty) {
      hilog.debug(0x0000, TAG, '栈空了');
      this.eventHandler.onStackEmpty();
    }

    // 检查是否需要预加载下一页
    if (remainingCount <= this.finalConfig.preloadThreshold && this.eventHandler.onLoadNextPage) {
      hilog.debug(0x0000, TAG, '触发预加载回调，剩余: %{public}d, 阈值: %{public}d', remainingCount, this.finalConfig.preloadThreshold);
      this.eventHandler.onLoadNextPage(this.currentIndex, remainingCount);
    }

    this.cardState = CardState.IDLE;
  }

  /**
   * 创建卡片手势
   */
  private createCardGesture(data: CardData, dataIndex: number): GestureGroupInterface {
    hilog.debug(0x0000, TAG, 'createCardGesture被调用: cardId=%{public}s, dataIndex=%{public}d', data.id, dataIndex);
    
    const dragGesture: PanGestureInterface = GestureUtils.createDragGesture(
      (x: number, y: number): void => {
        this.handleDragStart(x, y);
      },
      (state: GestureState): void => {
        this.handleDragUpdate(state);
      },
      (state: GestureState): void => {
        this.handleDragEnd(state, data, dataIndex);
      }
    );

    const tapGesture: TapGestureInterface = GestureUtils.createTapGesture((): void => {
      this.onCardClick(data, dataIndex);
    });

    hilog.debug(0x0000, TAG, 'createCardGesture完成: 手势已创建');

    return GestureGroup(GestureMode.Exclusive, dragGesture, tapGesture);
  }

  /**
   * 拖拽开始处理
   */
  private handleDragStart(x: number, y: number): void {
    hilog.debug(0x0000, TAG, '拖拽开始: %{public}f, %{public}f', x, y);
    this.cardState = CardState.DRAGGING;
  }

  /**
   * 拖拽更新处理
   */
  private handleDragUpdate(state: GestureState): void {
    if (!GestureUtils.isValidDrag(state)) {
      hilog.debug(0x0000, TAG, '拖拽无效，距离太小: %{public}f', Math.sqrt(state.deltaX * state.deltaX + state.deltaY * state.deltaY));
      return;
    }

    hilog.debug(0x0000, TAG, '拖拽更新: deltaX=%{public}f, deltaY=%{public}f, 组件尺寸=%{public}dx%{public}d', 
      state.deltaX, state.deltaY, this.componentWidth, this.componentHeight);
    this.currentGestureState = state;
    const cardWidth: number = this.componentWidth * LayoutConstants.DEFAULT_CARD_WIDTH_RATIO;

    const dragAnimation: AnimationParams = AnimationUtils.calculateDragAnimation(
      state.deltaX,
      state.deltaY,
      cardWidth,
      this.finalConfig.rotationAngle
    );

    this.topCardAnimation = dragAnimation;
  }

  /**
   * 拖拽结束处理
   */
  private handleDragEnd(state: GestureState, data: CardData, dataIndex: number): void {
    hilog.debug(0x0000, TAG, '拖拽结束: deltaX=%{public}f, deltaY=%{public}f, 阈值=%{public}d', 
      state.deltaX, state.deltaY, this.finalConfig.swipeThreshold);
    this.currentGestureState = null;

    if (GestureUtils.shouldTriggerSwipe(state, this.finalConfig.swipeThreshold)) {
      hilog.debug(0x0000, TAG, '触发滑动');
      this.performSwipe(state, data, dataIndex);
    } else {
      hilog.debug(0x0000, TAG, '触发弹回');
      this.performSpringBack();
    }
  }

  /**
   * 卡片点击处理
   */
  private onCardClick(data: CardData, dataIndex: number): void {
    hilog.debug(0x0000, TAG, '卡片点击: id=%{public}s, 状态=%{public}s', data.id, this.cardState);
    if (this.cardState === CardState.IDLE && this.eventHandler.onCardClicked) {
      this.eventHandler.onCardClicked(data, dataIndex);
    }
  }

  /**
   * 执行滑动动画
   */
  private performSwipe(state: GestureState, data: CardData, dataIndex: number): void {
    this.cardState = CardState.SWIPING;
    const direction: SwipeDirection = GestureUtils.getSwipeDirection(state);

    const cardWidth: number = this.componentWidth * LayoutConstants.DEFAULT_CARD_WIDTH_RATIO;
    const cardHeight: number = this.componentHeight * LayoutConstants.DEFAULT_CARD_HEIGHT_RATIO;

    const swipeAnimation: AnimationParams = AnimationUtils.createSwipeOutAnimation(
      direction,
      cardWidth,
      cardHeight,
      this.finalConfig.rotationAngle
    );

    const duration: number = AnimationUtils.calculateAnimationDuration(
      state.velocity,
      this.finalConfig.animationDuration
    );

    const animationOptions: AnimateParam = AnimationUtils.createAnimationOptions(duration);
    animationOptions.onFinish = (): void => {
      this.onSwipeComplete(data, dataIndex, direction);
    };

    animateTo(animationOptions, (): void => {
      this.topCardAnimation = swipeAnimation;
    });
  }

  /**
   * 执行弹回动画
   */
  private performSpringBack(): void {
    if (!this.finalConfig.enableSpringBack) {
      this.cardState = CardState.IDLE;
      this.topCardAnimation = AnimationUtils.createSpringBackAnimation();
      return;
    }

    this.cardState = CardState.ANIMATING;
    const springBackAnimation: AnimationParams = AnimationUtils.createSpringBackAnimation();

    const animationOptions: AnimateParam = AnimationUtils.createAnimationOptions(
      this.finalConfig.animationDuration,
      AnimationUtils.createSpringCurve()
    );
    animationOptions.onFinish = (): void => {
      this.cardState = CardState.IDLE;
    };

    animateTo(animationOptions, (): void => {
      this.topCardAnimation = springBackAnimation;
    });
  }



  /**
   * 程序化向左滑动
   */
  public swipeLeft(): void {
    if (this.cardState !== CardState.IDLE || this.currentIndex >= this.cardDataList.length) {
      return;
    }

    const data: CardData = this.cardDataList[this.currentIndex];
    const fakeState: GestureState = {
      startX: 0,
      startY: 0,
      currentX: -this.finalConfig.swipeThreshold - 1,
      currentY: 0,
      deltaX: -this.finalConfig.swipeThreshold - 1,
      deltaY: 0,
      velocity: 0,
      isActive: false
    };

    this.performSwipe(fakeState, data, this.currentIndex);
  }

  /**
   * 程序化向右滑动
   */
  public swipeRight(): void {
    if (this.cardState !== CardState.IDLE || this.currentIndex >= this.cardDataList.length) {
      return;
    }

    const data: CardData = this.cardDataList[this.currentIndex];
    const fakeState: GestureState = {
      startX: 0,
      startY: 0,
      currentX: this.finalConfig.swipeThreshold + 1,
      currentY: 0,
      deltaX: this.finalConfig.swipeThreshold + 1,
      deltaY: 0,
      velocity: 0,
      isActive: false
    };

    this.performSwipe(fakeState, data, this.currentIndex);
  }

  /**
   * 重置卡片栈
   */
  public reset(): void {
    this.currentIndex = 0;
    this.cardState = CardState.IDLE;
    this.topCardAnimation = AnimationUtils.createSpringBackAnimation();
  }

  /**
   * 获取剩余卡片数量
   */
  public getRemainingCount(): number {
    return Math.max(0, this.cardDataList.length - this.currentIndex);
  }
} 