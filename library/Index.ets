/**
 * ArkSwipeDeck 卡片堆叠滑动容器库
 * 
 * 一个纯净的鸿蒙ArkTS卡片堆叠滑动容器组件，提供Tinder风格的滑动交互、
 * 流畅动画和完整的事件回调系统。专注于提供容器能力，所有卡片内容
 * 完全由开发者通过Builder自定义。
 * 
 * @version 1.0.0
 * @author ArkSwipeDeck Contributors
 * @license Apache-2.0
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

// 核心组件导出
export { SwipeCardStack } from './src/main/ets/components/SwipeCardStack';
export { SwipeCardStackControllerImpl, SwipeCardStackRefImpl } from './src/main/ets/components/SwipeCardStackControllerImpl';
export { SwipeCardStackAdapter } from './src/main/ets/components/SwipeCardStackAdapter';
export type { SwipeCardStackRef } from './src/main/ets/components/SwipeCardStackControllerImpl';
export type { SwipeCardStackComponent } from './src/main/ets/components/SwipeCardStackComponent';

// 类型定义导出
export {
  SwipeDirection,
  AnimationType,
  CardState
} from './src/main/ets/types/SwipeCardTypes';

export type {
  CardData,
  CardDataPrimitiveValue,
  SwipeEvent,
  Position,
  ContainerSize,
  AnimationConfig,
  SpringConfig,
  FrictionConfig,
  StackConfig,
  SwipeConfig,
  SwipeCardStackConfig,
  SwipeCardStackConfigUpdate,
  SwipeCardStackCallbacks,
  SwipeCardStackController
} from './src/main/ets/types/SwipeCardTypes';

// 工具类导出
export { AnimationUtils } from './src/main/ets/utils/AnimationUtils';
export { GestureUtils } from './src/main/ets/utils/GestureUtils';
export type { GestureData, VelocityData } from './src/main/ets/utils/GestureUtils';

// 默认配置导出
export {
  DEFAULT_STACK_CONFIG,
  DEFAULT_SWIPE_CONFIG,
  DEFAULT_ANIMATION_CONFIG,
  DEFAULT_SWIPE_CARD_STACK_CONFIG,
  PERFORMANCE_CONSTANTS,
  GESTURE_CONSTANTS,
  ANIMATION_CONSTANTS
} from './src/main/ets/constants/DefaultConfigs';
