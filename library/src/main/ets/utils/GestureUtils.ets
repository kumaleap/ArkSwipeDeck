/**
 * 手势工具类
 *
 * 提供手势识别、方向判断和速度计算等工具函数
 *
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import type { Position, SwipeConfig, ContainerSize } from '../types/SwipeCardTypes';
import { SwipeDirection } from '../types/SwipeCardTypes';
import { GESTURE_CONSTANTS } from '../constants/DefaultConfigs';

/**
 * 手势数据接口
 */
export interface GestureData {
  /** 开始位置 */
  readonly startPosition: Position;

  /** 当前位置 */
  readonly currentPosition: Position;

  /** 开始时间戳 */
  readonly startTime: number;

  /** 当前时间戳 */
  readonly currentTime: number;
}

/**
 * 速度数据接口
 */
export interface VelocityData {
  /** X轴速度 */
  readonly velocityX: number;

  /** Y轴速度 */
  readonly velocityY: number;

  /** 总速度 */
  readonly velocity: number;
}

/**
 * 矩形区域接口
 */
export interface RectArea {
  readonly x: number;
  readonly y: number;
  readonly width: number;
  readonly height: number;
}

/**
 * 手势工具类
 */
export class GestureUtils {
  /**
   * 计算两点间距离
   *
   * @param point1 - 起始点
   * @param point2 - 结束点
   * @returns 距离值
   */
  public static calculateDistance(point1: Position, point2: Position): number {
    const deltaX: number = point2.x - point1.x;
    const deltaY: number = point2.y - point1.y;
    return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
  }

  /**
   * 计算移动向量
   *
   * @param start - 起始位置
   * @param current - 当前位置
   * @returns 移动向量
   */
  public static calculateDelta(start: Position, current: Position): Position {
    const delta: Position = {
      x: current.x - start.x,
      y: current.y - start.y
    };
    return delta;
  }

  /**
   * 判断滑动方向
   *
   * @param start - 起始位置
   * @param current - 当前位置
   * @returns 滑动方向
   */
  public static getSwipeDirection(start: Position, current: Position): SwipeDirection {
    const delta: Position = GestureUtils.calculateDelta(start, current);
    const absX: number = Math.abs(delta.x);
    const absY: number = Math.abs(delta.y);

    if (absX > absY) {
      return delta.x > 0 ? SwipeDirection.RIGHT : SwipeDirection.LEFT;
    } else {
      return delta.y > 0 ? SwipeDirection.DOWN : SwipeDirection.UP;
    }
  }

  /**
   * 计算滑动进度
   *
   * @param start - 起始位置
   * @param current - 当前位置
   * @param threshold - 阈值距离
   * @returns 滑动进度 (0-1)
   */
  public static calculateSwipeProgress(start: Position, current: Position, threshold: number): number {
    const distance: number = GestureUtils.calculateDistance(start, current);
    return Math.min(1, distance / threshold);
  }

  /**
   * 计算速度
   *
   * @param gestureData - 手势数据
   * @returns 速度数据
   */
  public static calculateVelocity(gestureData: GestureData): VelocityData {
    const delta: Position = GestureUtils.calculateDelta(gestureData.startPosition, gestureData.currentPosition);
    const timeDelta: number = gestureData.currentTime - gestureData.startTime;

    if (timeDelta === 0) {
      const zeroVelocity: VelocityData = {
        velocityX: 0,
        velocityY: 0,
        velocity: 0
      };
      return zeroVelocity;
    }

    const velocityX: number = delta.x / timeDelta * 1000; // px/s
    const velocityY: number = delta.y / timeDelta * 1000; // px/s
    const velocity: number = Math.sqrt(velocityX * velocityX + velocityY * velocityY);

    const velocityData: VelocityData = {
      velocityX,
      velocityY,
      velocity
    };
    return velocityData;
  }

  /**
   * 判断是否为有效滑动
   *
   * @param start - 起始位置
   * @param current - 当前位置
   * @param config - 滑动配置
   * @returns 是否为有效滑动
   */
  public static isValidSwipe(start: Position, current: Position, config: SwipeConfig): boolean {
    const distance: number = GestureUtils.calculateDistance(start, current);
    const direction: SwipeDirection = GestureUtils.getSwipeDirection(start, current);

    // 检查距离是否达到阈值
    if (distance < GESTURE_CONSTANTS.MIN_SWIPE_DISTANCE) {
      return false;
    }

    // 检查方向是否被允许
    return config.allowedDirections.includes(direction);
  }

  /**
   * 判断是否应该触发滑动
   *
   * @param gestureData - 手势数据
   * @param config - 滑动配置
   * @returns 是否应该触发滑动
   */
  public static shouldTriggerSwipe(gestureData: GestureData, config: SwipeConfig): boolean {
    const distance: number = GestureUtils.calculateDistance(gestureData.startPosition, gestureData.currentPosition);
    const velocity: VelocityData = GestureUtils.calculateVelocity(gestureData);

    // 距离阈值判断
    if (distance >= config.threshold) {
      return true;
    }

    // 速度阈值判断
    if (velocity.velocity >= config.velocityThreshold) {
      return true;
    }

    return false;
  }

  /**
   * 计算旋转角度
   *
   * @param start - 起始位置
   * @param current - 当前位置
   * @param maxRotation - 最大旋转角度
   * @param containerWidth - 容器宽度
   * @returns 旋转角度
   */
  public static calculateRotation(
    start: Position,
    current: Position,
    maxRotation: number,
    containerWidth: number
  ): number {
    const delta: Position = GestureUtils.calculateDelta(start, current);
    const progress: number = Math.abs(delta.x) / (containerWidth * 0.5);
    const clampedProgress: number = Math.min(1, progress);

    const rotation: number = clampedProgress * maxRotation;
    return delta.x > 0 ? rotation : -rotation;
  }

  /**
   * 计算透明度
   *
   * @param progress - 滑动进度
   * @param minOpacity - 最小透明度
   * @returns 透明度值
   */
  public static calculateOpacity(progress: number, minOpacity: number = 0.3): number {
    return Math.max(minOpacity, 1 - progress);
  }

  /**
   * 计算缩放比例
   *
   * @param progress - 滑动进度
   * @param minScale - 最小缩放比例
   * @returns 缩放比例
   */
  public static calculateScale(progress: number, minScale: number = 0.8): number {
    return Math.max(minScale, 1 - progress * 0.2);
  }

  /**
   * 判断点是否在矩形区域内
   *
   * @param point - 点坐标
   * @param rect - 矩形区域
   * @returns 是否在区域内
   */
  public static isPointInRect(point: Position, rect: RectArea): boolean {
    return point.x >= rect.x &&
      point.x <= rect.x + rect.width &&
      point.y >= rect.y &&
      point.y <= rect.y + rect.height;
  }

  /**
   * 计算边界检测
   *
   * @param position - 当前位置
   * @param containerSize - 容器尺寸
   * @param threshold - 边界阈值
   * @returns 是否触及边界
   */
  public static isBoundaryReached(
    position: Position,
    containerSize: ContainerSize,
    threshold: number = GESTURE_CONSTANTS.BOUNDARY_THRESHOLD
  ): boolean {
    const boundaryX: number = containerSize.width * threshold;
    const boundaryY: number = containerSize.height * threshold;

    return Math.abs(position.x) >= boundaryX || Math.abs(position.y) >= boundaryY;
  }
}