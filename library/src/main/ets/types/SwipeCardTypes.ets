/**
 * 滑动卡片类型定义
 * 
 * 定义滑动卡片组件所需的所有类型和接口
 * 遵循ArkTS严格语法规范
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

/**
 * 滑动方向枚举
 */
export const enum SwipeDirection {
  LEFT = 'left',
  RIGHT = 'right',
  UP = 'up',
  DOWN = 'down'
}

/**
 * 卡片状态枚举
 */
export const enum CardState {
  IDLE = 'idle',
  DRAGGING = 'dragging',
  SWIPING = 'swiping',
  ANIMATING = 'animating'
}

/**
 * 内部卡片信息接口 - 仅供组件内部使用
 * 包含数据对象、数据索引和堆叠索引
 */
interface InternalCardInfo {
  /** 用户数据对象 - 任意结构 */
  readonly data: object;
  /** 数据在原数组中的索引 */
  readonly dataIndex: number;
  /** 在可见卡片堆叠中的索引 */
  readonly stackIndex: number;
}

/**
 * 卡片滑动回调函数类型
 * @param direction - 滑动方向
 * @param data - 卡片数据对象
 * @param index - 卡片在数组中的索引
 */
export type OnCardSwipedCallback = (direction: SwipeDirection, data: object, index: number) => void;

/**
 * 卡片点击回调函数类型
 * @param data - 卡片数据对象
 * @param index - 卡片在数组中的索引
 */
export type OnCardClickedCallback = (data: object, index: number) => void;

/**
 * 卡片栈即将为空回调函数类型
 * @param remainingCount - 剩余卡片数量
 */
export type OnStackNearEmptyCallback = (remainingCount: number) => void;

/**
 * 卡片栈为空回调函数类型
 */
export type OnStackEmptyCallback = () => void;

/**
 * 预加载下一页回调函数类型
 * @param currentIndex - 当前卡片索引
 * @param remainingCount - 剩余卡片数量
 */
export type OnLoadNextPageCallback = (currentIndex: number, remainingCount: number) => void;

/**
 * 滑动事件处理器接口
 */
export interface SwipeEventHandler {
  /**
   * 卡片滑动回调
   */
  onCardSwiped?: OnCardSwipedCallback;

  /**
   * 卡片点击回调
   */
  onCardClicked?: OnCardClickedCallback;

  /**
   * 卡片栈即将为空回调
   */
  onStackNearEmpty?: OnStackNearEmptyCallback;

  /**
   * 卡片栈为空回调
   */
  onStackEmpty?: OnStackEmptyCallback;

  /**
   * 预加载下一页回调
   */
  onLoadNextPage?: OnLoadNextPageCallback;
}

/**
 * 滑动配置接口
 */
export interface SwipeConfig {
  /**
   * 最大可见卡片数量
   * @default 4
   */
  maxVisibleCards?: number;

  /**
   * 触发栈即将为空事件的最小卡片数量
   * @default 2
   */
  minStackSize?: number;

  /**
   * 卡片旋转角度（度）
   * @default 15
   */
  rotationAngle?: number;

  /**
   * 卡片缩放比例
   * @default 0.95
   */
  scaleRatio?: number;

  /**
   * 滑动阈值（触发滑动的最小距离）
   * @default 100
   */
  swipeThreshold?: number;

  /**
   * 动画持续时间（毫秒）
   * @default 300
   */
  animationDuration?: number;

  /**
   * 是否启用弹性效果
   * @default true
   */
  enableSpringBack?: boolean;

  /**
   * 卡片之间的间距（像素）
   * @default 8
   */
  cardSpacing?: number;

  /**
   * 预加载触发阈值（剩余卡片数量）
   * @default 3
   */
  preloadThreshold?: number;
}

/**
 * 动画参数接口
 */
export interface AnimationParams {
  translateX: number;
  translateY: number;
  rotation: number;
  scale: number;
  opacity: number;
}

/**
 * 手势状态接口
 */
export interface GestureState {
  startX: number;
  startY: number;
  currentX: number;
  currentY: number;
  deltaX: number;
  deltaY: number;
  velocity: number;
  isActive: boolean;
}

// 导出内部类型供组件使用
export type { InternalCardInfo }; 