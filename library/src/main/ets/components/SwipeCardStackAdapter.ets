/**
 * SwipeCardStack 适配器类
 * 
 * 由于ArkTS中struct不能实现接口，使用适配器模式连接组件和接口
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import type { CardData, SwipeCardStackConfigUpdate } from '../types/SwipeCardTypes';
import { SwipeDirection } from '../types/SwipeCardTypes';
import type { SwipeCardStackComponent } from './SwipeCardStackComponent';

/**
 * SwipeCardStack 适配器实现类
 * 连接struct组件和接口定义，符合arktsV2.mdc规范
 */
export class SwipeCardStackAdapter implements SwipeCardStackComponent {
  private getTopCardCallback: () => CardData | null;
  private getVisibleCardsCallback: () => CardData[];
  private performSwipeCallback: (card: CardData, direction: SwipeDirection, animated: boolean) => Promise<void>;
  private resetCardPositionCallback: (card: CardData, animated: boolean) => Promise<void>;
  private updateConfigCallback: (config: SwipeCardStackConfigUpdate) => void;
  private reloadCallback: (cards: CardData[]) => void;

  constructor(
    getTopCardCallback: () => CardData | null,
    getVisibleCardsCallback: () => CardData[],
    performSwipeCallback: (card: CardData, direction: SwipeDirection, animated: boolean) => Promise<void>,
    resetCardPositionCallback: (card: CardData, animated: boolean) => Promise<void>,
    updateConfigCallback: (config: SwipeCardStackConfigUpdate) => void,
    reloadCallback: (cards: CardData[]) => void
  ) {
    this.getTopCardCallback = getTopCardCallback;
    this.getVisibleCardsCallback = getVisibleCardsCallback;
    this.performSwipeCallback = performSwipeCallback;
    this.resetCardPositionCallback = resetCardPositionCallback;
    this.updateConfigCallback = updateConfigCallback;
    this.reloadCallback = reloadCallback;
  }

  /**
   * 获取顶部卡片
   */
  getInternalTopCard(): CardData | null {
    return this.getTopCardCallback();
  }

  /**
   * 获取可见卡片列表
   */
  getInternalVisibleCards(): CardData[] {
    return this.getVisibleCardsCallback();
  }

  /**
   * 执行卡片滑动
   */
  async performInternalSwipe(card: CardData, direction: SwipeDirection, animated: boolean): Promise<void> {
    await this.performSwipeCallback(card, direction, animated);
  }

  /**
   * 重置卡片位置
   */
  async resetInternalCardPosition(card: CardData, animated: boolean): Promise<void> {
    await this.resetCardPositionCallback(card, animated);
  }

  /**
   * 更新配置
   */
  updateInternalConfig(config: SwipeCardStackConfigUpdate): void {
    this.updateConfigCallback(config);
  }

  /**
   * 重新加载数据
   */
  reloadInternal(cards: CardData[]): void {
    this.reloadCallback(cards);
  }
} 