/**
 * SwipeCardStack 组件核心类型定义
 * 
 * 提供卡片堆叠滑动容器的所有类型定义
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
 * 动画类型枚举
 */
export const enum AnimationType {
  SPRING = 'spring',
  FRICTION = 'friction',
  EASE = 'ease'
}

/**
 * 卡片状态枚举
 */
export const enum CardState {
  IDLE = 'idle',
  DRAGGING = 'dragging',
  ANIMATING = 'animating',
  DISMISSED = 'dismissed'
}

/**
 * 卡片数据基础值类型
 */
export type CardDataPrimitiveValue = string | number | boolean | null;

/**
 * 卡片数据接口
 * 使用预定义字段替代索引签名 (符合arkts-no-indexed-signatures规范)
 */
export interface CardData {
  /** 唯一标识符 */
  readonly id: string;
  /** 卡片索引 */
  readonly index: number;
  /** 是否可见 */
  visible: boolean;
  /** 自定义数据 - 使用Map存储动态键值对 */
  data?: Map<string, CardDataPrimitiveValue>;
}

/**
 * 滑动事件数据接口
 */
export interface SwipeEvent {
  /** 卡片数据 */
  readonly card: CardData;
  /** 滑动方向 */
  readonly direction: SwipeDirection;
  /** 滑动距离比例 (0-1) */
  readonly progress: number;
  /** 滑动速度 */
  readonly velocity: number;
  /** 触摸位置 */
  readonly position: Position;
}

/**
 * 位置坐标接口
 */
export interface Position {
  readonly x: number;
  readonly y: number;
}

/**
 * 容器尺寸接口
 */
export interface ContainerSize {
  width: number;
  height: number;
}

/**
 * 动画配置接口
 */
export interface AnimationConfig {
  /** 动画类型 */
  readonly type: AnimationType;
  /** 动画时长(ms) */
  readonly duration: number;
  /** 弹簧动画参数 */
  readonly spring?: SpringConfig;
  /** 摩擦动画参数 */
  readonly friction?: FrictionConfig;
  /** 缓动曲线 */
  readonly curve?: Curve;
}

/**
 * 弹簧动画配置
 */
export interface SpringConfig {
  readonly velocity: number;
  readonly mass: number;
  readonly stiffness: number;
  readonly damping: number;
}

/**
 * 摩擦动画配置
 */
export interface FrictionConfig {
  readonly friction: number;
}

/**
 * 堆叠配置接口
 */
export interface StackConfig {
  /** 可见卡片数量 */
  readonly visibleCount: number;
  /** 卡片间距 */
  readonly cardSpacing: number;
  /** 缩放比例 */
  readonly scaleStep: number;
  /** 透明度步长 */
  readonly opacityStep: number;
  /** 旋转角度步长 */
  readonly rotationStep: number;
}

/**
 * 滑动配置接口
 */
export interface SwipeConfig {
  /** 滑动阈值距离 */
  readonly threshold: number;
  /** 滑动阈值速度 */
  readonly velocityThreshold: number;
  /** 允许的滑动方向 */
  readonly allowedDirections: SwipeDirection[];
  /** 最大旋转角度 */
  readonly maxRotation: number;
  /** 是否启用边界回弹 */
  readonly enableBounce: boolean;
}

/**
 * 组件配置接口
 */
export interface SwipeCardStackConfig {
  /** 堆叠配置 */
  readonly stack: StackConfig;
  /** 滑动配置 */
  readonly swipe: SwipeConfig;
  /** 动画配置 */
  readonly animation: AnimationConfig;
  /** 是否启用循环模式 */
  readonly enableLoop: boolean;
  /** 是否启用调试模式 */
  readonly debug: boolean;
}

/**
 * 组件配置更新接口
 * 替代Partial<SwipeCardStackConfig> (符合arkts规范)
 */
export interface SwipeCardStackConfigUpdate {
  /** 堆叠配置 */
  readonly stack?: StackConfig;
  /** 滑动配置 */
  readonly swipe?: SwipeConfig;
  /** 动画配置 */
  readonly animation?: AnimationConfig;
  /** 是否启用循环模式 */
  readonly enableLoop?: boolean;
  /** 是否启用调试模式 */
  readonly debug?: boolean;
}

/**
 * 事件回调接口
 */
export interface SwipeCardStackCallbacks {
  /** 开始拖拽回调 */
  onDragStart?: (event: SwipeEvent) => void;
  /** 拖拽中回调 */
  onDragUpdate?: (event: SwipeEvent) => void;
  /** 拖拽结束回调 */
  onDragEnd?: (event: SwipeEvent) => void;
  /** 卡片滑出回调 */
  onCardSwiped?: (event: SwipeEvent) => void;
  /** 卡片回弹回调 */
  onCardBounced?: (event: SwipeEvent) => void;
  /** 卡片栈为空回调 */
  onStackEmpty?: () => void;
  /** 卡片栈更新回调 */
  onStackUpdate?: (visibleCards: CardData[]) => void;
}

/**
 * 组件控制器接口
 */
export interface SwipeCardStackController {
  /** 程序化触发左滑 */
  swipeLeft(animated?: boolean): Promise<void>;
  /** 程序化触发右滑 */
  swipeRight(animated?: boolean): Promise<void>;
  /** 程序化触发上滑 */
  swipeUp(animated?: boolean): Promise<void>;
  /** 程序化触发下滑 */
  swipeDown(animated?: boolean): Promise<void>;
  /** 重置当前卡片位置 */
  resetCard(animated?: boolean): Promise<void>;
  /** 获取当前可见卡片 */
  getVisibleCards(): CardData[];
  /** 获取顶部卡片 */
  getTopCard(): CardData | null;
  /** 更新配置 */
  updateConfig(config: SwipeCardStackConfigUpdate): void;
  /** 重新加载数据 */
  reload(cards: CardData[]): void;
} 