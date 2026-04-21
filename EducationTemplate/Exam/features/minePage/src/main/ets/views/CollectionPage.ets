/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AppStorageV2, } from '@kit.ArkUI';
import { SampleCollectInfo, OrderInfo, Logger, TopBar } from 'commonlib';
import { RouterMap, RouterModule } from 'router_module';

const TAG = 'CollectionPage';
const COLLECTION_PAGE_ROOT_ID: string = 'collection_page_root';
const COLLECTION_PAGE_EMPTY_TEXT_ID: string = 'collection_page_empty_text';
const COLLECTION_PAGE_LIST_ID: string = 'collection_page_list';

@ComponentV2
export struct CollectionPage {
  @Local isSelectDelete: boolean = false;
  @Local swiperDelete: boolean = false
  @Local isSelectAll: boolean = false
  @Local selectCount: number = 0
  @Local propCollect: SampleCollectInfo = AppStorageV2.connect(SampleCollectInfo, () => new SampleCollectInfo())!;
  @Param onDisappearEvent: () => void = () => {
  };

  aboutToDisappear(): void {
    Logger.info(TAG, 'aboutToDisappear')
    this.onDisappearEvent();
  }

  build() {
    Column() {
      // 顶部
      this.topBuilder();
      Divider().color($r('sys.color.comp_divider'))
      Column() {
        if (this.propCollect.orderInfos.length > 0) {
          // 收藏列表
          this.collectListBuilder()
          // 删除按钮
          this.deleteButtonBuilder()
        } else {
          Text('当前暂无收藏的课程。')
            .id(COLLECTION_PAGE_EMPTY_TEXT_ID)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.icon_secondary'))
            .height('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .id(COLLECTION_PAGE_ROOT_ID)
    .width('100%')
    .height('100%')
  }

  /**
   * 删除按钮
   */
  @Builder
  deleteButtonBuilder() {
    if (this.isSelectDelete) {
      Row() {
        Image($r('app.media.icon_delete'))
          .width($r('app.float.vp_24'))
          .height($r('app.float.vp_24'))
        Text('删除')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .margin({ left: $r('app.float.vp_8') })
      }
      .width($r('app.float.vp_312'))
      .justifyContent(FlexAlign.Center)
      .borderRadius(20)
      .padding({ top: $r('app.float.vp_8'), bottom: $r('app.float.vp_8') })
      .backgroundColor('#4c5dc4')
      .opacity(this.selectCount > 0 ? 1 : 0.4)
      .onClick(() => {
        if (this.selectCount > 0) {
          // 删除选中
          this.deleteSelectData()
        }
      })
    }
  }

  // 移除所选中的
  deleteSelectData() {
    this.propCollect.orderInfos = this.propCollect.orderInfos.filter((it: OrderInfo) => it.isDelete === false)
    this.isSelectDelete = false
  }

  // 是否全选
  isSelectAllClick() {
    if (!this.isSelectAll) {
      this.propCollect.orderInfos.forEach((item: OrderInfo) => {
        item.isDelete = true;
      })
      this.selectCount = this.propCollect.orderInfos.length;
      this.isSelectAll = true
    } else {
      this.propCollect.orderInfos.forEach((item: OrderInfo) => {
        item.isDelete = false;
      })
      this.selectCount = 0
      this.isSelectAll = false
    }
  }

  /**
   * 收藏列表
   */
  @Builder
  collectListBuilder() {
    List({ space: 8 }) {
      ForEach(this.propCollect.orderInfos, ((item: OrderInfo, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Image($r('app.media.ic_avatar'))
                .width($r('app.float.vp_24'))
                .margin({ right: '12vp' })
                .height($r('app.float.vp_24'))
              Text('华为用户')
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
              Blank()
              // 父组件 点击右上角删除按钮显示  否则不显示
              if (this.isSelectDelete) {
                Row() {
                  Image(item.isDelete ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
                    .width($r('app.float.vp_20'))
                    .margin({ right: $r('app.float.vp_8') })
                    .height($r('app.float.vp_20'))
                }
                .height($r('app.float.vp_24'))
                .onClick(() => {
                  item.isDelete = !item.isDelete
                  if (item.isDelete) {
                    this.selectCount++;
                  } else {
                    this.selectCount--;
                  }
                  if (this.selectCount < this.propCollect.orderInfos.length) {
                    this.isSelectAll = false
                  } else {
                    this.isSelectAll = true
                  }
                })
              }
            }
            .padding({ left: '12vp' })
            .width('100%')
            .height('24vp')

            Column() {
              Row() {
                Text(item.content)
                  .width('100%')
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.Body_M'))
              }
              .width('100%')
              .margin({ top: '12vp', bottom: '2vp' })
              .justifyContent(FlexAlign.Start)

              Row() {
                Column() {
                  Text(`￥${item.price}`)
                    .fontSize($r('sys.float.Title_S'))
                    .fontColor($r('sys.color.multi_color_08'))
                    .textAlign(TextAlign.Start)
                    .fontWeight(FontWeight.Medium)
                    .width('100%')
                  Text(`已有 ${item.buyNumbers}人 购买`)
                    .fontSize($r('sys.float.Body_S'))
                    .fontWeight(FontWeight.Lighter)
                    .textAlign(TextAlign.Start)
                    .fontColor('rgb(2, 2, 3)')
                    .width('100%')
                }
                .justifyContent(FlexAlign.Start)
                .width('50%')

                Column() {
                  Row() {
                    Button('查看详情')
                      .fontSize($r('sys.float.Body_M'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.system_color_background_white'))
                      .backgroundColor('#4B5CC4')
                      .fontWeight(FontWeight.Bold)
                      .onClick(() => {
                        RouterModule.push({ url: RouterMap.GOOD_COURSE_DETAIL_PAGE, param: item })
                      })
                  }.width('100%')
                  .justifyContent(FlexAlign.End)
                }
                .width('50%')
              }
              .height('auto')
              .width('100%')
            }
            .width('100%')
            .padding({ left: '24vp', right: '24vp' })
          }
          .borderRadius(16)
          .padding({ top: '16vp', bottom: '16vp' })
          .height('138vp')
          .backgroundColor($r('sys.color.background_primary'))
          .width('100%')
        }
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .margin({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.collectItemEnd(index)
            },
            actionAreaDistance: 26,
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.swiperDelete = true
                this.isSelectDelete = false
              } else if (state === SwipeActionState.COLLAPSED) {
                this.swiperDelete = false
              }
            },
          }
        })
      }), (item: OrderInfo, index: number) => item.orderNo + index)
    }
    .id(COLLECTION_PAGE_LIST_ID)
    .width('100%')
    .scrollBar(BarState.Off)
    .padding({
      top: $r('app.float.vp_20'),
      bottom: $r('app.float.vp_46')
    })
  }

