import { StickerShowModel } from 'common';
import { StickerModel } from '../model/BeautificationParam';
import { Constants } from '../model/Constants';
import { JSON, util } from '@kit.ArkTS';

@Component
export struct StickerToolBar {
  @Link barIndex: number
  @State stickerTabIndex: number = 0;
  private stickerController: TabsController = new TabsController();
  @State searchList: StickerShowModel[] = []
  @Prop testSearchList: StickerShowModel[] = []
  @Link stickerList: StickerModel[]
  saveImage?: () => void
  @StorageProp('isVip') @Watch('vipChange') isVip: boolean = false
  @StorageProp('loginState') loginState: boolean = false;
  pathStack: NavPathStack = new NavPathStack()
  vipDialogController?: CustomDialogController
  @State wantSticker?: StickerModel = undefined

  build() {
    Column() {
      Row() {
        Image($r('app.media.xmark'))
          .width(24)
          .height(24)
          .id('sticker_toolbar_close_btn')
          .margin({ left: 16 })
          .onClick(() => {
            this.barIndex = -1
            this.cleanSticker()
          })
        Text('2.5D贴纸')
          .fontSize(16)
          .id('sticker_toolbar_title')
        Image($r('app.media.checkMark'))
          .width(24)
          .height(24)
          .id('sticker_toolbar_save_btn')
          .margin({ right: 16 })
          .onClick(() => {
            if (this.saveImage) {
              this.saveImage()
            }
            this.cleanSticker()
          })
      }
      .width('100%')
      .margin({ top: 14, bottom: 24 })
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row({ space: 24 }) {
          ForEach(Constants.stickerTagList, (item: string, index: number) => {
            Text(item)
              .fontSize(16)
              .id(`sticker_tab_title_${index}`)
              .fontColor(this.stickerTabIndex === index ? '#ED6F21' : Color.Black)
              .onClick(() => {
                this.stickerTabIndex = index
                this.stickerController.changeIndex(index);
              })
          }, (item: string) => item)
        }
        .margin({ left: 16, right: 16 })
      }
      .width('100%')
      .height(22)
      .margin({ left: 16, right: 16 })

      Tabs({ barPosition: BarPosition.Start, controller: this.stickerController }) {
        ForEach(Constants.stickerTagList, (item: string, index: number) => {
          TabContent() {
            this.stickerContentBuilder(this.getList(item), index)
          }
        }, (item: string) => item)
      }
      .height(180)
      .barHeight(0)

      Row() {
        Grid() {
          ForEach(this.searchList, (item: StickerShowModel, index: number) => {
            GridItem() {
              Stack() {
                Image(item.imageSource)
                  .height(68)
                Image($r('app.media.image_vip'))
                  .width(16)
                  .height(16)
                  .visibility(item.isVip ? Visibility.Visible : Visibility.None)
              }
              .height(68)
              .id(`sticker_search_item_${index}`)
              .backgroundColor($r('app.color.main_background_color'))
              .borderRadius(8)
              .alignContent(Alignment.BottomStart)
              .onClick(() => {
                if (item.isVip) {
                  if (!this.loginState) {
                    this.pathStack.pushPath({ name: 'quickLoginPage' })
                  } else {
                    if (!this.isVip) {
                      this.wantSticker = {
                        id: util.generateRandomUUID(),
                        positionX: 0,
                        positionY: 0,
                        img: item.imageSource
                      }
                      this.vipDialogController?.open()
                    } else {
                      this.stickerList.push({
                        id: util.generateRandomUUID(),
                        positionX: 0,
                        positionY: 0,
                        img: item.imageSource
                      })
                    }
                  }
                } else {
                  this.stickerList.push({
                    id: util.generateRandomUUID(),
                    positionX: 0,
                    positionY: 0,
                    img: item.imageSource
                  })
                }
              })
            }
          }, (item: StickerShowModel) => JSON.stringify(item))
        }
        .id('sticker_search_grid')
        .height(152)
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsGap(16)
        .columnsGap(19)
        .margin({ left: 16, right: 16 })
      }
      .height(180)
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius({ topLeft: 16, topRight: 16 })
  }

  @Builder
  stickerContentBuilder(list: StickerShowModel[], tabIndex: number) {
    Grid() {
      ForEach(list, (item: StickerShowModel, index: number) => {
        GridItem() {
          Stack() {
            Image(item.imageSource)
              .height(68)
            Image($r('app.media.image_vip'))
              .width(16)
              .height(16)
              .visibility(item.isVip ? Visibility.Visible : Visibility.None)
          }
          .height(68)
          .id(`sticker_tab_item_${tabIndex}_${index}`)
          .backgroundColor($r('app.color.main_background_color'))
          .borderRadius(8)
          .alignContent(Alignment.BottomStart)
          .onClick(() => {
            if (item.isVip) {
              if (!this.loginState) {
                this.pathStack.pushPath({ name: 'quickLoginPage' })
              } else {
                if (!this.isVip) {
                  this.wantSticker = {
                    id: util.generateRandomUUID(),
                    positionX: 0,
                    positionY: 0,
                    img: item.imageSource
                  }
                  this.vipDialogController?.open()
                } else {
                  this.stickerList.push({
                    id: util.generateRandomUUID(),
                    positionX: 0,
                    positionY: 0,
                    img: item.imageSource
                  })
                }
              }
            } else {
              this.stickerList.push({
                id: util.generateRandomUUID(),
                positionX: 0,
                positionY: 0,
                img: item.imageSource
              })
            }
          })
        }
      }, (item: StickerShowModel) => JSON.stringify(item))
    }
    .id(`sticker_tab_grid_${tabIndex}`)
    .height(152)
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsGap(16)
    .columnsGap(19)
    .margin({ left: 16, right: 16 })
  }

  aboutToAppear() {
    if (this.testSearchList.length > 0) {
      this.searchList = this.testSearchList
    }
  }

  getList(tag?: string): StickerShowModel[] {
    let list: StickerShowModel[] = []
    if (tag) {
      list = Constants.stickerList.filter((item) => item.tag.includes(tag))
      return list
    }
    return list
  }

  cleanSticker() {
    this.stickerTabIndex = 0;
    this.stickerList = []
  }

  vipChange() {
    if (this.isVip && this.wantSticker) {
      this.stickerList.push(this.wantSticker)
      this.wantSticker = undefined
    }
  }
}
