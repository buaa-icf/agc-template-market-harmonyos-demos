import { AppStorageV2, promptAction, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import {baseActionSheet} from 'base_common'
import { UserInfo } from 'base_common';
import { SelectState } from './SelectState';

interface ReaderSettingLike {
  fontName: string;
  fontPath: string;
  fontSize: number;
  fontColor: string;
  fontWeight: number;
  lineHeight: number;
  nightMode: boolean;
  themeColor: string;
  themeBgImg: string;
  flipMode: string;
  scaledDensity: number;
  viewPortWidth: number;
  viewPortHeight: number;
}

interface ReaderComponentControllerLike {
  setPageConfig(readerSetting: ReaderSettingLike): void;
  startPlay(resourceIndex: number, domPos: string): void;
}

interface BookParserHandlerLike {
  getDomPosByCatalogHref(href: string): string;
}

interface CatalogItemLike {
  href?: string;
  resourceFile?: string;
  catalogName?: string;
  catalogId?: number;
}

interface SpineItemLike {
  idRef: string;
  index: number;
  href: string;
  properties: string;
}

class DefaultReaderComponentController implements ReaderComponentControllerLike {
  setPageConfig(_readerSetting: ReaderSettingLike): void {
  }

  startPlay(_resourceIndex: number, _domPos: string): void {
  }
}

@ComponentV2
export struct ReaderToolBar {
  @Param @Require readerComponentController: ReaderComponentControllerLike = new DefaultReaderComponentController();
  @Param @Require bookParserHandler: BookParserHandlerLike | null = null;
  @Param @Require lockedStatus: boolean[] = [];
  @Param @Require curChapterId: number = 0
  @Param @Require catalogItemList: CatalogItemLike[] = [];
  @Param @Require spineList: SpineItemLike[] = []
  @Param @Require readerSetting: ReaderSettingLike
  @Local isShowSetTool: boolean = false;
  @Local isShowLight: boolean = false;
  @Local screenLight: number = 0.5;
  @Local fontSize: number = 0;
  @Local autoLight: boolean = true;
  @Local nightMode: boolean = false;
  @Local price: number = 10
  @Local isReadingBySingle: boolean = true;
  @Local selectState: SelectState = AppStorageV2.connect(SelectState, () => new SelectState())!;
  @Local userInfo: UserInfo = AppStorage.get<UserInfo>('userInfo')!
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private windowClass: window.Window | null = null;

  aboutToAppear(): void {
    this.fontSize = this.readerSetting.fontSize
    this.nightMode = this.readerSetting.nightMode
    if (this.nightMode) {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
    }
  }

  private async getWindowClass(): Promise<window.Window | null> {
    if (this.windowClass !== null) {
      return this.windowClass;
    }

    try {
      this.windowClass = await window.getLastWindow(getContext());
    } catch (_error) {
      this.windowClass = null;
    }
    return this.windowClass;
  }

  private async jumpToCatalogItem(catalogItem: CatalogItemLike) {
    const domPos = await this.getDomPos(catalogItem);
    const resourceIndex = this.getResourceItemByCatalog(catalogItem).index;
    // 通过domPos及resourceIndex信息，即可通过startPlay接口跳转到指定位置
    this.readerComponentController.startPlay(resourceIndex, domPos)
  }

  private async getDomPos(catalogItem: CatalogItemLike): Promise<string> {
    const domPos: string = this.bookParserHandler?.getDomPosByCatalogHref(catalogItem.href || '') || '';
    return domPos;
  }

  /**
   * 获取书籍目录对应的资源条目
   *
   * @param catalogItem 目录条目
   */
  private getResourceItemByCatalog(catalogItem: CatalogItemLike): SpineItemLike {
    let resourceFile = catalogItem.resourceFile || '';

    // 查找目录对应的资源条目
    let resourceItemArr = this.spineList.filter(item => item.href === resourceFile);
    if (resourceItemArr.length > 0) {
      hilog.info(0x0000, 'testTag', 'getResourceItemByCatalog get resource ', resourceItemArr[0]);
      let resourceItem = resourceItemArr[0];
      return resourceItem;
    } else if (this.spineList.length > 0) {
      // 如果查找不到，则默认返回第1个资源条目
      hilog.info(0x0000, 'testTag', 'getResourceItemByCatalog get resource in resourceList', this.spineList[0]);
      return this.spineList[0];
    } else {
      // 如果没有资源条目，则返回默认值
      hilog.info(0x0000, 'testTag', 'getResourceItemByCatalog get resource in escape');
      return {
        idRef: '',
        index: 0,
        href: '',
        properties: ''
      };
    }
  }

  @Builder
  buildBuyChapter(ri: RepeatItem<CatalogItemLike>) {
    Column({ space: 8 }) {
      Text(`价格：${this.price}书币`)
      Text(`余额：${this.userInfo!.bookCoins}书币`)
      Row() {
        Checkbox()
          .onChange((value) => {
            this.userInfo!.continuousBuy = value
          })
        Text('自动购买下一章')
      }

      Button('购买')
        .onClick(() => {
          if (this.price > this.userInfo!.bookCoins!) {
            promptAction.showToast({
              message: '余额不足',
              duration: 2000
            });
          } else {
            this.userInfo!.bookCoins -= this.price
            this.lockedStatus[ri.index] = false
            baseActionSheet.close('buyChapter')
            baseActionSheet.close('catalog')
          }
        })
        .width('100%')
    }
    .padding({ bottom: 30, left: 16, right: 16 })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  fontChoice(name: string, filePath: string, index: number) {
    Text(name)
      .padding({
        left: 24,
        right: 24,
        top: 6,
        bottom: 6
      })
      .borderRadius(14)
      .fontColor(this.selectState.fontSelectedIndex === index ? $r('sys.color.ohos_id_color_text_primary_contrary') :
      $r('sys.color.ohos_id_color_text_secondary'))
      .fontSize(14)
      .fontWeight('medium')
      .backgroundColor(this.selectState.fontSelectedIndex === index ? $r('sys.color.ohos_id_color_handup') :
      $r('sys.color.ohos_id_color_button_normal'))
      .onClick(() => {
        this.selectState.fontSelectedIndex = index
        this.readerSetting.fontName = name;
        this.readerSetting.fontPath = filePath;
        this.readerComponentController.setPageConfig(this.readerSetting)
      })
  }

  @Builder
  buildSettingSheet() {
    Column({ space: 25 }) {
      Row({ space: 8 }) {
        Text('字号')

        Image($r('app.media.ic_font_sub'))
          .id('reader_tool_bar_font_size_sub')
          .height(28)
          .width(48)
          .onClick(() => {
            if (this.fontSize > 1) {
              this.readerSetting.fontSize -= 1;
              this.readerComponentController.setPageConfig(this.readerSetting)
              this.fontSize = this.readerSetting.fontSize
            }
          })

        Text(this.fontSize.toString())
          .id('reader_tool_bar_font_size_value')
          .fontSize(16)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))

        Image($r('app.media.ic_font_add'))
          .id('reader_tool_bar_font_size_add')
          .height(28)
          .width(48)
          .onClick(() => {
            if (this.fontSize < 50) {
              this.readerSetting.fontSize += 1;
              this.readerComponentController.setPageConfig(this.readerSetting)
              this.fontSize = this.readerSetting.fontSize
            }
          })
      }

      Row({ space: 8 }) {
        Text('字体')

        Row({ space: 10 }) {
          this.fontChoice('系统','fonts/HarmonyOS_Sans_Regular.ttf', 0)
          this.fontChoice('鸿蒙黑体','fonts/HarmonyOS_Sans_Black.ttf', 1)
        }
      }

      Row({ space: 8 }) {
        Text('行间')

        Row({ space: 12 }) {
          Image($r('app.media.ic_space_min'))
            .height(24)
            .width(24)

          Slider({
            min: 1,
            max: 4,
            value: this.readerSetting.lineHeight,
            step: 0.1,
            style: SliderStyle.InSet
          })
            .blockColor($r('app.color.font_modifier_inner_color'))
            .trackColor($r('app.color.pure_white'))
            .selectedColor($r('app.color.slider_selected_color'))
            .onChange((value: number) => {
              this.readerSetting.lineHeight = value
              this.readerComponentController.setPageConfig(this.readerSetting)
            })
            .layoutWeight(1)

          Image($r('app.media.ic_space_max'))
            .height(24)
            .width(24)
        }
        .layoutWeight(1)

      }
      .width('100%')

      Row({ space: 12 }) {
        Text('背景')

        Row({ space: 8 }) {
          this.colorCircle($r('app.color.reader_view_background_0'), 0)
          this.colorCircle($r('app.color.reader_view_background_1'), 1)
          this.colorCircle($r('app.color.reader_view_background_2'), 2)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
      }

      Row({ space: 12 }) {
        Text('翻页')

        Row({ space: 10 }) {
          Text('仿真')
            .padding({
              left: 24,
              right: 24,
              top: 6,
              bottom: 6
            })
            .borderRadius(14)
            .fontColor(this.selectState.isReadingBySwiper ? $r('sys.color.ohos_id_color_text_secondary') :
            $r('sys.color.ohos_id_color_text_primary_contrary'))
            .fontSize(14)
            .fontWeight('medium')
            .backgroundColor(this.selectState.isReadingBySwiper ? $r('sys.color.ohos_id_color_button_normal') :
            $r('sys.color.ohos_id_color_handup'))
            .onClick(() => {
              this.readerSetting.flipMode = '0'
              this.selectState.isReadingBySwiper = false
              this.readerComponentController.setPageConfig(this.readerSetting)
            })

          Text('横滑')
            .padding({
              left: 24,
              right: 24,
              top: 6,
              bottom: 6
            })
            .borderRadius(14)
            .fontColor(this.selectState.isReadingBySwiper ? $r('sys.color.ohos_id_color_text_primary_contrary') :
            $r('sys.color.ohos_id_color_text_secondary'))
            .fontSize(14)
            .fontWeight('medium')
            .backgroundColor(this.selectState.isReadingBySwiper ? $r('sys.color.ohos_id_color_handup') :
            $r('sys.color.ohos_id_color_button_normal'))
            .onClick(() => {
              this.readerSetting.flipMode = '1'
              this.selectState.isReadingBySwiper = true
              this.readerComponentController.setPageConfig(this.readerSetting)
            })
        }
      }
    }
    .padding({
      top: 25,
      bottom: 25,
      left: 24,
      right: 24
    })
    .id('reader_tool_bar_setting_sheet')
    .alignItems(HorizontalAlign.Start)

  }

  @Builder
  buildLightModifySlider() {
    Row({ space: 5 }) {
      Image($r('app.media.light_min'))
        .height(16)
        .width(16)

      Slider({
        min: 0,
        max: 1,
        value: this.screenLight!!,
        step: 0.2,
        style: SliderStyle.OutSet
      })
        .blockColor($r('app.color.font_modifier_inner_color'))
        .trackColor($r('app.color.pure_white'))
        .selectedColor($r('app.color.slider_selected_color'))
        .onChange(async (value: number) => {
          this.autoLight = false
          this.screenLight = value;
          (await this.getWindowClass())?.setWindowBrightness(this.screenLight);
        })
        .layoutWeight(1)

      Image($r('app.media.light_min'))
        .height(20)
        .width(20)
    }
    .width('100%')
    .padding({ left: 18, right: 18 })
    .justifyContent(FlexAlign.SpaceBetween)
    .height(50)
  }

  @Builder
  buildCatalogCard() {
    Column() {
      Row() {
        Text(`共${this.catalogItemList.length}章`)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_secondary'))
          .width('100%')
      }
      .padding({
        top: 4,
        bottom: 33,
        left: 15,
        right: 15
      })


      List({ space: 22 }) {
        Repeat<CatalogItemLike>(this.catalogItemList)
          .each((ri: RepeatItem<CatalogItemLike>) => {
            ListItem() {
              Text(`• ${ri.item.catalogName}`)
                .fontSize(14)
                .width('100%')
                .fontColor(this.curChapterId === ri.item.catalogId ? $r('sys.color.ohos_id_color_warning') :
                $r('sys.color.ohos_fa_text_primary'))
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
            }
            .onClick(() => {
              this.jumpToCatalogItem(ri.item)
              baseActionSheet.close('catalog')
            })
          })
          .templateId((_item: CatalogItemLike, index: number): string => {
            return this.lockedStatus[index] ? 'locked' : ''
          })
          .template('locked', (ri: RepeatItem<CatalogItemLike>) => {
            ListItem() {
              Row() {
                Text(`• ${ri.item.catalogName}`)
                  .fontSize(14)
                  .fontWeight('medium')
                  .width('80%')
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)

                Image($r('app.media.ic_public_locked'))
                  .height(24)
                  .width(24)
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
            }
            .onClick(() => {
              baseActionSheet.show({
                id: 'buyChapter',
                title: { title: '购买' },
                height: SheetSize.FIT_CONTENT,
                preferType: SheetType.CENTER,
                customContent: () => {
                  this.buildBuyChapter(ri)
                }
              })
            })
          })
      }
      .padding({ left: 28, right: 28, bottom: 15 })
      .divider({ strokeWidth: 1, color: $r('sys.color.ohos_id_color_list_separator') })
    }
  }

  @Builder
  colorCircle(color: Resource, index: number) {
    Column()
      .height(28)
      .width(56)
      .backgroundColor(color)
      .borderRadius(14)
      .onClick(() => {
        this.context.resourceManager.getColor(color.id).then((value) => {
          // 转成16进制
          let colorStr = '#' + value.toString(16).substring(2)
          this.readerSetting.themeColor = colorStr
          this.readerComponentController.setPageConfig(this.readerSetting)
          this.selectState.colorSelectedIndex = index;
        })
      })
      .borderColor($r('sys.color.ohos_fa_handup'))
      .borderWidth(this.selectState.colorSelectedIndex === index ? 0.1 : 0)
  }

  @Builder
  buildModifyColor() {
    Column() {
      // 亮度调整
      this.buildLightModifySlider();

      Row() {
        Text('系统亮度')

        Toggle({ type: ToggleType.Switch, isOn: $$this.autoLight })
          .onChange(async (isOn) => {
            const windowClass = await this.getWindowClass();
            if (isOn) {
              windowClass?.setWindowBrightness(-1)
            } else {
              windowClass?.setWindowBrightness(this.screenLight);
            }
          })
      }

    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .padding({ top: 10, left: 18, right: 18 })
    .height(130)
  }

  build() {
    Column() {
      if (this.isShowLight) {
        this.buildModifyColor();
      }

      if (this.isShowSetTool) {
        this.buildSettingSheet();
      }

      Row() {
        Column({ space: 2 }) {
          Image($r('app.media.ic_public_lists'))
            .width(24)
            .height(24)

          Text('目录')
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        }
        .onClick(() => {
          baseActionSheet.show({
            id: 'catalog',
            title: { title: '目录' },
            height: SheetSize.FIT_CONTENT,
            preferType: SheetType.BOTTOM,
            customContent: () => {
              this.buildCatalogCard()
            },
          })
        })

        Column({ space: 2 }) {
          Image($r('app.media.ic_light'))
            .width(24)
            .height(24)

          Text('亮度')
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        }
        .onClick(() => {
          this.isShowSetTool = false
          this.isShowLight = !this.isShowLight
        })

        Column({ space: 2 }) {
          Image($r('app.media.night_mode'))
            .width(24)
            .height(24)

          Text(this.nightMode ? '日间' : '夜间')
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        }
        .onClick(() => {
          this.nightMode = !this.nightMode
          this.readerSetting.nightMode = this.nightMode
          if (this.nightMode) {
            this.selectState.colorSelectedIndex = 0
            this.readerSetting.fontColor = 'rgba(255,255,255,0.60)'
            this.readerSetting.themeColor = '#000000'
            this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
          } else {
            this.readerSetting.fontColor = 'rgba(0,0,0,0.90)'
            this.readerSetting.themeColor = 'rgba(251, 240, 219, 1)'
            this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
          }
          this.readerComponentController.setPageConfig(this.readerSetting)
        })

        Column({ space: 2 }) {
          Image($r('app.media.book_setting'))
            .width(24)
            .height(24)

          Text('设置')
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        }
        .id('reader_tool_bar_settings_trigger')
        .onClick(() => {
          this.isShowSetTool = !this.isShowSetTool
          this.isShowLight = false
        })
      }
      .width('100%')
      .padding({
        left: 25,
        right: 25,
        bottom: 30,
        top: 15
      })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .borderRadius((this.isShowSetTool || this.isShowLight) ? { topLeft: 16, topRight: 16 } : 0)
    .width('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .align(Alignment.BottomEnd)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
