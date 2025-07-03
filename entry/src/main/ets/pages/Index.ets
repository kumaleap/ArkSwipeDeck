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
} from 'ark-swipe-deck';

// 日志标签
const TAG: string = 'ArkSwipeDeck';

export class UserInfo {
  src?: string;
}

@Entry
struct Index {
  private readonly imageList: string[] = [
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?w=800&h=1422&fit=crop',
    'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=800&h=1422&fit=crop',
    'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=800&h=1422&fit=crop',
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=800&h=1422&fit=crop',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800&h=1422&fit=crop',
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?w=800&h=1422&fit=crop',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=1422&fit=crop',
    'https://fastly.picsum.photos/id/314/800/1422.jpg?hmac=hCc3DkCNPtN0tJLo2PS7PlrAnnJ89yhoRT9kwIpdV6c',
    'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=800&h=1422&fit=crop',
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800&h=1422&fit=crop'
  ];
  @State private isLoading: boolean = false; // 是否正在加载
  @State private cards: UserInfo[] = [];

  aboutToAppear(): void {
    this.loadMoreCards(10)
  }

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
          scaleRatio: 0.8,
          preloadThreshold: 3,
        }
      })
        .width('70%')
        .height(400)
        .margin({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F0F0F0')
  }

  @Builder
  buildCard(data: UserInfo, index: number): void {
    Stack() {
      Image(data?.src ?? "")
        .width('100%')
        .height('100%')
        .borderRadius(20) // 用户自定义圆角
        .flexShrink(1)
      Text(`${index}`)
        .width("100%")
        .height(40)
        .fontSize(16)
        .fontColor("#333")
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .borderRadius({ bottomLeft: 20, bottomRight: 20 })
        .backgroundColor(Color.White)
    }
    .alignContent(Alignment.Bottom)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .borderRadius(20) // 用户自定义圆角
    .shadow({
      // 用户自定义阴影
      radius: 20,
      color: Color.Gray,
      offsetX: 2,
      offsetY: 2
    })
  }

  private handleCardSwiped: OnCardSwipedCallback = (direction: SwipeDirection, data: object, index: number): void => {
    // 可以在这里添加更多的交互逻辑
    hilog.debug(0x0000, TAG, '用户滑动了卡片: direction=%{public}d, data=%{public}s, index=%{public}d', direction, data,
      index)
  };
  private handleLoadNextPage: OnLoadNextPageCallback = (currentIndex: number, remainingCount: number): void => {
    hilog.debug(0x0000, TAG, '触发预加载: currentIndex=%{public}d, remainingCount=%{public}d', currentIndex,
      remainingCount);
    // 避免重复加载
    if (this.isLoading) {
      hilog.debug(0x0000, TAG, '正在加载中，跳过本次预加载');
      return;
    }

    this.loadMoreCards(10);
  };

  private loadMoreCards(count: number): void {
    this.isLoading = true;
    setTimeout((): void => {
      const newCards: object[] = [];
      for (let i = 0; i < count; i++) {
        //随机从图片列表中随机获取一张图片
        const imageUrl: string = this.imageList[i];
        newCards.push({ src: imageUrl } as UserInfo);
      }
      for (let i = 0; i < newCards.length; i++) {
        this.cards.push(newCards[i]);
      }
      this.isLoading = false;
    }, 800);
  }
}