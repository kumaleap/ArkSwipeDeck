/**
 * ArkSwipeDeck 完整功能演示
 *
 * 展示SwipeCardStack组件的所有功能：
 * - 基础滑动交互
 * - 程序化控制
 * - 动态配置
 * - 多种动画类型
 * - 四方向滑动
 * - 性能监控
 *
 * @since 1.0.0
 */

import { SwipeCardStack } from 'arkswipe-deck';
import type {
  CardData,
  CardDataPrimitiveValue,
  SwipeCardStackConfig,
  SwipeCardStackCallbacks,
  SwipeCardStackController,
  SwipeEvent
} from 'arkswipe-deck';
import { SwipeDirection, AnimationType, DEFAULT_SWIPE_CARD_STACK_CONFIG } from 'arkswipe-deck';

/**
 * 统计数据接口
 */
interface StatsData {
  readonly likes: number;
  readonly dislikes: number;
  readonly ups: number;
  readonly downs: number;
}

/**
 * 用户资料接口
 */
interface UserProfile {
  readonly name: string;
  readonly role: string;
  readonly description: string;
  readonly features: readonly string[];
}

/**
 * 配置更新辅助类
 */
class ConfigHelper {
  /**
   * 创建基础模式配置
   */
  static createBasicConfig(): SwipeCardStackConfig {
    const defaultConfig = DEFAULT_SWIPE_CARD_STACK_CONFIG;

    return {
      stack: {
        visibleCount: defaultConfig.stack.visibleCount,
        cardSpacing: defaultConfig.stack.cardSpacing,
        scaleStep: defaultConfig.stack.scaleStep,
        opacityStep: defaultConfig.stack.opacityStep,
        rotationStep: defaultConfig.stack.rotationStep
      },
      swipe: {
        threshold: defaultConfig.swipe.threshold,
        velocityThreshold: defaultConfig.swipe.velocityThreshold,
        allowedDirections: [SwipeDirection.LEFT, SwipeDirection.RIGHT],
        maxRotation: defaultConfig.swipe.maxRotation,
        enableBounce: defaultConfig.swipe.enableBounce
      },
      animation: {
        type: defaultConfig.animation.type,
        duration: defaultConfig.animation.duration,
        spring: {
          velocity: defaultConfig.animation.spring?.velocity ?? 0,
          mass: defaultConfig.animation.spring?.mass ?? 1,
          stiffness: defaultConfig.animation.spring?.stiffness ?? 400,
          damping: defaultConfig.animation.spring?.damping ?? 30
        },
        friction: {
          friction: defaultConfig.animation.friction?.friction ?? 0.6
        }
      },
      enableLoop: defaultConfig.enableLoop,
      debug: defaultConfig.debug
    };
  }

  /**
   * 创建程序控制模式配置
   */
  static createProgrammaticConfig(): SwipeCardStackConfig {
    const defaultConfig = DEFAULT_SWIPE_CARD_STACK_CONFIG;

    return {
      stack: {
        visibleCount: defaultConfig.stack.visibleCount,
        cardSpacing: defaultConfig.stack.cardSpacing,
        scaleStep: defaultConfig.stack.scaleStep,
        opacityStep: defaultConfig.stack.opacityStep,
        rotationStep: defaultConfig.stack.rotationStep
      },
      swipe: {
        threshold: defaultConfig.swipe.threshold,
        velocityThreshold: defaultConfig.swipe.velocityThreshold,
        allowedDirections: defaultConfig.swipe.allowedDirections,
        maxRotation: defaultConfig.swipe.maxRotation,
        enableBounce: defaultConfig.swipe.enableBounce
      },
      animation: {
        type: AnimationType.SPRING,
        duration: defaultConfig.animation.duration,
        spring: {
          velocity: defaultConfig.animation.spring?.velocity ?? 0,
          mass: defaultConfig.animation.spring?.mass ?? 1,
          stiffness: defaultConfig.animation.spring?.stiffness ?? 400,
          damping: defaultConfig.animation.spring?.damping ?? 30
        },
        friction: {
          friction: defaultConfig.animation.friction?.friction ?? 0.6
        }
      },
      enableLoop: defaultConfig.enableLoop,
      debug: defaultConfig.debug
    };
  }

