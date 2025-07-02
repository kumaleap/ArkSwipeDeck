/**
 * SwipeCardStackController 实现类
 * 
 * 提供卡片堆叠滑动容器的程序化控制能力
 * 
 * @since 1.0.0
 * @syscap SystemCapability.ArkUI.ArkUI.Full
 */

import type { 
  SwipeCardStackController, 
  CardData, 
  SwipeCardStackConfigUpdate 
} from '../types/SwipeCardTypes';
import { SwipeDirection } from '../types/SwipeCardTypes';
import type { SwipeCardStackComponent } from './SwipeCardStackComponent';

/**
 * SwipeCardStack 组件引用接口
 * 用于实现类访问组件内部方法
 */
export interface SwipeCardStackRef {
  getTopCard(): CardData | null;
  getVisibleCards(): CardData[];
  performSwipe(card: CardData, direction: SwipeDirection, animated: boolean): Promise<void>;
  resetCardPosition(card: CardData, animated: boolean): Promise<void>;
  updateConfig(config: SwipeCardStackConfigUpdate): void;
  reload(cards: CardData[]): void;
}

/**
 * SwipeCardStackRef 实现类
 * 符合arktsV2.mdc规范：使用实现类而非对象字面量
 */
export class SwipeCardStackRefImpl implements SwipeCardStackRef {
  private readonly component: SwipeCardStackComponent;

  constructor(component: SwipeCardStackComponent) {
    this.component = component;
  }

  /**
   * 获取顶部卡片
   */
  getTopCard(): CardData | null {
    return this.component.getInternalTopCard();
  }

  /**
   * 获取可见卡片列表
   */
  getVisibleCards(): CardData[] {
    return this.component.getInternalVisibleCards();
  }

  /**
   * 执行卡片滑动
   */
  async performSwipe(card: CardData, direction: SwipeDirection, animated: boolean): Promise<void> {
    await this.component.performInternalSwipe(card, direction, animated);
  }

  /**
   * 重置卡片位置
   */
  async resetCardPosition(card: CardData, animated: boolean): Promise<void> {
    await this.component.resetInternalCardPosition(card, animated);
  }

  /**
   * 更新配置
   */
  updateConfig(config: SwipeCardStackConfigUpdate): void {
    this.component.updateInternalConfig(config);
  }

  /**
   * 重新加载数据
   */
  reload(cards: CardData[]): void {
    this.component.reloadInternal(cards);
  }
}

/**
 * SwipeCardStackController 实现类
 */
export class SwipeCardStackControllerImpl implements SwipeCardStackController {
  private readonly swipeStackRef: SwipeCardStackRef;

  constructor(swipeStackRef: SwipeCardStackRef) {
    this.swipeStackRef = swipeStackRef;
  }

  /**
   * 程序化触发左滑
   */
  async swipeLeft(animated: boolean = true): Promise<void> {
    const topCard: CardData | null = this.swipeStackRef.getTopCard();
    if (topCard) {
      await this.swipeStackRef.performSwipe(topCard, SwipeDirection.LEFT, animated);
    }
  }

  /**
   * 程序化触发右滑
   */
  async swipeRight(animated: boolean = true): Promise<void> {
    const topCard: CardData | null = this.swipeStackRef.getTopCard();
    if (topCard) {
      await this.swipeStackRef.performSwipe(topCard, SwipeDirection.RIGHT, animated);
    }
  }

  /**
   * 程序化触发上滑
   */
  async swipeUp(animated: boolean = true): Promise<void> {
    const topCard: CardData | null = this.swipeStackRef.getTopCard();
    if (topCard) {
      await this.swipeStackRef.performSwipe(topCard, SwipeDirection.UP, animated);
    }
  }

  /**
   * 程序化触发下滑
   */
  async swipeDown(animated: boolean = true): Promise<void> {
    const topCard: CardData | null = this.swipeStackRef.getTopCard();
    if (topCard) {
      await this.swipeStackRef.performSwipe(topCard, SwipeDirection.DOWN, animated);
    }
  }

  /**
   * 重置当前卡片位置
   */
  async resetCard(animated: boolean = true): Promise<void> {
    const topCard: CardData | null = this.swipeStackRef.getTopCard();
    if (topCard) {
      await this.swipeStackRef.resetCardPosition(topCard, animated);
    }
  }

  /**
   * 获取当前可见卡片
   */
  getVisibleCards(): CardData[] {
    return this.swipeStackRef.getVisibleCards();
  }

  /**
   * 获取顶部卡片
   */
  getTopCard(): CardData | null {
    return this.swipeStackRef.getTopCard();
  }

  /**
   * 更新配置
   */
  updateConfig(config: SwipeCardStackConfigUpdate): void {
    this.swipeStackRef.updateConfig(config);
  }

  /**
   * 重新加载数据
   */
  reload(cards: CardData[]): void {
    this.swipeStackRef.reload(cards);
  }
} 