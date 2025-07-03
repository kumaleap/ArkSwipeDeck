/**
 * 动画工具类
 * 
 * 提供滑动卡片组件所需的动画效果和参数计算
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import curves from '@ohos.curves';
import type { AnimationParams } from '../types/SwipeCardTypes';
import { SwipeDirection } from '../types/SwipeCardTypes';
import { AnimationConstants, GestureConstants } from '../constants/DefaultConfigs';

/**
 * 动画工具类
 */
export class AnimationUtils {
  /**
   * 创建弹簧曲线动画
   * @param stiffness - 刚度
   * @param damping - 阻尼
   * @param mass - 质量
   * @returns 弹簧曲线
   */
  static createSpringCurve(
    stiffness: number = AnimationConstants.SPRING_STIFFNESS,
    damping: number = AnimationConstants.SPRING_DAMPING,
    mass: number = AnimationConstants.SPRING_MASS
  ): ICurve {
    return curves.springCurve(stiffness, damping, mass, 0);
  }

  /**
   * 创建滑动退出动画参数
   * @param direction - 滑动方向
   * @param cardWidth - 卡片宽度
   * @param cardHeight - 卡片高度
   * @param rotationAngle - 旋转角度
   * @returns 动画参数
   */
  static createSwipeOutAnimation(
    direction: SwipeDirection,
    cardWidth: number,
    cardHeight: number,
    rotationAngle: number
  ): AnimationParams {
    let translateX: number = 0;
    let translateY: number = 0;
    let rotation: number = 0;

    const exitDistance: number = Math.max(cardWidth, cardHeight) * 1.5;

    switch (direction) {
      case SwipeDirection.LEFT:
        translateX = -exitDistance;
        rotation = -rotationAngle;
        break;
      case SwipeDirection.RIGHT:
        translateX = exitDistance;
        rotation = rotationAngle;
        break;
      case SwipeDirection.UP:
        translateY = -exitDistance;
        break;
      case SwipeDirection.DOWN:
        translateY = exitDistance;
        break;
    }

    return {
      translateX: translateX,
      translateY: translateY,
      rotation: rotation,
      scale: 0.8,
      opacity: 0
    };
  }

  /**
   * 创建弹回动画参数
   * @returns 弹回动画参数
   */
  static createSpringBackAnimation(): AnimationParams {
    return {
      translateX: 0,
      translateY: 0,
      rotation: 0,
      scale: 1,
      opacity: 1
    };
  }

  /**
   * 根据拖拽距离计算实时动画参数
   * @param deltaX - X轴位移
   * @param deltaY - Y轴位移
   * @param cardWidth - 卡片宽度
   * @param maxRotation - 最大旋转角度
   * @returns 实时动画参数
   */
  static calculateDragAnimation(
    deltaX: number,
    deltaY: number,
    cardWidth: number,
    maxRotation: number = GestureConstants.MAX_ROTATION_ANGLE
  ): AnimationParams {
    const progress: number = Math.abs(deltaX) / cardWidth;
    const clampedProgress: number = Math.min(progress, 1);

    // 计算旋转角度
    const rotation: number = (deltaX / cardWidth) * maxRotation;
    const clampedRotation: number = Math.max(-maxRotation, Math.min(maxRotation, rotation));

    // 计算透明度
    const opacity: number = Math.max(0.3, 1 - clampedProgress * GestureConstants.OPACITY_CHANGE_RATE);

    // 计算缩放
    const scale: number = Math.max(0.8, 1 - clampedProgress * GestureConstants.SCALE_CHANGE_RATE);

    return {
      translateX: deltaX,
      translateY: deltaY,
      rotation: clampedRotation,
      scale: scale,
      opacity: opacity
    };
  }

  /**
   * 计算卡片堆叠动画参数
   * @param index - 卡片索引（0为顶层卡片）
   * @param scaleRatio - 缩放比例
   * @param cardSpacing - 卡片间距
   * @returns 堆叠动画参数
   */
  static calculateStackAnimation(
    index: number,
    scaleRatio: number,
    cardSpacing: number
  ): AnimationParams {
    const scale: number = Math.pow(scaleRatio, index);
    const translateY: number = index * cardSpacing;

    return {
      translateX: 0,
      translateY: translateY,
      rotation: 0,
      scale: scale,
      opacity: 1
    };
  }

  /**
   * 判断是否为快速滑动
   * @param velocity - 滑动速度
   * @returns 是否为快速滑动
   */
  static isFastSwipe(velocity: number): boolean {
    return Math.abs(velocity) >= AnimationConstants.FAST_SWIPE_VELOCITY;
  }

  /**
   * 根据速度计算动画持续时间
   * @param velocity - 滑动速度
   * @param baseDuration - 基础持续时间
   * @returns 计算后的动画持续时间
   */
  static calculateAnimationDuration(velocity: number, baseDuration: number): number {
    if (AnimationUtils.isFastSwipe(velocity)) {
      return AnimationConstants.MIN_ANIMATION_DURATION;
    }

    const normalizedVelocity: number = Math.abs(velocity) / AnimationConstants.FAST_SWIPE_VELOCITY;
    const duration: number = baseDuration * (1 - normalizedVelocity * 0.5);

    return Math.max(
      AnimationConstants.MIN_ANIMATION_DURATION,
      Math.min(AnimationConstants.MAX_ANIMATION_DURATION, duration)
    );
  }

  /**
   * 创建动画选项
   * @param duration - 动画持续时间
   * @param curve - 动画曲线
   * @returns 动画选项
   */
  static createAnimationOptions(duration: number, curve?: ICurve): AnimateParam {
    return {
      duration: duration,
      curve: curve ?? Curve.Ease,
      iterations: 1,
      playMode: PlayMode.Normal,
      onFinish: undefined
    };
  }

  /**
   * 插值计算
   * @param from - 起始值
   * @param to - 结束值
   * @param progress - 进度（0-1）
   * @returns 插值结果
   */
  static interpolate(from: number, to: number, progress: number): number {
    return from + (to - from) * progress;
  }

  /**
   * 限制数值范围
   * @param value - 输入值
   * @param min - 最小值
   * @param max - 最大值
   * @returns 限制后的值
   */
  static clamp(value: number, min: number, max: number): number {
    return Math.max(min, Math.min(max, value));
  }

  /**
   * 计算两点间距离
   * @param x1 - 起点X坐标
   * @param y1 - 起点Y坐标
   * @param x2 - 终点X坐标
   * @param y2 - 终点Y坐标
   * @returns 距离
   */
  static calculateDistance(x1: number, y1: number, x2: number, y2: number): number {
    const deltaX: number = x2 - x1;
    const deltaY: number = y2 - y1;
    return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
  }
} 