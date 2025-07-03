/**
 * 滑动卡片堆叠组件
 *
 * 实现类似Tinder的滑动卡片效果
 * 遵循ArkTS严格语法规范
 *
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import type {
  SwipeConfig,
  AnimationParams,
  InternalCardInfo,
  SwipeEventHandler
} from '../types/SwipeCardTypes';
import { SwipeDirection, CardState } from '../types/SwipeCardTypes';
import { mergeSwipeConfig, LayoutConstants } from '../constants/DefaultConfigs';
import { AnimationUtils } from '../utils/AnimationUtils';

/**
 * 滑动卡片堆叠组件
 */
@Component
export struct SwipeCardStack {
  /** 卡片数据列表 - 支持任意对象结构 */
  @Prop private cardDataList: object[] = [];
  /** 滑动配置 */
  @Prop private swipeConfig: SwipeConfig = {};
  /** 事件监听器 */
  @Prop private eventHandler: SwipeEventHandler = {};
  /** 卡片内容构建器 */
  @BuilderParam private cardBuilder?: (data: object, index: number) => void;
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

  aboutToAppear(): void {
    // 初始化配置
    this.finalConfig = mergeSwipeConfig(this.swipeConfig);
  }

  /**
   * 添加新的卡片数据
   * @param newCards - 新的卡片数据数组
   */
  public addCards(newCards: object[]): void {
    if (newCards.length === 0) {
      return;
    }

    // 添加新卡片到数组末尾 - ArkTS规范：手动循环替代扩展运算符
    for (let i = 0; i < newCards.length; i++) {
      this.cardDataList.push(newCards[i]);
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
          (cardInfo: InternalCardInfo) => {
            this.buildCard(cardInfo.data, cardInfo.dataIndex, cardInfo.stackIndex);
          },
          (cardInfo: InternalCardInfo): string => cardInfo.dataIndex.toString()
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
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      const newWidth: number = Number(newValue.width);
      const newHeight: number = Number(newValue.height);
      if (newWidth > 0 && newHeight > 0) {
        this.componentWidth = newWidth;
        this.componentHeight = newHeight;
      }
    })
  }

  /**
   * 构建单个卡片
   */
  @Builder
  private buildCard(data: object, dataIndex: number, stackIndex: number): void {
    Stack() {
      if (this.cardBuilder) {
        this.cardBuilder(data, dataIndex);
      }
    }
    .width(this.componentWidth * LayoutConstants.DEFAULT_CARD_WIDTH_RATIO)
    .height(this.componentHeight * LayoutConstants.DEFAULT_CARD_HEIGHT_RATIO)
    .translate(this.getCardTranslate(stackIndex, dataIndex))
    .scale(this.getCardScale(stackIndex, dataIndex))
    .rotate(this.getCardRotation(stackIndex, dataIndex))
    .opacity(this.getCardOpacity(stackIndex, dataIndex))
    .zIndex(this.getCardZIndex(dataIndex))
    .gesture(
      // 给所有卡片添加手势，但在事件中判断是否响应
      PanGesture({ fingers: 1, direction: PanDirection.All, distance: 1 })
        .onActionStart((_event: GestureEvent): void => {
          // 只有当前索引对应的卡片才响应手势
          if (dataIndex !== this.currentIndex) {
            return;
          }

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
          // 只有当前索引对应的卡片才响应手势
          if (dataIndex !== this.currentIndex) {
            return;
          }

          const deltaX: number = event.offsetX;
          const deltaY: number = event.offsetY;

          // 判断是否达到滑动阈值
          const distance: number = Math.sqrt(deltaX * deltaX + deltaY * deltaY);

          if (distance >= this.finalConfig.swipeThreshold) {
            // 达到阈值，执行滑出动画
            this.performSwipeOut(deltaX, deltaY, data, dataIndex);
          } else {
            // 未达到阈值，弹回
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
   * 获取可见卡片列表
   */
  private getVisibleCards(): InternalCardInfo[] {
    const visibleCards: InternalCardInfo[] = [];
    const maxVisible: number = Math.min(this.finalConfig.maxVisibleCards, this.cardDataList.length);

    for (let i = 0; i < maxVisible; i++) {
      const dataIndex: number = this.currentIndex + i;
      if (dataIndex < this.cardDataList.length) {
        const cardInfo: InternalCardInfo = {
          data: this.cardDataList[dataIndex],
          dataIndex: dataIndex,
          stackIndex: i
        };
        visibleCards.push(cardInfo);
      }
    }

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
  }

  /**
   * 获取卡片位移
   */
  private getCardTranslate(stackIndex: number, dataIndex: number): TranslateOptions {
    if (dataIndex === this.currentIndex) {
      // 当前卡片
      const translateOptions: TranslateOptions = {
        x: this.topCardAnimation.translateX,
        y: this.topCardAnimation.translateY,
        z: 0
      };
      return translateOptions;
    } else if (dataIndex === this.currentIndex + 1 && this.dragProgress > 0) {
      // 第二张卡片，且正在拖拽时使用跟随动画
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
  private getCardRotation(_stackIndex: number, dataIndex: number): RotateOptions {
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
  private getCardOpacity(_stackIndex: number, dataIndex: number): number {
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
    return zIndex;
  }

  /**
   * 执行滑出动画
   */
  private performSwipeOut(deltaX: number, deltaY: number, data: object, dataIndex: number): void {
    this.cardState = CardState.SWIPING;

    // 判断滑动方向
    const direction: SwipeDirection = Math.abs(deltaX) > Math.abs(deltaY)
      ? (deltaX > 0 ? SwipeDirection.RIGHT : SwipeDirection.LEFT)
      : (deltaY > 0 ? SwipeDirection.DOWN : SwipeDirection.UP);

    // 计算滑出的最终位置（移动到屏幕外）
    const screenWidth: number = this.componentWidth;
    const finalX: number = deltaX > 0 ? screenWidth : -screenWidth;
    const finalY: number = deltaY * 2; // 保持Y轴方向但加大幅度

    // 计算最终旋转角度
    const cardWidth: number = this.componentWidth * LayoutConstants.DEFAULT_CARD_WIDTH_RATIO;
    const finalRotation: number = finalX / cardWidth * this.finalConfig.rotationAngle * 2;

    // 执行滑出动画
    animateTo({
      duration: this.finalConfig.animationDuration,
      curve: Curve.EaseOut,
      onFinish: (): void => {
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
  private onSwipeComplete(data: object, dataIndex: number, direction: SwipeDirection): void {
    // 移动到下一张卡片
    this.currentIndex++;

    // 重置所有动画状态 - ArkTS规范：手动赋值替代扩展运算符
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

    // 触发滑动事件
    if (this.eventHandler.onCardSwiped) {
      this.eventHandler.onCardSwiped(direction, data, dataIndex);
    }

    // 检查是否接近栈底
    const remainingCount: number = this.cardDataList.length - this.currentIndex;
    if (remainingCount <= this.finalConfig.minStackSize && this.eventHandler.onStackNearEmpty) {
      this.eventHandler.onStackNearEmpty(remainingCount);
    }

    // 检查是否栈空
    if (remainingCount === 0 && this.eventHandler.onStackEmpty) {
      this.eventHandler.onStackEmpty();
    }

    // 检查是否需要预加载下一页
    if (remainingCount <= this.finalConfig.preloadThreshold && this.eventHandler.onLoadNextPage) {
      this.eventHandler.onLoadNextPage(this.currentIndex, remainingCount);
    }

    this.cardState = CardState.IDLE;
  }

  /**
   * 程序化向左滑动
   */
  public swipeLeft(): void {
    if (this.cardState !== CardState.IDLE || this.currentIndex >= this.cardDataList.length) {
      return;
    }

    const data: object = this.cardDataList[this.currentIndex];
    const deltaX: number = -this.finalConfig.swipeThreshold - 1;
    const deltaY: number = 0;

    this.performSwipeOut(deltaX, deltaY, data, this.currentIndex);
  }

  /**
   * 程序化向右滑动
   */
  public swipeRight(): void {
    if (this.cardState !== CardState.IDLE || this.currentIndex >= this.cardDataList.length) {
      return;
    }

    const data: object = this.cardDataList[this.currentIndex];
    const deltaX: number = this.finalConfig.swipeThreshold + 1;
    const deltaY: number = 0;

    this.performSwipeOut(deltaX, deltaY, data, this.currentIndex);
  }

  /**
   * 重置卡片栈
   */
  public reset(): void {
    this.currentIndex = 0;
    this.cardState = CardState.IDLE;
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
  }

  /**
   * 获取剩余卡片数量
   */
  public getRemainingCount(): number {
    return Math.max(0, this.cardDataList.length - this.currentIndex);
  }
} 