  /**
   * 创建四向滑动模式配置
   */
  static createFourwayConfig(): SwipeCardStackConfig {
    const defaultConfig = DEFAULT_SWIPE_CARD_STACK_CONFIG;

    return {
      stack: {
        visibleCount: defaultConfig.stack.visibleCount,
        cardSpacing: defaultConfig.stack.cardSpacing,
        scaleStep: defaultConfig.stack.scaleStep,
        opacityStep: defaultConfig.stack.opacityStep,
        rotationStep: defaultConfig.stack.rotationStep
      },
      swipe: {
        threshold: defaultConfig.swipe.threshold,
        velocityThreshold: defaultConfig.swipe.velocityThreshold,
        allowedDirections: [
          SwipeDirection.LEFT,
          SwipeDirection.RIGHT,
          SwipeDirection.UP,
          SwipeDirection.DOWN
        ],
        maxRotation: defaultConfig.swipe.maxRotation,
        enableBounce: defaultConfig.swipe.enableBounce
      },
      animation: {
        type: defaultConfig.animation.type,
        duration: defaultConfig.animation.duration,
        spring: {
          velocity: defaultConfig.animation.spring?.velocity ?? 0,
          mass: defaultConfig.animation.spring?.mass ?? 1,
          stiffness: defaultConfig.animation.spring?.stiffness ?? 400,
          damping: defaultConfig.animation.spring?.damping ?? 30
        },
        friction: {
          friction: defaultConfig.animation.friction?.friction ?? 0.6
        }
      },
      enableLoop: defaultConfig.enableLoop,
      debug: defaultConfig.debug
    };
  }

  /**
   * 创建性能测试模式配置
   */
  static createPerformanceConfig(): SwipeCardStackConfig {
    const defaultConfig = DEFAULT_SWIPE_CARD_STACK_CONFIG;

    return {
      stack: {
        visibleCount: defaultConfig.stack.visibleCount,
        cardSpacing: defaultConfig.stack.cardSpacing,
        scaleStep: defaultConfig.stack.scaleStep,
        opacityStep: defaultConfig.stack.opacityStep,
        rotationStep: defaultConfig.stack.rotationStep
      },
      swipe: {
        threshold: defaultConfig.swipe.threshold,
        velocityThreshold: defaultConfig.swipe.velocityThreshold,
        allowedDirections: defaultConfig.swipe.allowedDirections,
        maxRotation: defaultConfig.swipe.maxRotation,
        enableBounce: defaultConfig.swipe.enableBounce
      },
      animation: {
        type: AnimationType.FRICTION,
        duration: 200,
        spring: {
          velocity: defaultConfig.animation.spring?.velocity ?? 0,
          mass: defaultConfig.animation.spring?.mass ?? 1,
          stiffness: defaultConfig.animation.spring?.stiffness ?? 400,
          damping: defaultConfig.animation.spring?.damping ?? 30
        },
        friction: {
          friction: defaultConfig.animation.friction?.friction ?? 0.6
        }
      },
      enableLoop: defaultConfig.enableLoop,
      debug: true
    };
  }
}

@Entry
@Component
struct Index {
  /** 卡片数据 */
  @State private cardList: CardData[] = this.generateCardData();
  /** 组件控制器 */
  private controller: SwipeCardStackController | null = null;
  /** 当前模式 */
  @State private currentMode: string = 'basic';
  /** 操作状态 */
  @State private currentAction: string = '选择演示模式开始体验';
  /** 统计信息 */
  @State private stats: StatsData = this.createInitialStats();
  /** 当前配置 */
  @State private config: SwipeCardStackConfig = DEFAULT_SWIPE_CARD_STACK_CONFIG;
  /** 显示配置面板 */
  @State private showConfig: boolean = false;

