/**
 * 滑动卡片示例页面
 * 
 * 展示ArkSwipeDeck的最基本用法
 * 
 * @since 1.0.0
 */

import hilog from '@ohos.hilog';
import { SwipeCardStack, type CardData, SwipeDirection, type OnCardSwipedCallback, } from 'arkswipe-deck';

// 日志标签
const TAG: string = 'ArkSwipeDeck';

@Entry
struct Index {
  @State private cards: CardData[] = [
    { id: '1', title: '第一张卡片' },
    { id: '2', title: '第二张卡片' },
    { id: '3', title: '第三张卡片' },
    { id: '4', title: '第四张卡片' },
    { id: '5', title: '第五张卡片' }
  ];
  @State private colors: string[] = [
    '#FF6B6B', '#4ECDC4', '#45B7D1',
    '#96CEB4', '#FFEAA7', '#DDA0DD'
  ];

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
          onCardSwiped: this.handleCardSwiped
        },
        cardBuilder: this.buildCard
      })
        .width('90%')
        .height(400)
        .margin({ bottom: 20 })

      Text('← 向左滑动表示不喜欢 | 向右滑动表示喜欢 →')
        .fontSize(12)
        .fontColor('#999999')
        .textAlign(TextAlign.Center)
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F0F0F0')
  }

  @Builder
  buildCard(data: CardData, index: number): void {
    Column() {
      Text(data.title as string)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
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
    .justifyContent(FlexAlign.Center)
    .backgroundColor("#96CEB4")
  }

    private handleCardSwiped: OnCardSwipedCallback = (direction: SwipeDirection, data: CardData, index: number): void => {
    hilog.debug(0x0000, TAG, '卡片 "%{public}s" 向 %{public}s 滑动', data.title as string, direction);
    
    // 可以在这里添加更多的交互逻辑
    if (direction === SwipeDirection.LEFT) {
      hilog.debug(0x0000, TAG, '用户不喜欢这张卡片');
    } else if (direction === SwipeDirection.RIGHT) {
      hilog.debug(0x0000, TAG, '用户喜欢这张卡片');
    }
  }
}
