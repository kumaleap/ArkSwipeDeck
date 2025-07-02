/**
 * SwipeCardStack 默认配置常量
 * 
 * 提供组件的默认配置参数，确保开箱即用的良好体验
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import type { 
  SwipeCardStackConfig, 
  StackConfig, 
  SwipeConfig, 
  AnimationConfig 
} from '../types/SwipeCardTypes';
import { SwipeDirection, AnimationType } from '../types/SwipeCardTypes';

/**
 * 默认堆叠配置
 */
export const DEFAULT_STACK_CONFIG: StackConfig = {
  visibleCount: 3,
  cardSpacing: 8,
  scaleStep: 0.05,
  opacityStep: 0.1,
  rotationStep: 2
};

/**
 * 默认滑动配置
 */
export const DEFAULT_SWIPE_CONFIG: SwipeConfig = {
  threshold: 80,
  velocityThreshold: 800,
  allowedDirections: [
    SwipeDirection.LEFT,
    SwipeDirection.RIGHT
  ],
  maxRotation: 15,
  enableBounce: true
};

/**
 * 默认动画配置
 */
export const DEFAULT_ANIMATION_CONFIG: AnimationConfig = {
  type: AnimationType.SPRING,
  duration: 300,
  spring: {
    velocity: 0,
    mass: 1,
    stiffness: 400,
    damping: 30
  },
  curve: Curve.FastOutSlowIn
};

/**
 * 默认组件配置
 */
export const DEFAULT_SWIPE_CARD_STACK_CONFIG: SwipeCardStackConfig = {
  stack: DEFAULT_STACK_CONFIG,
  swipe: DEFAULT_SWIPE_CONFIG,
  animation: DEFAULT_ANIMATION_CONFIG,
  enableLoop: false,
  debug: false
};

/**
 * 性能相关常量接口
 */
interface PerformanceConstants {
  /** 最大可见卡片数量 */
  readonly MAX_VISIBLE_COUNT: number;
  /** 最小拖拽距离 */
  readonly MIN_DRAG_DISTANCE: number;
  /** 防抖延迟时间 */
  readonly DEBOUNCE_DELAY: number;
  /** 动画帧率目标 */
  readonly TARGET_FPS: number;
}

/**
 * 性能相关常量
 */
export const PERFORMANCE_CONSTANTS: PerformanceConstants = {
  /** 最大可见卡片数量 */
  MAX_VISIBLE_COUNT: 5,
  /** 最小拖拽距离 */
  MIN_DRAG_DISTANCE: 10,
  /** 防抖延迟时间 */
  DEBOUNCE_DELAY: 16,
  /** 动画帧率目标 */
  TARGET_FPS: 60
};

/**
 * 手势相关常量接口
 */
interface GestureConstants {
  /** 最小滑动距离 */
  readonly MIN_SWIPE_DISTANCE: number;
  /** 最大触摸时间 */
  readonly MAX_TOUCH_TIME: number;
  /** 边界检测阈值 */
  readonly BOUNDARY_THRESHOLD: number;
}

/**
 * 手势相关常量
 */
export const GESTURE_CONSTANTS: GestureConstants = {
  /** 最小滑动距离 */
  MIN_SWIPE_DISTANCE: 50,
  /** 最大触摸时间 */
  MAX_TOUCH_TIME: 500,
  /** 边界检测阈值 */
  BOUNDARY_THRESHOLD: 0.7
};

/**
 * 动画相关常量接口
 */
interface AnimationConstants {
  /** 最小动画时长 */
  readonly MIN_DURATION: number;
  /** 最大动画时长 */
  readonly MAX_DURATION: number;
  /** 默认缓动函数 */
  readonly DEFAULT_CURVE: Curve;
  /** 回弹动画时长 */
  readonly BOUNCE_DURATION: number;
}

/**
 * 动画相关常量
 */
export const ANIMATION_CONSTANTS: AnimationConstants = {
  /** 最小动画时长 */
  MIN_DURATION: 100,
  /** 最大动画时长 */
  MAX_DURATION: 1000,
  /** 默认缓动函数 */
  DEFAULT_CURVE: Curve.FastOutSlowIn,
  /** 回弹动画时长 */
  BOUNCE_DURATION: 200
}; 