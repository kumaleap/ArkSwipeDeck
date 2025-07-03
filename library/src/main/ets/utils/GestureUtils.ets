/**
 * 手势工具类
 * 
 * 提供滑动卡片组件的手势识别和处理功能
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import hilog from '@ohos.hilog';
import type { GestureState } from '../types/SwipeCardTypes';
import { SwipeDirection } from '../types/SwipeCardTypes';
import { GestureConstants } from '../constants/DefaultConfigs';

// 日志标签
const TAG: string = 'ArkSwipeDeck';

/**
 * 手势工具类
 */
export class GestureUtils {
  /**
   * 创建初始手势状态
   * @param startX - 起始X坐标
   * @param startY - 起始Y坐标
   * @returns 初始手势状态
   */
  static createInitialGestureState(startX: number, startY: number): GestureState {
    return {
      startX: startX,
      startY: startY,
      currentX: startX,
      currentY: startY,
      deltaX: 0,
      deltaY: 0,
      velocity: 0,
      isActive: true
    };
  }

  /**
   * 更新手势状态
   * @param state - 当前手势状态
   * @param currentX - 当前X坐标
   * @param currentY - 当前Y坐标
   * @returns 更新后的手势状态
   */
  static updateGestureState(
    state: GestureState,
    currentX: number,
    currentY: number
  ): GestureState {
    return {
      startX: state.startX,
      startY: state.startY,
      currentX: currentX,
      currentY: currentY,
      deltaX: currentX - state.startX,
      deltaY: currentY - state.startY,
      velocity: GestureUtils.calculateVelocity(state, currentX, currentY),
      isActive: state.isActive
    };
  }

  /**
   * 计算手势速度
   * @param state - 当前手势状态
   * @param currentX - 当前X坐标
   * @param currentY - 当前Y坐标
   * @returns 速度值
   */
  static calculateVelocity(
    state: GestureState,
    currentX: number,
    currentY: number
  ): number {
    const deltaX: number = currentX - state.currentX;
    const deltaY: number = currentY - state.currentY;
    return Math.sqrt(deltaX * deltaX + deltaY * deltaY);
  }

  /**
   * 判断是否应该触发滑动
   * @param state - 手势状态
   * @param threshold - 滑动阈值
   * @returns 是否应该滑动
   */
  static shouldTriggerSwipe(state: GestureState, threshold: number): boolean {
    const distance: number = Math.sqrt(state.deltaX * state.deltaX + state.deltaY * state.deltaY);
    return distance >= threshold;
  }

  /**
   * 判断滑动方向
   * @param state - 手势状态
   * @returns 滑动方向
   */
  static getSwipeDirection(state: GestureState): SwipeDirection {
    const absX: number = Math.abs(state.deltaX);
    const absY: number = Math.abs(state.deltaY);

    if (absX > absY) {
      return state.deltaX > 0 ? SwipeDirection.RIGHT : SwipeDirection.LEFT;
    } else {
      return state.deltaY > 0 ? SwipeDirection.DOWN : SwipeDirection.UP;
    }
  }

  /**
   * 判断是否为有效拖拽
   * @param state - 手势状态
   * @returns 是否为有效拖拽
   */
  static isValidDrag(state: GestureState): boolean {
    const distance: number = Math.sqrt(state.deltaX * state.deltaX + state.deltaY * state.deltaY);
    return distance >= GestureConstants.MIN_DRAG_DISTANCE;
  }

