# ArkSwipeDeck - 鸿蒙卡片堆叠滑动组件

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-4.0%2B-orange.svg)](https://developer.harmonyos.com/)
[![ArkTS](https://img.shields.io/badge/ArkTS-Latest-green.svg)](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkts-get-started-0000001504769321)

> 一个纯净的鸿蒙ArkTS卡片堆叠滑动容器组件，提供Tinder风格的滑动交互、流畅动画和完整的事件回调系统。

## 🎯 项目概述

本项目包含两个主要部分：

### 📚 Library 模块
- 位置：`library/` 
- 核心的SwipeCardStack组件实现
- 完整的API和工具类
- 详细的文档和示例 - [查看文档](./library/README.md)

### 📱 Entry 模块  
- 位置：`entry/`
- 最佳实践示例应用
- 展示组件的所有功能
- 可直接运行的演示

### 🎨 快速预览

```typescript
// 最简单的使用方式
SwipeCardStack({
  cardDataList: this.cards,
  cardBuilder: this.buildCard
})

@Builder
buildCard(data: CardData, index: number) {
  Text(data.title)
    .width('100%')
    .height('100%')
    .textAlign(TextAlign.Center)
    .backgroundColor(Color.Blue)
    .borderRadius(16)
}
```

## ✨ 核心特性

- 🎯 **纯容器设计** - 不预设任何UI样式，完全可定制
- 🎨 **Builder模式** - 通过ArkTS Builder完全自定义卡片内容
- 🎭 **Tinder风格** - 经典的卡片堆叠滑动交互
- ⚡ **流畅动画** - 支持弹簧、摩擦、缓动等多种动画类型
- 🎮 **丰富手势** - 支持拖拽、滑动、回弹等手势交互
- 📡 **事件系统** - 完整的事件回调支持
- 🎛️ **程序化控制** - 提供API进行程序化操作
- 🔄 **循环模式** - 支持无限循环模式
- 📱 **响应式设计** - 自适应不同屏幕尺寸
- 🚀 **高性能** - 优化的渲染和内存管理

## 🚀 快速开始

### 运行示例

1. 使用DevEco Studio打开项目
2. 选择entry模块作为运行目标
3. 点击运行按钮

### 在你的项目中使用

```typescript
import { SwipeCardStack } from 'library';
import type { CardData, SwipeEvent } from 'library';
import { SwipeDirection } from 'library';

@Component
struct MyComponent {
  @State cardList: CardData[] = [
    { id: '1', index: 0, visible: true, data: { title: '卡片1' } },
    { id: '2', index: 1, visible: true, data: { title: '卡片2' } }
  ];

  build() {
    SwipeCardStack({
      cardDataList: this.cardList,
      cardContentBuilder: this.buildCard,
      callbacks: {
        onCardSwiped: (event: SwipeEvent) => {
          console.log(`卡片${event.direction === SwipeDirection.LEFT ? '拒绝' : '喜欢'}`);
        }
      }
    })
  }

  @Builder
  buildCard(card: CardData, index: number) {
    Text(card.data?.title)
      .width('100%')
      .height('100%')
      .textAlign(TextAlign.Center)
      .backgroundColor(Color.White)
      .borderRadius(12)
  }
}
```

## 📖 详细文档

详细的API文档请查看：[library/README.md](library/README.md)

## 🏗️ 项目结构

```
ArkSwipeDeck/
├── entry/                          # 示例应用
│   └── src/main/ets/pages/
│       └── Index.ets               # 最佳示例页面
├── library/                        # 核心组件库
│   ├── Index.ets                   # 主入口
│   ├── README.md                   # 详细文档
│   ├── src/main/ets/
│   │   ├── components/             # 核心组件
│   │   │   └── SwipeCardStack.ets
│   │   ├── types/                  # 类型定义
│   │   ├── utils/                  # 工具类
│   │   └── constants/              # 常量配置
│   └── examples/
│       └── BasicUsage.ets          # 使用示例
└── README.md                       # 项目说明
```

## 🎨 示例展示

entry模块中的Index.ets展示了组件的完整功能：

- ✅ 自定义卡片内容（头像、姓名、年龄、描述、兴趣标签）
- ✅ 实时拖拽反馈和进度显示
- ✅ 完整的事件处理（喜欢/拒绝统计）
- ✅ 自动重新加载机制
- ✅ 精美的UI设计和动画效果

## 🔧 开发环境

- HarmonyOS API 9+
- DevEco Studio 4.0+
- ArkTS支持

## 📄 开源协议

本项目采用 [Apache License 2.0](LICENSE) 开源协议。

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📞 支持

如有问题，请通过以下方式联系：

- 📧 提交Issue
- 💬 项目讨论区

---

⭐ 如果这个项目对你有帮助，请给个Star支持一下