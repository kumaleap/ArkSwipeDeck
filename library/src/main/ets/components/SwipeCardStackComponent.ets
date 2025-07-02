/**
 * SwipeCardStack 组件接口
 * 
 * 定义组件内部方法的访问接口，用于实现类调用
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import type { CardData, SwipeCardStackConfigUpdate } from '../types/SwipeCardTypes';
import { SwipeDirection } from '../types/SwipeCardTypes';

/**
 * SwipeCardStack 组件接口
 * 定义组件需要暴露给控制器的方法
 */
export interface SwipeCardStackComponent {
  /**
   * 获取顶部卡片
   */
  getInternalTopCard(): CardData | null;
  
  /**
   * 获取可见卡片列表
   */
  getInternalVisibleCards(): CardData[];
  
  /**
   * 执行卡片滑动
   */
  performInternalSwipe(card: CardData, direction: SwipeDirection, animated: boolean): Promise<void>;
  
  /**
   * 重置卡片位置
   */
  resetInternalCardPosition(card: CardData, animated: boolean): Promise<void>;
  
  /**
   * 更新配置
   */
  updateInternalConfig(config: SwipeCardStackConfigUpdate): void;
  
  /**
   * 重新加载数据
   */
  reloadInternal(cards: CardData[]): void;
} 