  /**
   * 创建拖拽手势处理器
   * @param onStart - 拖拽开始回调
   * @param onUpdate - 拖拽更新回调
   * @param onEnd - 拖拽结束回调
   * @returns 拖拽手势处理器
   */
  static createDragGesture(
    onStart: (x: number, y: number) => void,
    onUpdate: (state: GestureState) => void,
    onEnd: (state: GestureState) => void
  ): PanGestureInterface {
    let gestureState: GestureState | null = null;

    hilog.debug(0x0000, TAG, 'GestureUtils.createDragGesture: 创建拖拽手势');

    return PanGesture({ 
      fingers: 1, 
      direction: PanDirection.All, 
      distance: 1  // 设置最小触发距离为1px
    })
      .onActionStart((event: GestureEvent): void => {
        hilog.debug(0x0000, TAG, 'PanGesture.onActionStart: 拖拽开始');
        const x: number = event.fingerList[0].globalX;
        const y: number = event.fingerList[0].globalY;
        gestureState = GestureUtils.createInitialGestureState(x, y);
        onStart(x, y);
      })
      .onActionUpdate((event: GestureEvent): void => {
        if (gestureState === null) {
          hilog.debug(0x0000, TAG, 'PanGesture.onActionUpdate: gestureState为null');
          return;
        }

        const x: number = event.fingerList[0].globalX;
        const y: number = event.fingerList[0].globalY;
        gestureState = GestureUtils.updateGestureState(gestureState, x, y);
        hilog.debug(0x0000, TAG, 'PanGesture.onActionUpdate: deltaX=%{public}f, deltaY=%{public}f', 
          gestureState.deltaX, gestureState.deltaY);
        onUpdate(gestureState);
      })
      .onActionEnd((event: GestureEvent): void => {
        if (gestureState === null) {
          hilog.debug(0x0000, TAG, 'PanGesture.onActionEnd: gestureState为null');
          return;
        }

        const x: number = event.fingerList[0].globalX;
        const y: number = event.fingerList[0].globalY;
        gestureState = GestureUtils.updateGestureState(gestureState, x, y);
        gestureState.isActive = false;
        hilog.debug(0x0000, TAG, 'PanGesture.onActionEnd: 最终deltaX=%{public}f, deltaY=%{public}f', 
          gestureState.deltaX, gestureState.deltaY);
        onEnd(gestureState);
        gestureState = null;
      });
  }

  /**
   * 创建点击手势处理器
   * @param onClick - 点击回调
   * @returns 点击手势处理器
   */
  static createTapGesture(onClick: () => void): TapGestureInterface {
    hilog.debug(0x0000, TAG, 'GestureUtils.createTapGesture: 创建点击手势');
    return TapGesture({ count: 1 })
      .onAction((): void => {
        hilog.debug(0x0000, TAG, 'TapGesture.onAction: 点击触发');
        onClick();
      });
  }

  /**
   * 计算滑动进度
   * @param deltaX - X轴位移
   * @param cardWidth - 卡片宽度
   * @returns 滑动进度（0-1）
   */
  static calculateSwipeProgress(deltaX: number, cardWidth: number): number {
    const progress: number = Math.abs(deltaX) / cardWidth;
    return Math.min(progress, 1);
  }

  /**
   * 计算阻力系数
   * @param distance - 移动距离
   * @param maxDistance - 最大距离
   * @returns 阻力系数（0-1）
   */
  static calculateResistance(distance: number, maxDistance: number): number {
    if (distance <= 0) {
      return 1;
    }

    const ratio: number = distance / maxDistance;
    return Math.max(0.1, 1 - ratio * 0.5);
  }

  /**
   * 应用阻力效果
   * @param delta - 原始位移
   * @param resistance - 阻力系数
   * @returns 应用阻力后的位移
   */
  static applyResistance(delta: number, resistance: number): number {
    return delta * resistance;
  }

  /**
   * 限制拖拽范围
   * @param delta - 位移
   * @param maxDistance - 最大距离
   * @returns 限制后的位移
   */
  static clampDragDistance(delta: number, maxDistance: number): number {
    return Math.max(-maxDistance, Math.min(maxDistance, delta));
  }

  /**
   * 计算弹性效果
   * @param progress - 进度（0-1）
   * @param elasticity - 弹性系数
   * @returns 弹性效果值
   */
  static calculateElasticity(progress: number, elasticity: number = 0.3): number {
    if (progress <= 1) {
      return progress;
    }

    const overshoot: number = progress - 1;
    return 1 + overshoot * elasticity;
  }
} 