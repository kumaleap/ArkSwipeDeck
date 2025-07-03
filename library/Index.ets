/**
 * ArkSwipeDeck 滑动卡片组件库
 * 
 * 对外导出的主要API
 * 遵循ArkTS严格语法规范
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

// 导出主要组件
export { SwipeCardStack } from './src/main/ets/components/SwipeCardStack';

// 导出类型定义
export type {
  SwipeConfig,
  SwipeEventHandler,
  OnCardSwipedCallback,
  OnCardClickedCallback,
  OnStackNearEmptyCallback,
  OnStackEmptyCallback,
  OnLoadNextPageCallback,
  AnimationParams,
  GestureState
} from './src/main/ets/types/SwipeCardTypes';

// 导出枚举
export { SwipeDirection, CardState } from './src/main/ets/types/SwipeCardTypes';

// 导出工具类
export { AnimationUtils } from './src/main/ets/utils/AnimationUtils';
export { GestureUtils } from './src/main/ets/utils/GestureUtils';

// 导出常量和配置
export {
  mergeSwipeConfig,
  LayoutConstants,
  AnimationConstants,
  GestureConstants
} from './src/main/ets/constants/DefaultConfigs';
