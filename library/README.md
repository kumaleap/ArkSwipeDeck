# ArkSwipeDeck - 鸿蒙滑动卡片库

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/kumaleap/ArkSwipeDeck)
[![HarmonyOS](https://img.shields.io/badge/HarmonyOS->=4.0.0-green.svg)](https://developer.harmonyos.com/)
[![License](https://img.shields.io/badge/license-Apache--2.0-brightgreen.svg)](LICENSE)

一个纯鸿蒙ArkTS滑动卡片堆叠容器组件，提供类似Tinder的滑动交互效果，具有流畅的动画和全面的事件回调。专注于容器功能，通过Builder模式提供完全可自定义的内容。

## ✨ 特性

- 🎯 **纯ArkTS实现** - 完全遵循鸿蒙开发规范，无第三方依赖
- 🎨 **高度可定制** - 通过Builder模式自定义卡片内容和样式
- 🚀 **流畅动画** - 基于鸿蒙原生动画系统，支持弹簧动画和自定义曲线
- 👆 **丰富手势** - 支持拖拽、快速滑动、点击等多种交互方式
- 📱 **响应式布局** - 自适应不同屏幕尺寸和方向
- 🔧 **灵活配置** - 丰富的配置选项满足各种使用场景
- 📚 **完整类型** - 提供完整的TypeScript类型定义

## 🚀 快速开始

### 安装

```bash
# 在你的模块目录下
ohpm install ark-swipe-deck
```

### 基础使用

```typescript
import {
  SwipeCardStack,
  type CardData,
  SwipeDirection,
  type OnCardSwipedCallback,
  type OnCardClickedCallback,
  type OnStackNearEmptyCallback,
  type OnStackEmptyCallback
} from 'ark-swipe-deck';

@Entry
@Component
struct MyPage {
  @State cardList: CardData[] = [
    { id: '1', title: '卡片1', content: '内容1' },
    { id: '2', title: '卡片2', content: '内容2' },
    { id: '3', title: '卡片3', content: '内容3' }
  ];

  private handleCardSwiped: OnCardSwipedCallback = (direction: SwipeDirection, data: CardData, index: number): void => {
    console.log(`卡片 ${data.title} 向 ${direction} 滑动`);
  }

  private handleCardClicked: OnCardClickedCallback = (data: CardData, index: number): void => {
    console.log(`点击了卡片: ${data.title}`);
  }

  private handleStackNearEmpty: OnStackNearEmptyCallback = (remainingCount: number): void => {
    console.log(`卡片栈即将为空，剩余: ${remainingCount}`);
  }

  private handleStackEmpty: OnStackEmptyCallback = (): void => {
    console.log('卡片栈已空');
  }

  build() {
    Column() {
      SwipeCardStack({
        cardDataList: this.cardList,
        onCardSwiped: this.handleCardSwiped,
        onCardClicked: this.handleCardClicked,
        onStackNearEmpty: this.handleStackNearEmpty,
        onStackEmpty: this.handleStackEmpty,
        cardBuilder: this.buildCard
      })
        .width('90%')
        .height(400)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F0F0F0')
  }

  @Builder
  buildCard(data: CardData, index: number) {
    Column() {
      Text(data.title)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
      
      Text(data.content)
        .fontSize(16)
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
}
```

## 📖 API 文档

### SwipeCardStack 组件

主要的滑动卡片堆叠组件。

#### 属性

| 属性名 | 类型 | 必需 | 默认值 | 描述 |
|--------|------|------|--------|------|
| `cardDataList` | `CardData[]` | ✅ | `[]` | 卡片数据列表 |
| `swipeConfig` | `SwipeConfig` | ❌ | `{}` | 滑动配置选项 |
| `onCardSwiped` | `OnCardSwipedCallback` | ❌ | `undefined` | 卡片滑动回调 |
| `onCardClicked` | `OnCardClickedCallback` | ❌ | `undefined` | 卡片点击回调 |
| `onStackNearEmpty` | `OnStackNearEmptyCallback` | ❌ | `undefined` | 卡片栈即将为空回调 |
| `onStackEmpty` | `OnStackEmptyCallback` | ❌ | `undefined` | 卡片栈为空回调 |
| `cardBuilder` | `@BuilderParam` | ❌ | `undefined` | 自定义卡片内容构建器 |

#### 公共方法

```typescript
// 程序化向左滑动
swipeLeft(): void

// 程序化向右滑动  
swipeRight(): void

// 重置卡片栈到初始状态
reset(): void

// 获取剩余卡片数量
getRemainingCount(): number
```

### 配置选项 (SwipeConfig)

```typescript
interface SwipeConfig {
  maxVisibleCards?: number;    // 最大可见卡片数 (默认: 4)
  minStackSize?: number;       // 触发栈即将为空的最小卡片数 (默认: 2)
  rotationAngle?: number;      // 卡片旋转角度 (默认: 15)
  scaleRatio?: number;         // 卡片缩放比例 (默认: 0.95)
  swipeThreshold?: number;     // 滑动触发阈值 (默认: 100)
  animationDuration?: number;  // 动画持续时间 (默认: 300)
  enableSpringBack?: boolean;  // 是否启用弹簧回弹 (默认: true)
  cardSpacing?: number;        // 卡片间距 (默认: 8)
}
```

### 回调函数类型

```typescript
// 卡片滑动回调
type OnCardSwipedCallback = (direction: SwipeDirection, data: CardData, index: number) => void;

// 卡片点击回调
type OnCardClickedCallback = (data: CardData, index: number) => void;

// 卡片栈即将为空回调
type OnStackNearEmptyCallback = (remainingCount: number) => void;

// 卡片栈为空回调
type OnStackEmptyCallback = () => void;
```

### 卡片数据 (CardData)

```typescript
interface CardData {
  id: string;              // 唯一标识符
  title?: string;          // 标题
  description?: string;    // 描述
  color?: string;          // 颜色
  likes?: number;          // 点赞数
  distance?: string;       // 距离
}
```

### 滑动方向 (SwipeDirection)

```typescript
enum SwipeDirection {
  LEFT = 'left',
  RIGHT = 'right',
  UP = 'up',
  DOWN = 'down'
}
```

## 🎨 高级用法

### 自定义配置

```typescript
const customConfig: SwipeConfig = {
  maxVisibleCards: 3,
  rotationAngle: 20,
  scaleRatio: 0.9,
  swipeThreshold: 150,
  animationDuration: 400,
  enableSpringBack: true,
  cardSpacing: 12
};

SwipeCardStack({
  cardDataList: this.cardList,
  swipeConfig: customConfig,
  onCardSwiped: this.handleCardSwiped,
  cardBuilder: this.buildCard
})
```

### 完整事件处理

```typescript
private handleCardSwiped: OnCardSwipedCallback = (direction: SwipeDirection, data: CardData, index: number): void => {
  switch (direction) {
    case SwipeDirection.LEFT:
      console.log('不喜欢:', data.title);
      break;
    case SwipeDirection.RIGHT:
      console.log('喜欢:', data.title);
      break;
  }
}

private handleCardClicked: OnCardClickedCallback = (data: CardData, index: number): void => {
  // 处理卡片点击
  this.showCardDetail(data);
}

private handleStackNearEmpty: OnStackNearEmptyCallback = (remainingCount: number): void => {
  // 加载更多数据
  this.loadMoreCards();
}

private handleStackEmpty: OnStackEmptyCallback = (): void => {
  // 显示空状态
  this.showEmptyState();
}
```

### 程序化控制

```typescript
// 获取组件引用
@State swipeCardRef: SwipeCardStack | null = null;

// 在按钮点击时控制滑动
Button("不喜欢")
  .onClick((): void => {
    this.swipeCardRef?.swipeLeft();
  })

Button("喜欢")  
  .onClick((): void => {
    this.swipeCardRef?.swipeRight();
  })

Button("重置")
  .onClick((): void => {
    this.swipeCardRef?.reset();
  })
```

## 🎯 性能优化

### 卡片内容优化

- 使用轻量级布局组件
- 避免在卡片中使用复杂的嵌套结构
- 合理使用图片缓存和懒加载

### 数据管理

- 实现虚拟滚动减少内存占用
- 在 `onStackNearEmpty` 中分批加载数据
- 及时清理已滑出的卡片数据

### 动画性能

- 使用默认动画参数以获得最佳性能
- 避免在动画过程中进行复杂计算
- 合理设置 `maxVisibleCards` 数量

## 🐛 故障排除

### 常见问题

**Q: 卡片不响应滑动手势？**
A: 检查卡片内容是否阻止了手势传播，确保没有其他手势处理器拦截事件。

**Q: 动画卡顿？**
A: 尝试降低 `maxVisibleCards` 数量，简化卡片内容，或调整动画参数。

**Q: 内存占用过高？**
A: 实现数据的动态加载和清理，避免一次性加载大量卡片数据。

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📄 许可证

本项目基于 [Apache-2.0](LICENSE) 许可证开源。

## 🔗 相关链接

- [HarmonyOS开发文档](https://developer.harmonyos.com/)
- [ArkTS语法指南](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkts-basic-syntax-overview-0000001531611153)
- [项目主页](https://github.com/kumaleap/ArkSwipeDeck) 