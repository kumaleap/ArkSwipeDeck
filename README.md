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
- 详细的文档和示例

### 📱 Entry 模块  
- 位置：`entry/`
- 最佳实践示例应用
- 展示组件的所有功能
- 可直接运行的演示

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

⭐ 如果这个项目对你有帮助，请给个Star支持一下！ 

# 鸿蒙ArkTS开发规范 (严格版)

> 基于华为官方ArkTS编码风格指南、高性能编程规范及TypeScript迁移指南，严格遵循ArkTS语法限制

## 1. ArkTS 严格语法限制

### 1.1 禁用的JavaScript/TypeScript特性

**❌ 绝对禁止使用：**

```typescript
// ❌ 解构赋值 (arkts-no-destruct-decls)
const { name, age } = user;
let [first, second] = array;

// ❌ 扩展运算符用于对象 (arkts-no-spread)
const merged = { ...defaultOptions, ...userOptions };
const newArray = [...oldArray];

// ❌ 动态类型和any
let data: any = getValue();

// ❌ 枚举
enum Direction {
  UP = 'up',
  DOWN = 'down'
}

// ❌ as const 断言 (arkts-no-as-const)
const config = {
  maxCount: 10,
  enabled: true
} as const;

// ❌ 命名空间
namespace Utils {
  export function helper() {}
}

// ❌ 高级类型操作
type Partial<T> = { [P in keyof T]?: T[P] };

// ❌ ForEach回调函数的void类型注解 (arkts-foreach-callback-void)
ForEach(dataList, (item: DataType): void => {
  Text(item.name)
});

// ❌ 类内部定义interface (arkts-no-interface-in-class)
class MyClass {
  interface InternalInterface {  // 错误：interface必须在模块顶层
    prop: string;
  }
}
```

**✅ 必须替换为：**

```typescript
// ✅ 显式赋值替代解构
const name: string = user.name;
const age: number = user.age;

// ✅ 手动对象合并替代扩展运算符
function mergeOptions(defaults: Options, user: Options): Required<Options> {
  const merged: Required<Options> = {
    prop1: defaults.prop1,
    prop2: defaults.prop2
  };
  if (user.prop1 !== undefined) {
    merged.prop1 = user.prop1;
  }
  if (user.prop2 !== undefined) {
    merged.prop2 = user.prop2;
  }
  return merged;
}

// ✅ 循环替代数组扩展运算符
const newArray: T[] = [];
for (let i = 0; i < oldArray.length; i++) {
  newArray.push(oldArray[i]);
}

// ✅ const enum替代普通枚举
export const enum Direction {
  UP = 'up',
  DOWN = 'down'
}

// ✅ ES模块替代命名空间
export class Utils {
  static helper(): void {}
}

// ✅ 明确类型替代动态类型
interface UserData {
  name: string;
  age: number;
}
const data: UserData = getValue();

// ✅ ForEach回调函数不使用void类型注解
ForEach(dataList, (item: DataType) => {
  Text(item.name)
});

// ✅ ForEach的keyGenerator可以有返回类型注解
ForEach(
  dataList, 
  (item: DataType) => {
    Text(item.name)
  },
  (item: DataType): string => item.id  // keyGenerator可以有返回类型
);

// ❌ @Builder方法内部使用this调用其他@Builder方法 (arkts-builder-this-call)
@Builder
private buildParent(): void {
  Column() {
    this.buildChild()  // 错误：@Builder内部不能用this调用其他@Builder
  }
}

// ✅ @Builder方法内部直接调用其他@Builder方法
@Builder
private buildParent(): void {
  Column() {
    buildChild()  // 正确：@Builder内部直接调用
  }
}

// ❌ @Builder方法作为参数传递时this上下文丢失 (arkts-this-context-loss)
@Component
struct ParentComponent {
  @Builder
  private buildCard(data: Data): void {
    Text(this.getTitle(data))  // this在传递后会丢失
  }
  
  build() {
    ChildComponent({
      cardBuilder: this.buildCard  // 错误：this上下文丢失
    })
  }
}

// ✅ 使用箭头函数包装保持this上下文
@Component
struct ParentComponent {
  @Builder
  private buildCard(data: Data): void {
    Text(this.getTitle(data))
  }
  
  build() {
    ChildComponent({
      cardBuilder: (data: Data) => {
        this.buildCard(data);  // 正确：箭头函数保持this上下文
      }
    })
  }
}

// ✅ interface定义在模块顶层
export interface InternalInterface {
  prop: string;
}

export class MyClass {
  // 类内部只能使用interface，不能定义interface
}

// ❌ 错误：静态方法中使用this
public static createAnimateParam(config: AnimationConfig): AnimateParam {
  return {
    curve: this.createSpringCurve(config), // ArkTS编译错误
  };
}

// ✅ 正确：静态方法中使用类名
public static createAnimateParam(config: AnimationConfig): AnimateParam {
  return {
    curve: AnimationUtils.createSpringCurve(config), // 符合ArkTS规范
  };
}
```

### 1.2 ArkUI组件特有语法规范

**❌ ArkUI组件语法错误：**

```typescript
// ❌ ForEach回调函数使用void返回类型
ForEach(this.dataList, (item: DataType): void => {
  Text(item.name)  // 编译错误：is not callable
});

// ❌ @Builder方法中的非UI语法
@Builder
private buildItem(): void {
  const localVar = 'test';  // 错误：@Builder中不能声明变量
  Text(localVar)
}

// ❌ overlay直接传入组件属性链
Circle()
  .overlay(
    Text('content').fontSize(20)  // 错误：不能直接传入组件属性链
  )
```

**✅ ArkUI组件正确语法：**

```typescript
// ✅ ForEach回调函数不使用返回类型注解
ForEach(this.dataList, (item: DataType) => {
  Text(item.name)
});

// ✅ @Builder方法中只使用UI组件
@Builder
private buildItem(): void {
  Text(this.getItemName())  // 正确：调用方法获取数据
}

// ✅ overlay使用Builder函数
Circle()
  .overlay(() => {
    Text('content')
      .fontSize(20)
  })

// ✅ 或使用Stack布局
Stack() {
  Circle()
  Text('content')
    .fontSize(20)
}
``` 