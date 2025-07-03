/**
 * ArkSwipeDeck 滑动卡片库入口文件
 * 
 * 提供类似Tinder的滑动卡片交互组件
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

// 导出主要组件
export { SwipeCardStack } from './src/main/ets/components/SwipeCardStack';

// 导出类型定义
export type {
  CardData,
  SwipeConfig,
  CardInfo,
  AnimationParams,
  GestureState,
  OnCardSwipedCallback,
  OnCardClickedCallback,
  OnStackNearEmptyCallback,
  OnStackEmptyCallback,
  OnLoadNextPageCallback,
  SwipeEventHandler
} from './src/main/ets/types/SwipeCardTypes';

// 导出枚举
export {
  SwipeDirection,
  CardState
} from './src/main/ets/types/SwipeCardTypes';

// 导出常量配置
export {
  DEFAULT_SWIPE_CONFIG,
  AnimationConstants,
  GestureConstants,
  LayoutConstants,
  mergeSwipeConfig
} from './src/main/ets/constants/DefaultConfigs';

// 导出工具类
export { AnimationUtils } from './src/main/ets/utils/AnimationUtils';
export { GestureUtils } from './src/main/ets/utils/GestureUtils';
