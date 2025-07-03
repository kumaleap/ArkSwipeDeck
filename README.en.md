# ArkSwipeDeck - HarmonyOS Card Stack Swipe Component

> This is the English version. For Chinese, see README.md.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-4.0%2B-orange.svg)](https://developer.harmonyos.com/)
[![ArkTS](https://img.shields.io/badge/ArkTS-Latest-green.svg)](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkts-get-started-0000001504769321)

> A pure ArkTS card stack swipe component for HarmonyOS, providing Tinder-style swipe interaction, smooth animation, and a complete event callback system.

---

## ✨ Features

- 🧩 **Pure Container Design**: No preset UI style, fully customizable
- 🏗️ **Builder Pattern**: Customize card content via ArkTS Builder
- 🎭 **Tinder-Style Interaction**: Classic card stack swipe experience
- ⚡ **Smooth Animation**: Supports spring, friction, easing, and more
- 🕹️ **Rich Gestures**: Drag, swipe, rebound, and more
- 🛰️ **Complete Event System**: Callbacks for swipe, click, stack empty, etc.
- 🔄 **Programmatic Control**: API for programmatic swipe, reset, etc.
- ♻️ **Infinite Loop Mode**: Supports infinite card stack loop
- 📱 **Responsive Design**: Adapts to different screen sizes
- 🚀 **High Performance**: Optimized rendering and memory management

---

## 🚀 Quick Start

### Run the Example

1. Open the project with DevEco Studio
2. Select the `entry` module as the run target
3. Click the run button to experience the full card swipe functionality

### Integrate into Your Project

1. Copy the `library/` directory into your ArkTS project
2. Import the core component in your page:

```typescript
import { SwipeCardStack } from '../library';
import type { UserInfo } from '../library/src/main/ets/types/SwipeCardTypes';

@Component
struct MyComponent {
  @State private cards: UserInfo[] = [
    { src: 'https://example.com/image1.jpg' },
    { src: 'https://example.com/image2.jpg' }
  ];

  build() {
    SwipeCardStack({
      cardDataList: this.cards,
      cardBuilder: this.buildCard
    })
  }

  @Builder
  buildCard(data: UserInfo, index: number) {
    Image(data.src ?? '')
      .width('100%')
      .height('100%')
      .borderRadius(20)
  }
}
```

---

## 📚 Detailed API Documentation

### SwipeCardStack Component Properties

| Property           | Type                        | Required | Default      | Description                |
|--------------------|-----------------------------|----------|--------------|----------------------------|
| cardDataList       | `object[]`                  | ✅       | `[]`         | Card data list             |
| swipeConfig        | `SwipeConfig`               | ❌       | `{}`         | Swipe configuration        |
| onCardSwiped       | `OnCardSwipedCallback`      | ❌       | `undefined`  | Card swipe callback        |
| onCardClicked      | `OnCardClickedCallback`     | ❌       | `undefined`  | Card click callback        |
| onStackNearEmpty   | `OnStackNearEmptyCallback`  | ❌       | `undefined`  | Stack near empty callback  |
| onStackEmpty       | `OnStackEmptyCallback`      | ❌       | `undefined`  | Stack empty callback       |
| cardBuilder        | `@BuilderParam`             | ❌       | `undefined`  | Custom card builder        |

### Public Methods

```typescript
// Programmatically swipe left
swipeLeft(): void

// Programmatically swipe right  
swipeRight(): void

// Reset the card stack to initial state
reset(): void

// Get the number of remaining cards
getRemainingCount(): number
```

### Configuration Options (SwipeConfig)

```typescript
interface SwipeConfig {
  maxVisibleCards?: number;    // Max visible cards (default: 4)
  minStackSize?: number;       // Min cards to trigger near empty (default: 2)
  rotationAngle?: number;      // Card rotation angle (default: 15)
  scaleRatio?: number;         // Card scale ratio (default: 0.95)
  swipeThreshold?: number;     // Swipe trigger threshold (default: 100)
  animationDuration?: number;  // Animation duration (default: 300)
  enableSpringBack?: boolean;  // Enable spring rebound (default: true)
  cardSpacing?: number;        // Card spacing (default: 8)
}
```

### Callback Types

```typescript
// Card swipe callback
type OnCardSwipedCallback = (direction: SwipeDirection, data: object, index: number) => void;

// Card click callback
type OnCardClickedCallback = (data: object, index: number) => void;

// Stack near empty callback
type OnStackNearEmptyCallback = (remainingCount: number) => void;

// Stack empty callback
type OnStackEmptyCallback = () => void;
```

### Card Data Structure (Example)

```typescript
interface UserInfo {
  src?: string; // Image URL
  // Extend with more fields as needed
}
```

### SwipeDirection Enum

```typescript
enum SwipeDirection {
  LEFT = 'left',
  RIGHT = 'right',
  UP = 'up',
  DOWN = 'down'
}
```

---

### Advanced Usage

#### Custom Configuration

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
  cardDataList: this.cards,
  swipeConfig: customConfig,
  onCardSwiped: this.handleCardSwiped,
  cardBuilder: this.buildCard
})
```

#### Full Event Handling

```typescript
private handleCardSwiped: OnCardSwipedCallback = (direction: SwipeDirection, data: object, index: number): void => {
  switch (direction) {
    case SwipeDirection.LEFT:
      console.log('Dislike:', data);
      break;
    case SwipeDirection.RIGHT:
      console.log('Like:', data);
      break;
  }
}

private handleCardClicked: OnCardClickedCallback = (data: object, index: number): void => {
  // Handle card click
  this.showCardDetail(data);
}

private handleStackNearEmpty: OnStackNearEmptyCallback = (remainingCount: number): void => {
  // Load more data
  this.loadMoreCards();
}

private handleStackEmpty: OnStackEmptyCallback = (): void => {
  // Show empty state
  this.showEmptyState();
}
```

#### Programmatic Control

```typescript
// Get component reference
@State swipeCardRef: SwipeCardStack | null = null;

// Control swipe via button click
Button('Dislike')
  .onClick((): void => {
    this.swipeCardRef?.swipeLeft();
  })

Button('Like')  
  .onClick((): void => {
    this.swipeCardRef?.swipeRight();
  })

Button('Reset')
  .onClick((): void => {
    this.swipeCardRef?.reset();
  })
```

---

### Performance Optimization Tips

- Use lightweight layout components, avoid complex nesting in cards
- Set `maxVisibleCards` reasonably to improve rendering efficiency
- Load data in batches in `onStackNearEmpty` or `onLoadNextPage`
- Use default animation parameters for best performance
- Clean up swiped-out card data in time to avoid memory leaks

---

### FAQ

**Q: Cards do not respond to swipe gestures?**
A: Check if card content blocks gesture propagation, and ensure no other gesture handlers intercept events.

**Q: Animation is laggy?**
A: Try lowering `maxVisibleCards`, simplifying card content, or adjusting animation parameters.

**Q: High memory usage?**
A: Implement dynamic data loading and cleanup, avoid loading too many cards at once.

---

## 🏗️ Project Structure

```
ArkSwipeDeck/
├── entry/                  # Example app (entry)
│   └── src/main/ets/pages/
│       └── Index.ets       # Example page, full usage demo
├── library/                # Component library source
│   ├── Index.ets           # Unified export entry
│   └── src/main/ets/
│       ├── components/     # Core components like SwipeCardStack
│       ├── types/          # Type definitions
│       ├── utils/          # Utility classes
│       └── constants/      # Constant configs
└── README.en.md            # English documentation (this file)
```

---

## 🤝 Contribution

Contributions via Issues and Pull Requests are welcome!

---

## 📄 License

This project is open-sourced under the [Apache-2.0](LICENSE) license.

---

## 🔗 Links

- [HarmonyOS Developer Docs](https://developer.harmonyos.com/)
- [ArkTS Syntax Guide](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkts-basic-syntax-overview-0000001531611153)
- [Project Homepage](https://github.com/kumaleap/ArkSwipeDeck)

---

⭐ If you find this project helpful, please give it a Star! 