  build(): void {
    Column() {
      // 顶部导航栏
      this.buildHeader()

      // 模式选择器
      this.buildModeSelector()

      // 主要演示区域
      Stack() {
        this.buildSwipeDemo()
      }
      .width('100%')
      .height(400)
      .margin({ top: 20 })

      // 状态信息
      this.buildStatusInfo()

      // 控制按钮区域
      if (this.currentMode !== 'basic') {
        this.buildControlButtons()
      }

      // 统计面板
      this.buildStatsPanel()

      Blank()

      // 底部操作区
      this.buildBottomActions()
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F5F7FA')
  }

  /**
   * 构建顶部标题
   */
  @Builder
  private buildHeader(): void {
    Row() {
      Column() {
        Text('ArkSwipeDeck')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Text('完整功能演示')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      // 配置按钮
      Button('⚙️')
        .backgroundColor('#007AFF')
        .borderRadius(20)
        .width(40)
        .height(40)
        .onClick((): void => {
          this.showConfig = !this.showConfig;
        })
    }
    .width('100%')
    .margin({ top: 20, bottom: 20 })
  }

  /**
   * 构建模式选择器
   */
  @Builder
  private buildModeSelector(): void {
    Row() {
      this.buildModeButton('basic', '基础模式', '#4ECDC4')
      this.buildModeButton('programmatic', '程序控制', '#007AFF')
      this.buildModeButton('fourway', '四向滑动', '#FF6B6B')
      this.buildModeButton('performance', '性能测试', '#FFA726')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
  }

  /**
   * 构建模式按钮
   */
  @Builder
  private buildModeButton(mode: string, title: string, color: string): void {
    Column() {
      Text(title)
        .fontSize(12)
        .fontColor(this.currentMode === mode ? Color.White : color)
        .fontWeight(this.currentMode === mode ? FontWeight.Bold : FontWeight.Normal)
    }
    .padding({ left: 8, right: 12 })
    .backgroundColor(this.currentMode === mode ? color : 'rgba(0,0,0,0.05)')
    .borderRadius(16)
    .onClick((): void => {
      this.switchMode(mode);
    })
  }

  /**
   * 构建滑动演示区域
   */
  @Builder
  private buildSwipeDemo(): void {
    SwipeCardStack({
      cardDataList: this.cardList,
      config: this.config,
      callbacks: this.createCallbacks(),
      cardContentBuilder: (card: CardData, index: number) => {
        this.buildCard(card, index);
      },
      controller: (controller: SwipeCardStackController): void => {
        this.controller = controller;
      }
    })
  }

  /**
   * 构建卡片内容
   */
  @Builder
  private buildCard(card: CardData, index: number): void {
    Column() {
      // 头部信息
      Row() {
                // 头像
        Stack() {
          Circle({ width: 50, height: 50 })
            .fill(this.getAvatarColor(index))
          
          Text(this.getCardEmoji(index))
            .fontSize(20)
        }
        Column() {
          Text(this.getCardTitle(card, index))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)

          Text(this.getCardSubtitle(card, index))
            .fontSize(14)
            .fontColor('#E8E8E8')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })

        Blank()

        // 模式标识
        Text(this.getModeIcon())
          .fontSize(16)
          .fontColor('#E8E8E8')
      }
      .width('100%')
      .padding(20)

      // 主要内容
      Column() {
        Text(this.getCardDescription(card, index))
          .fontSize(16)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .maxLines(3)
          .margin({ bottom: 16 })

        // 特性标签
        this.buildFeatureTags(index)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .padding({ left: 20, right: 20 })

      // 底部提示
      Row() {
        if (this.currentMode === 'fourway') {
          Text('👎←  ↑👍  ↓❌  →❤️')
            .fontSize(12)
            .fontColor('#E8E8E8')
        } else {
          Text('👎 左滑拒绝  |  右滑喜欢 👍')
            .fontSize(12)
            .fontColor('#E8E8E8')
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.getCardColor(index))
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: 'rgba(0,0,0,0.15)',
      offsetX: 0,
      offsetY: 6
    })
  }

  /**
   * 构建特性标签
   */
  @Builder
  private buildFeatureTags(index: number): void {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
      ForEach(this.getCardFeatures(index), (feature: string) => {
        Text(feature)
          .fontSize(12)
          .fontColor('#E8E8E8')
          .backgroundColor('rgba(255,255,255,0.2)')
          .padding({
            left: 12,
            right: 12,
            top: 6,
            bottom: 6
          })
          .borderRadius(12)
          .margin({ right: 6, bottom: 6 })
      })
    }
  }

  /**
   * 构建状态信息
   */
  @Builder
  private buildStatusInfo(): void {
    Column() {
      Text(this.currentAction)
        .fontSize(16)
        .fontColor('#333333')
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .lineHeight(22)

      if (this.showConfig) {
        this.buildConfigPanel()
      }
    }
    .width('100%')
    .margin({ top: 16 })
  }

  /**
   * 构建配置面板
   */
  @Builder
  private buildConfigPanel(): void {
    Column() {
      Text('配置面板')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 16, bottom: 12 })

      Grid() {
        GridItem() {
          this.buildConfigItem('动画类型', this.config.animation.type.toString(), (): void => {
            this.switchAnimationType();
          })
        }

        GridItem() {
          this.buildConfigItem('可见卡片', this.config.stack.visibleCount.toString(), (): void => {
            this.adjustVisibleCount();
          })
        }

        GridItem() {
          this.buildConfigItem('回弹效果', this.config.swipe.enableBounce ? '开启' : '关闭', (): void => {
            this.toggleBounce();
          })
        }

        GridItem() {
          this.buildConfigItem('调试模式', this.config.debug ? '开启' : '关闭', (): void => {
            this.toggleDebug();
          })
        }
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .height(100)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 12 })
  }

  /**
   * 构建配置项
   */
  @Builder
  private buildConfigItem(label: string, value: string, onClick: () => void): void {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor('#666666')
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#007AFF')
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
    .padding(8)
    .backgroundColor('#F8F9FA')
    .borderRadius(8)
    .onClick(onClick)
  }

  /**
   * 构建控制按钮
   */
  @Builder
  private buildControlButtons(): void {
    Row() {
      if (this.currentMode === 'programmatic') {
        Button('👍 喜欢')
          .backgroundColor('#4ECDC4')
          .borderRadius(20)
          .onClick((): void => {
            this.performProgrammaticSwipe(SwipeDirection.RIGHT);
          })

        Button('👎 拒绝')
          .backgroundColor('#FF6B6B')
          .borderRadius(20)
          .margin({ left: 12 })
          .onClick((): void => {
            this.performProgrammaticSwipe(SwipeDirection.LEFT);
          })

        Button('🔄 重置')
          .backgroundColor('#FFA726')
          .borderRadius(20)
          .margin({ left: 12 })
          .onClick((): void => {
            this.resetCurrentCard();
          })
      }

      if (this.currentMode === 'fourway') {
        Button('⬆️')
          .backgroundColor('#4ECDC4')
          .borderRadius(20)
          .width(50)
          .onClick((): void => {
            this.performProgrammaticSwipe(SwipeDirection.UP);
          })

        Button('⬇️')
          .backgroundColor('#FF9500')
          .borderRadius(20)
          .width(50)
          .margin({ left: 12 })
          .onClick((): void => {
            this.performProgrammaticSwipe(SwipeDirection.DOWN);
          })

        Button('⬅️')
          .backgroundColor('#FF6B6B')
          .borderRadius(20)
          .width(50)
          .margin({ left: 12 })
          .onClick((): void => {
            this.performProgrammaticSwipe(SwipeDirection.LEFT);
          })

        Button('➡️')
          .backgroundColor('#007AFF')
          .borderRadius(20)
          .width(50)
          .margin({ left: 12 })
          .onClick((): void => {
            this.performProgrammaticSwipe(SwipeDirection.RIGHT);
          })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: 16 })
  }

  /**
   * 构建统计面板
   */
  @Builder
  private buildStatsPanel(): void {
    Row() {
      this.buildStatItem('👍', '喜欢', this.stats.likes, '#4ECDC4')
      this.buildStatItem('👎', '拒绝', this.stats.dislikes, '#FF6B6B')

      if (this.currentMode === 'fourway') {
        this.buildStatItem('⬆️', '向上', this.stats.ups, '#4ECDC4')
        this.buildStatItem('⬇️', '向下', this.stats.downs, '#FF9500')
      }

      this.buildStatItem('📱', '剩余', this.cardList.length, '#007AFF')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .margin({ top: 20 })
  }

  /**
   * 构建统计项
   */
  @Builder
  private buildStatItem(icon: string, label: string, value: number, color: string): void {
    Column() {
      Text(icon)
        .fontSize(20)
        .margin({ bottom: 4 })
      Text(value.toString())
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(12)
        .fontColor('#666666')
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 构建底部操作区
   */
  @Builder
  private buildBottomActions(): void {
    Row() {
      Button('🔄 重新开始')
        .backgroundColor('#007AFF')
        .borderRadius(25)
        .height(44)
        .layoutWeight(1)
        .onClick((): void => {
          this.resetDemo();
        })

      Button('📊 性能测试')
        .backgroundColor('#FFA726')
        .borderRadius(25)
        .height(44)
        .layoutWeight(1)
        .margin({ left: 12 })
        .onClick((): void => {
          this.runPerformanceTest();
        })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  // ==============================
  // 数据和逻辑方法
  // ==============================

  /**
   * 创建初始统计数据
   */
  private createInitialStats(): StatsData {
    const initialStats: StatsData = {
      likes: 0,
      dislikes: 0,
      ups: 0,
      downs: 0
    };

    return initialStats;
  }

  /**
   * 生成示例卡片数据
   */
  private generateCardData(): CardData[] {
    const profile1: UserProfile = {
      name: '小美',
      role: '摄影师',
      description: '热爱捕捉生活中的美好瞬间 📸\n专业人像和风景摄影\n在这里寻找拍摄伙伴',
      features: ['摄影', '旅行', '艺术', '咖啡']
    };
    const profile2: UserProfile = {
      name: '小雨',
      role: '音乐人',
      description: '独立音乐制作人和歌手 🎵\n喜欢民谣和电子音乐\n寻找音乐路上的知音',
      features: ['音乐', '吉他', '创作', '演出']
    };
    const profile3: UserProfile = {
      name: '小夏',
      role: '健身教练',
      description: 'ACSM认证私人教练 💪\n专注功能性训练\n帮你找到运动的乐趣',
      features: ['健身', '瑜伽', '营养', '马拉松']
    };
    const profile4: UserProfile = {
      name: '小秋',
      role: '美食博主',
      description: '美食探索者和料理研究家 🍜\n分享地道美食和烹饪技巧\n一起发现味蕾的秘密',
      features: ['美食', '烹饪', '品酒', '探店']
    };
    const profile5: UserProfile = {
      name: '小冬',
      role: '设计师',
      description: 'UI/UX设计师和插画师 🎨\n专注用户体验设计\n用设计改变世界',
      features: ['设计', '插画', '用户体验', 'AI']
    };
    const profile6: UserProfile = {
      name: '阿强',
      role: '程序员',
      description: '全栈开发工程师 💻\n热爱开源和新技术\n代码改变生活',
      features: ['编程', 'AI', '开源', '游戏']
    };

    const profiles: UserProfile[] = [profile1, profile2, profile3, profile4, profile5, profile6];

    return profiles.map((profile, index): CardData => {
      const dataMap: Map<string, CardDataPrimitiveValue> = new Map();
      dataMap.set('name', profile.name);
      dataMap.set('role', profile.role);
      dataMap.set('description', profile.description);

      const cardData: CardData = {
        id: `demo_card_${index}_${Date.now()}`,
        index: index,
        visible: true,
        data: dataMap
      };

      return cardData;
    });
  }

  /**
   * 创建事件回调
   */
  private createCallbacks(): SwipeCardStackCallbacks {
    const callbacks: SwipeCardStackCallbacks = {
      onDragStart: (event: SwipeEvent): void => {
        this.currentAction = '开始拖拽卡片...';
      },

      onDragUpdate: (event: SwipeEvent): void => {
        const progressPercent: number = Math.round(event.progress * 100);
        if (progressPercent > 20) {
          const directionText: string = this.getDirectionText(event.direction);
          this.currentAction = `${directionText} ${progressPercent}%`;
        }
      },

      onDragEnd: (event: SwipeEvent): void => {
        this.currentAction = '释放拖拽';
      },

      onCardSwiped: (event: SwipeEvent): void => {
        const directionText: string = this.getDirectionText(event.direction);
        const cardName: string = this.getCardName(event.card);

        this.currentAction = `${directionText}了 ${cardName}`;
        this.updateStats(event.direction);
      },

      onCardBounced: (event: SwipeEvent): void => {
        this.currentAction = '卡片已回弹到原位';
      },

      onStackEmpty: (): void => {
        this.currentAction = '🎉 所有卡片处理完毕！';
        setTimeout((): void => {
          this.resetDemo();
        }, 2000);
      },

      onStackUpdate: (visibleCards: CardData[]): void => {
        if (this.config.debug) {
          console.info(`可见卡片更新: ${visibleCards.length}张`);
        }
      }
    };

    return callbacks;
  }

  /**
   * 切换模式
   */
  private switchMode(mode: string): void {
    this.currentMode = mode;

    switch (mode) {
      case 'basic':
        this.config = ConfigHelper.createBasicConfig();
        this.currentAction = '基础模式：左右滑动体验';
        break;

      case 'programmatic':
        this.config = ConfigHelper.createProgrammaticConfig();
        this.currentAction = '程序控制：使用按钮控制卡片';
        break;

      case 'fourway':
        this.config = ConfigHelper.createFourwayConfig();
        this.currentAction = '四向滑动：支持上下左右全方向';
        break;

      case 'performance':
        this.config = ConfigHelper.createPerformanceConfig();
        this.currentAction = '性能模式：优化动画和调试信息';
        break;
    }
  }

  /**
   * 程序化滑动
   */
  private performProgrammaticSwipe(direction: SwipeDirection): void {
    if (this.controller && this.cardList.length > 0) {
      const topCard: CardData | null = this.controller.getTopCard();
      if (topCard) {
        switch (direction) {
          case SwipeDirection.LEFT:
            this.controller.swipeLeft(true);
            break;
          case SwipeDirection.RIGHT:
            this.controller.swipeRight(true);
            break;
          case SwipeDirection.UP:
            this.controller.swipeUp(true);
            break;
          case SwipeDirection.DOWN:
            this.controller.swipeDown(true);
            break;
        }
      }
    }
  }

  /**
   * 重置当前卡片
   */
  private resetCurrentCard(): void {
    if (this.controller) {
      this.controller.resetCard();
      this.currentAction = '当前卡片已重置';
    }
  }

  /**
   * 切换动画类型
   */
  private switchAnimationType(): void {
    const types: AnimationType[] = [AnimationType.SPRING, AnimationType.FRICTION, AnimationType.EASE];
    const currentIndex: number = types.indexOf(this.config.animation.type);
    const nextIndex: number = (currentIndex + 1) % types.length;

    const newConfig: SwipeCardStackConfig = {
      stack: {
        visibleCount: this.config.stack.visibleCount,
        cardSpacing: this.config.stack.cardSpacing,
        scaleStep: this.config.stack.scaleStep,
        opacityStep: this.config.stack.opacityStep,
        rotationStep: this.config.stack.rotationStep
      },
      swipe: {
        threshold: this.config.swipe.threshold,
        velocityThreshold: this.config.swipe.velocityThreshold,
        allowedDirections: this.config.swipe.allowedDirections,
        maxRotation: this.config.swipe.maxRotation,
        enableBounce: this.config.swipe.enableBounce
      },
      animation: {
        type: types[nextIndex],
        duration: this.config.animation.duration,
        spring: {
          velocity: this.config.animation.spring?.velocity ?? 0,
          mass: this.config.animation.spring?.mass ?? 1,
          stiffness: this.config.animation.spring?.stiffness ?? 400,
          damping: this.config.animation.spring?.damping ?? 30
        },
        friction: {
          friction: this.config.animation.friction?.friction ?? 0.6
        }
      },
      enableLoop: this.config.enableLoop,
      debug: this.config.debug
    };

    this.config = newConfig;
  }

  /**
   * 调整可见卡片数量
   */
  private adjustVisibleCount(): void {
    const counts: number[] = [2, 3, 4, 5];
    const currentIndex: number = counts.indexOf(this.config.stack.visibleCount);
    const nextIndex: number = (currentIndex + 1) % counts.length;

    const newConfig: SwipeCardStackConfig = {
      stack: {
        visibleCount: counts[nextIndex],
        cardSpacing: this.config.stack.cardSpacing,
        scaleStep: this.config.stack.scaleStep,
        opacityStep: this.config.stack.opacityStep,
        rotationStep: this.config.stack.rotationStep
      },
      swipe: {
        threshold: this.config.swipe.threshold,
        velocityThreshold: this.config.swipe.velocityThreshold,
        allowedDirections: this.config.swipe.allowedDirections,
        maxRotation: this.config.swipe.maxRotation,
        enableBounce: this.config.swipe.enableBounce
      },
      animation: {
        type: this.config.animation.type,
        duration: this.config.animation.duration,
        spring: {
          velocity: this.config.animation.spring?.velocity ?? 0,
          mass: this.config.animation.spring?.mass ?? 1,
          stiffness: this.config.animation.spring?.stiffness ?? 400,
          damping: this.config.animation.spring?.damping ?? 30
        },
        friction: {
          friction: this.config.animation.friction?.friction ?? 0.6
        }
      },
      enableLoop: this.config.enableLoop,
      debug: this.config.debug
    };

    this.config = newConfig;
  }

  /**
   * 切换回弹效果
   */
  private toggleBounce(): void {
    const newConfig: SwipeCardStackConfig = {
      stack: {
        visibleCount: this.config.stack.visibleCount,
        cardSpacing: this.config.stack.cardSpacing,
        scaleStep: this.config.stack.scaleStep,
        opacityStep: this.config.stack.opacityStep,
        rotationStep: this.config.stack.rotationStep
      },
      swipe: {
        threshold: this.config.swipe.threshold,
        velocityThreshold: this.config.swipe.velocityThreshold,
        allowedDirections: this.config.swipe.allowedDirections,
        maxRotation: this.config.swipe.maxRotation,
        enableBounce: !this.config.swipe.enableBounce
      },
      animation: {
        type: this.config.animation.type,
        duration: this.config.animation.duration,
        spring: {
          velocity: this.config.animation.spring?.velocity ?? 0,
          mass: this.config.animation.spring?.mass ?? 1,
          stiffness: this.config.animation.spring?.stiffness ?? 400,
          damping: this.config.animation.spring?.damping ?? 30
        },
        friction: {
          friction: this.config.animation.friction?.friction ?? 0.6
        }
      },
      enableLoop: this.config.enableLoop,
      debug: this.config.debug
    };

    this.config = newConfig;
  }

  /**
   * 切换调试模式
   */
  private toggleDebug(): void {
    const newConfig: SwipeCardStackConfig = {
      stack: {
        visibleCount: this.config.stack.visibleCount,
        cardSpacing: this.config.stack.cardSpacing,
        scaleStep: this.config.stack.scaleStep,
        opacityStep: this.config.stack.opacityStep,
        rotationStep: this.config.stack.rotationStep
      },
      swipe: {
        threshold: this.config.swipe.threshold,
        velocityThreshold: this.config.swipe.velocityThreshold,
        allowedDirections: this.config.swipe.allowedDirections,
        maxRotation: this.config.swipe.maxRotation,
        enableBounce: this.config.swipe.enableBounce
      },
      animation: {
        type: this.config.animation.type,
        duration: this.config.animation.duration,
        spring: {
          velocity: this.config.animation.spring?.velocity ?? 0,
          mass: this.config.animation.spring?.mass ?? 1,
          stiffness: this.config.animation.spring?.stiffness ?? 400,
          damping: this.config.animation.spring?.damping ?? 30
        },
        friction: {
          friction: this.config.animation.friction?.friction ?? 0.6
        }
      },
      enableLoop: this.config.enableLoop,
      debug: !this.config.debug
    };

    this.config = newConfig;
  }

  /**
   * 运行性能测试
   */
  private runPerformanceTest(): void {
    this.currentMode = 'performance';
    this.switchMode('performance');

    // 模拟快速操作
    let count: number = 0;
    const testInterval = setInterval((): void => {
      if (count < 10 && this.cardList.length > 0) {
        const direction: SwipeDirection = count % 2 === 0 ? SwipeDirection.RIGHT : SwipeDirection.LEFT;
        this.performProgrammaticSwipe(direction);
        count++;
      } else {
        clearInterval(testInterval);
        this.currentAction = `性能测试完成：${count}次操作`;
      }
    }, 300);
  }

  /**
   * 更新统计
   */
  private updateStats(direction: SwipeDirection): void {
    switch (direction) {
      case SwipeDirection.LEFT:
        const leftStats: StatsData = {
          likes: this.stats.likes,
          dislikes: this.stats.dislikes + 1,
          ups: this.stats.ups,
          downs: this.stats.downs
        };
        this.stats = leftStats;
        break;
      case SwipeDirection.RIGHT:
        const rightStats: StatsData = {
          likes: this.stats.likes + 1,
          dislikes: this.stats.dislikes,
          ups: this.stats.ups,
          downs: this.stats.downs
        };
        this.stats = rightStats;
        break;
      case SwipeDirection.UP:
        const upStats: StatsData = {
          likes: this.stats.likes,
          dislikes: this.stats.dislikes,
          ups: this.stats.ups + 1,
          downs: this.stats.downs
        };
        this.stats = upStats;
        break;
      case SwipeDirection.DOWN:
        const downStats: StatsData = {
          likes: this.stats.likes,
          dislikes: this.stats.dislikes,
          ups: this.stats.ups,
          downs: this.stats.downs + 1
        };
        this.stats = downStats;
        break;
    }
  }

  /**
   * 重置演示
   */
  private resetDemo(): void {
    this.cardList = this.generateCardData();
    this.stats = this.createInitialStats();
    this.currentAction = '演示已重置，选择模式开始体验';
  }

  // ==============================
  // 辅助方法
  // ==============================

  private getCardTitle(card: CardData, index: number): string {
    return card?.data?.get('name') as string || `用户 ${index + 1}`;
  }

  private getCardSubtitle(card: CardData, index: number): string {
    return card?.data?.get('role') as string || '神秘用户';
  }

  private getCardDescription(card: CardData, index: number): string {
    return card?.data?.get('description') as string || `这是第${index + 1}张演示卡片`;
  }

  private getCardFeatures(index: number): string[] {
    const allFeatures: string[][] = [
      ['摄影', '旅行', '艺术', '咖啡'],
      ['音乐', '吉他', '创作', '演出'],
      ['健身', '瑜伽', '营养', '马拉松'],
      ['美食', '烹饪', '品酒', '探店'],
      ['设计', '插画', '用户体验', 'AI'],
      ['编程', 'AI', '开源', '游戏']
    ];
    return allFeatures[index % allFeatures.length];
  }

  private getCardColor(index: number): string {
    const colors: string[] = [
      'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
      'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
      'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
      'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
      'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)'
    ];
    // 由于ArkTS不支持CSS渐变，使用纯色替代
    const solidColors: string[] = ['#667eea', '#f093fb', '#4facfe', '#43e97b', '#fa709a', '#a8edea'];
    return solidColors[index % solidColors.length];
  }

  private getAvatarColor(index: number): string {
    const colors: string[] = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA0DD'];
    return colors[index % colors.length];
  }

  private getCardEmoji(index: number): string {
    const emojis: string[] = ['📸', '🎵', '💪', '🍜', '🎨', '💻'];
    return emojis[index % emojis.length];
  }

  private getModeIcon(): string {
    switch (this.currentMode) {
      case 'basic':
        return '📱';
      case 'programmatic':
        return '🎮';
      case 'fourway':
        return '🧭';
      case 'performance':
        return '⚡';
      default:
        return '✨';
    }
  }

  private getDirectionText(direction: SwipeDirection): string {
    switch (direction) {
      case SwipeDirection.LEFT:
        return '拒绝';
      case SwipeDirection.RIGHT:
        return '喜欢';
      case SwipeDirection.UP:
        return '超级喜欢';
      case SwipeDirection.DOWN:
        return '不感兴趣';
      default:
        return '未知操作';
    }
  }

  private getCardName(card: CardData): string {
    if (card.data === undefined || card.data === null) {
      return '未知用户';
    }
    const name: CardDataPrimitiveValue | undefined = card.data.get('name');
    return (name as string) || '未知用户';
  }
}