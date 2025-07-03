/**
 * 滑动卡片默认配置
 * 
 * 提供滑动卡片组件的默认配置参数
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import type { SwipeConfig } from '../types/SwipeCardTypes';

/**
 * 默认滑动配置
 */
export const DEFAULT_SWIPE_CONFIG: Required<SwipeConfig> = {
  maxVisibleCards: 4,
  minStackSize: 2,
  rotationAngle: 15,
  scaleRatio: 0.95,
  swipeThreshold: 100,
  animationDuration: 300,
  enableSpringBack: true,
  cardSpacing: 8,
  preloadThreshold: 3
};

/**
 * 动画配置常量
 */
export class AnimationConstants {
  /** 弹簧动画刚度 */
  static readonly SPRING_STIFFNESS: number = 400;
  
  /** 弹簧动画阻尼 */
  static readonly SPRING_DAMPING: number = 0.7;
  
  /** 弹簧动画质量 */
  static readonly SPRING_MASS: number = 1.0;
  
  /** 快速滑动速度阈值 */
  static readonly FAST_SWIPE_VELOCITY: number = 1000;
  
  /** 最小动画持续时间 */
  static readonly MIN_ANIMATION_DURATION: number = 200;
  
  /** 最大动画持续时间 */
  static readonly MAX_ANIMATION_DURATION: number = 500;
}

/**
 * 手势配置常量
 */
export class GestureConstants {
  /** 最小拖拽距离 */
  static readonly MIN_DRAG_DISTANCE: number = 10;
  
  /** 最大旋转角度 */
  static readonly MAX_ROTATION_ANGLE: number = 45;
  
  /** 透明度变化速率 */
  static readonly OPACITY_CHANGE_RATE: number = 0.5;
  
  /** 缩放变化速率 */
  static readonly SCALE_CHANGE_RATE: number = 0.1;
}

/**
 * 布局配置常量
 */
export class LayoutConstants {
  /** 默认卡片宽度比例 */
  static readonly DEFAULT_CARD_WIDTH_RATIO: number = 0.85;
  
  /** 默认卡片高度比例 */
  static readonly DEFAULT_CARD_HEIGHT_RATIO: number = 0.7;
  
  /** 卡片圆角半径 */
  static readonly CARD_BORDER_RADIUS: number = 12;
  
  /** 卡片阴影模糊半径 */
  static readonly CARD_SHADOW_BLUR: number = 8;
  
  /** 卡片阴影偏移 */
  static readonly CARD_SHADOW_OFFSET: number = 2;
}

/**
 * 合并用户配置和默认配置
 * @param userConfig - 用户配置
 * @returns 合并后的完整配置
 */
export function mergeSwipeConfig(userConfig?: SwipeConfig): Required<SwipeConfig> {
  const merged: Required<SwipeConfig> = {
    maxVisibleCards: DEFAULT_SWIPE_CONFIG.maxVisibleCards,
    minStackSize: DEFAULT_SWIPE_CONFIG.minStackSize,
    rotationAngle: DEFAULT_SWIPE_CONFIG.rotationAngle,
    scaleRatio: DEFAULT_SWIPE_CONFIG.scaleRatio,
    swipeThreshold: DEFAULT_SWIPE_CONFIG.swipeThreshold,
    animationDuration: DEFAULT_SWIPE_CONFIG.animationDuration,
    enableSpringBack: DEFAULT_SWIPE_CONFIG.enableSpringBack,
    cardSpacing: DEFAULT_SWIPE_CONFIG.cardSpacing,
    preloadThreshold: DEFAULT_SWIPE_CONFIG.preloadThreshold
  };
  
  if (userConfig !== undefined) {
    if (userConfig.maxVisibleCards !== undefined) {
      merged.maxVisibleCards = userConfig.maxVisibleCards;
    }
    if (userConfig.minStackSize !== undefined) {
      merged.minStackSize = userConfig.minStackSize;
    }
    if (userConfig.rotationAngle !== undefined) {
      merged.rotationAngle = userConfig.rotationAngle;
    }
    if (userConfig.scaleRatio !== undefined) {
      merged.scaleRatio = userConfig.scaleRatio;
    }
    if (userConfig.swipeThreshold !== undefined) {
      merged.swipeThreshold = userConfig.swipeThreshold;
    }
    if (userConfig.animationDuration !== undefined) {
      merged.animationDuration = userConfig.animationDuration;
    }
    if (userConfig.enableSpringBack !== undefined) {
      merged.enableSpringBack = userConfig.enableSpringBack;
    }
    if (userConfig.cardSpacing !== undefined) {
      merged.cardSpacing = userConfig.cardSpacing;
    }
    if (userConfig.preloadThreshold !== undefined) {
      merged.preloadThreshold = userConfig.preloadThreshold;
    }
  }
  
  return merged;
} 