  @Builder
  collectItemEnd(index: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .margin({ left: $r('app.float.vp_12') })
        .height($r('app.float.vp_24'))
        .width($r('app.float.vp_24'))
        .onClick(() => {
          this.propCollect.orderInfos.splice(index, 1)
          this.swiperDelete = false
        })
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .padding($r('app.float.vp_4'))
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      TopBar({
        onClickBack: () => {
          RouterModule.pop()
        },
        title: '我的收藏'
      })
      Row() {
        Image(this.isSelectAll ? $r('app.media.icon_select_all') : $r('app.media.icon_select_all_off'))
          .height($r('app.float.vp_40'))
          .width($r('app.float.vp_40'))
          .onClick(() => {
            this.isSelectAllClick()
          })
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden)
        Image($r('app.media.ic_public_trash'))
          .height($r('app.float.vp_40'))
          .opacity(this.propCollect.orderInfos.length === 0 || this.swiperDelete ? 0.4 : 1)
          .margin({ left: $r('app.float.vp_8') })
          .width($r('app.float.vp_40'))
      }
      .onClick(() => {
        if (!this.swiperDelete && this.propCollect.orderInfos.length > 0) {
          this.isSelectDelete = !this.isSelectDelete
          if (!this.isSelectDelete) {
            this.selectCount = 0
            this.isSelectAll = false
            this.propCollect.orderInfos.forEach((item: OrderInfo) => {
              item.isDelete = false;
            })
          }
        }
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
  }
}

@Builder
export function CollectionBuilder() {
  CollectionPage()
}



