/**
 * 动画工具类
 * 
 * 提供动画相关的工具函数和计算方法
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import type { AnimationConfig, Position } from '../types/SwipeCardTypes';
import { AnimationType } from '../types/SwipeCardTypes';
import { ANIMATION_CONSTANTS } from '../constants/DefaultConfigs';
import { curves } from '@kit.ArkUI';

/**
 * 动画工具类
 */
export class AnimationUtils {
  
  /**
   * 创建动画选项
   * 
   * @param config - 动画配置
   * @returns AnimateParam对象
   */
  public static createAnimateParam(config: AnimationConfig): AnimateParam {
    const duration: number = Math.max(
      ANIMATION_CONSTANTS.MIN_DURATION,
      Math.min(config.duration, ANIMATION_CONSTANTS.MAX_DURATION)
    );

    switch (config.type) {
      case AnimationType.SPRING: {
        const animateParam: AnimateParam = {
          duration: duration,
          curve: AnimationUtils.createSpringCurve(config),
          playMode: PlayMode.Normal
        };
        return animateParam;
      }

      case AnimationType.FRICTION: {
        const animateParam: AnimateParam = {
          duration: duration,
          curve: AnimationUtils.createFrictionCurve(config),
          playMode: PlayMode.Normal
        };
        return animateParam;
      }

      case AnimationType.EASE:
      default: {
        const animateParam: AnimateParam = {
          duration: duration,
          curve: config.curve ?? ANIMATION_CONSTANTS.DEFAULT_CURVE,
          playMode: PlayMode.Normal
        };
        return animateParam;
      }
    }
  }

  /**
   * 创建弹簧曲线
   * 
   * @param config - 动画配置
   * @returns 弹簧曲线
   */
  private static createSpringCurve(config: AnimationConfig): ICurve {
    if (config.spring) {
      return curves.springCurve(
        config.spring.velocity,
        config.spring.mass,
        config.spring.stiffness,
        config.spring.damping
      );
    }
    return curves.springCurve(0, 1, 400, 30);
  }

  /**
   * 创建摩擦曲线
   * 
   * @param config - 动画配置
   * @returns 摩擦曲线
   */
  private static createFrictionCurve(config: AnimationConfig): ICurve {
    if (config.friction) {
      // 使用三次贝塞尔曲线模拟摩擦效果
      // 摩擦值越大，缓动越明显
      const friction: number = Math.max(0.1, Math.min(1.0, config.friction.friction));
      const x1: number = 0.25;
      const y1: number = 0.1;
      const x2: number = 0.25 + (friction * 0.5);
      const y2: number = 1.0;
      return curves.cubicBezierCurve(x1, y1, x2, y2);
    }
    // 默认摩擦曲线：类似EaseOut效果
    return curves.cubicBezierCurve(0.25, 0.1, 0.55, 1.0);
  }

  /**
   * 计算插值
   * 
   * @param start - 起始值
   * @param end - 结束值
   * @param progress - 进度 (0-1)
   * @returns 插值结果
   */
  public static lerp(start: number, end: number, progress: number): number {
    return start + (end - start) * Math.max(0, Math.min(1, progress));
  }

  /**
   * 计算位置插值
   * 
   * @param start - 起始位置
   * @param end - 结束位置
   * @param progress - 进度 (0-1)
   * @returns 插值位置
   */
  public static lerpPosition(start: Position, end: Position, progress: number): Position {
    const position: Position = {
      x: AnimationUtils.lerp(start.x, end.x, progress),
      y: AnimationUtils.lerp(start.y, end.y, progress)
    };
    return position;
  }

  /**
   * 缓动函数 - EaseOut
   * 
   * @param t - 时间进度 (0-1)
   * @returns 缓动后的值
   */
  public static easeOut(t: number): number {
    return 1 - Math.pow(1 - t, 3);
  }

  /**
   * 缓动函数 - EaseIn
   * 
   * @param t - 时间进度 (0-1)
   * @returns 缓动后的值
   */
  public static easeIn(t: number): number {
    return Math.pow(t, 3);
  }

  /**
   * 缓动函数 - EaseInOut
   * 
   * @param t - 时间进度 (0-1)
   * @returns 缓动后的值
   */
  public static easeInOut(t: number): number {
    return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
  }

  /**
   * 计算弹性效果
   * 
   * @param t - 时间进度 (0-1)
   * @param amplitude - 振幅
   * @param period - 周期
   * @returns 弹性效果值
   */
  public static elasticOut(t: number, amplitude: number = 1, period: number = 0.3): number {
    if (t === 0 || t === 1) {
      return t;
    }

    const s: number = period / (2 * Math.PI) * Math.asin(1 / amplitude);
    return amplitude * Math.pow(2, -10 * t) * Math.sin((t - s) * (2 * Math.PI) / period) + 1;
  }

  /**
   * 计算回弹效果
   * 
   * @param t - 时间进度 (0-1)
   * @returns 回弹效果值
   */
  public static bounceOut(t: number): number {
    if (t < 1 / 2.75) {
      return 7.5625 * t * t;
    } else if (t < 2 / 2.75) {
      return 7.5625 * (t -= 1.5 / 2.75) * t + 0.75;
    } else if (t < 2.5 / 2.75) {
      return 7.5625 * (t -= 2.25 / 2.75) * t + 0.9375;
    } else {
      return 7.5625 * (t -= 2.625 / 2.75) * t + 0.984375;
    }
  }

  /**
   * 约束值在指定范围内
   * 
   * @param value - 待约束的值
   * @param min - 最小值
   * @param max - 最大值
   * @returns 约束后的值
   */
  public static clamp(value: number, min: number, max: number): number {
    return Math.max(min, Math.min(max, value));
  }

  /**
   * 将值映射到新的范围
   * 
   * @param value - 原始值
   * @param fromMin - 原始范围最小值
   * @param fromMax - 原始范围最大值
   * @param toMin - 目标范围最小值
   * @param toMax - 目标范围最大值
   * @returns 映射后的值
   */
  public static map(value: number, fromMin: number, fromMax: number, toMin: number, toMax: number): number {
    const ratio: number = (value - fromMin) / (fromMax - fromMin);
    return toMin + ratio * (toMax - toMin);
  }
} 