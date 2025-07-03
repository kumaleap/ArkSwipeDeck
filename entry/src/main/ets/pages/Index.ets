/**
 * 滑动卡片示例页面
 *
 * 展示ArkSwipeDeck的最基本用法
 * 遵循ArkTS严格语法规范
 *
 * @since 1.0.0
 */

import hilog from '@ohos.hilog';
import {
  SwipeCardStack,
  SwipeDirection,
  type OnCardSwipedCallback,
  type OnLoadNextPageCallback
} from 'arkswipe-deck';

// 日志标签
const TAG: string = 'ArkSwipeDeck';

/**
 * 示例卡片数据类
 */
export class CardData {
  id?: string;
  title?: string;
  name?: string;
  age?: number;
}

@Entry
struct Index {
  @State private cards: CardData[] = [
    { id: '1', title: '第一张卡片', name: '张三', age: 25 },
    { id: '2', title: '第二张卡片', name: '李四', age: 28 },
    { id: '3', title: '第三张卡片', name: '王五', age: 30 },
    { id: '4', title: '第四张卡片', name: '赵六', age: 26 },
    { id: '5', title: '第五张卡片', name: '钱七', age: 32 }
  ];
  @State private nextCardId: number = 6; // 下一张卡片的ID
  @State private isLoading: boolean = false; // 是否正在加载

  build(): void {
    Column() {
      Text('ArkSwipeDeck 示例')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 20, bottom: 20 })

      SwipeCardStack({
        cardDataList: this.cards,
        eventHandler: {
          onCardSwiped: this.handleCardSwiped,
          onLoadNextPage: this.handleLoadNextPage
        },
        cardBuilder: this.buildCard,
        swipeConfig: {
          preloadThreshold: 2 // 剩余2张卡片时触发预加载
        }
      })
        .width('90%')
        .height(400)
        .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F0F0F0')
  }

  @Builder
  buildCard(cardData: CardData, index: number): void {
    Column() {
      Text(cardData.title ?? '默认标题')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ bottom: 10 })

      Text(`姓名: ${cardData.name ?? '未知'}`)
        .fontSize(16)
        .fontColor(Color.White)
        .margin({ bottom: 5 })
        
      Text(`年龄: ${cardData.age ?? 0}岁`)
        .fontSize(16)
        .fontColor(Color.White)
        .margin({ bottom: 10 })

      Text(`卡片编号: ${index + 1}`)
        .fontSize(14)
        .fontColor(Color.White)
        .opacity(0.8)

      Text('左滑不喜欢，右滑喜欢')
        .fontSize(12)
        .fontColor(Color.White)
        .opacity(0.6)
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .borderRadius(20)
    .justifyContent(FlexAlign.Center)
    .backgroundColor("#FF6B6B")
  }

  private handleCardSwiped: OnCardSwipedCallback = (direction: SwipeDirection, data: object, index: number): void => {
    // 类型断言：将object转换为CardData
    const cardData: CardData = data as CardData;
    
    hilog.debug(0x0000, TAG, '卡片 "%{public}s" 向 %{public}s 滑动', cardData.title ?? '未知', direction);

    // 可以在这里添加更多的交互逻辑
    if (direction === SwipeDirection.LEFT) {
      hilog.debug(0x0000, TAG, '用户不喜欢这张卡片');
    } else if (direction === SwipeDirection.RIGHT) {
      hilog.debug(0x0000, TAG, '用户喜欢这张卡片');
    }
  };
  
  private handleLoadNextPage: OnLoadNextPageCallback = (currentIndex: number, remainingCount: number): void => {
    hilog.debug(0x0000, TAG, '触发预加载: currentIndex=%{public}d, remainingCount=%{public}d', currentIndex,
      remainingCount);

    // 避免重复加载
    if (this.isLoading) {
      hilog.debug(0x0000, TAG, '正在加载中，跳过本次预加载');
      return;
    }

    this.loadMoreCards();
  };

  /**
   * 模拟加载更多卡片
   */
  private loadMoreCards(): void {
    this.isLoading = true;
    hilog.debug(0x0000, TAG, '开始加载更多卡片...');

    // 模拟网络请求延迟
    setTimeout((): void => {
      const newCards: CardData[] = this.generateNewCards(3); // 每次加载3张新卡片

      // ArkTS规范：手动循环替代扩展运算符
      for (let i = 0; i < newCards.length; i++) {
        this.cards.push(newCards[i]);
      }

      hilog.debug(0x0000, TAG, '成功加载了%{public}d张新卡片，总数: %{public}d', newCards.length, this.cards.length);

      this.isLoading = false;
    }, 1000); // 模拟1秒的加载时间
  }

  /**
   * 生成新的卡片数据
   */
  private generateNewCards(count: number): CardData[] {
    const newCards: CardData[] = [];
    const names: string[] = ['新用户A', '新用户B', '新用户C', '新用户D', '新用户E'];

    for (let i = 0; i < count; i++) {
      const cardData: CardData = {
        id: this.nextCardId.toString(),
        title: `第${this.nextCardId}张卡片`,
        name: names[i % names.length],
        age: 20 + Math.floor(Math.random() * 15) // 20-35岁随机年龄
      };
      newCards.push(cardData);
      this.nextCardId++;
    }

    return newCards;
  }
}