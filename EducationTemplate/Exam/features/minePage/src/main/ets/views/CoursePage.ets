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
import { SampleOrderInfo, OrderInfo, Logger, TopBar } from 'commonlib';
import { RouterMap, RouterModule } from 'router_module';

const TAG = 'CoursePage';
const COURSE_PAGE_ROOT_ID: string = 'course_page_root';
const COURSE_PAGE_EMPTY_TEXT_ID: string = 'course_page_empty_text';
const COURSE_PAGE_LIST_ID: string = 'course_page_list';
const COURSE_PAGE_DELETE_BUTTON_ID: string = 'course_page_delete_button';
const COURSE_PAGE_DELETE_TOGGLE_ID: string = 'course_page_delete_toggle';
const COURSE_PAGE_SELECT_ALL_ID: string = 'course_page_select_all_toggle';
const COURSE_PAGE_ITEM_CONTENT_PREFIX: string = 'course_page_item_content_';
const COURSE_PAGE_ITEM_PRICE_PREFIX: string = 'course_page_item_price_';
const COURSE_PAGE_ITEM_BUYERS_PREFIX: string = 'course_page_item_buyers_';
const COURSE_PAGE_ITEM_DETAIL_BUTTON_PREFIX: string = 'course_page_item_detail_button_';

@ComponentV2
export struct CoursePage {
  @Local isSelectDelete: boolean = false;
  @Local swiperDel: boolean = false
  @Local isSelectAll: boolean = false
  @Local selectCount: number = 0
  // 在AppStorageV2中创建一个key为Sample的键值对（如果存在，则返回AppStorageV2中的数据），并且和prop关联
  @Local propOrderInfo: SampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;

  aboutToDisappear(): void {
    Logger.info(TAG, 'aboutToDisappear')
  }

  build() {
    Column() {
      // 顶部
      this.topBuilder();
      Divider().color($r('sys.color.comp_divider'))
      Column() {
        if (this.propOrderInfo.orderInfos.length > 0) {
          // 我的课程列表
          this.orderInfosBuilder()
          // 删除按钮
          this.deleteButtonBuilder()
        } else {
          Text('当前暂无课程。')
            .id(COURSE_PAGE_EMPTY_TEXT_ID)
            .fontColor($r('sys.color.icon_secondary'))
            .fontSize($r('sys.float.Body_S'))
            .height('100%')
        }
      }
      .height('100%')
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .id(COURSE_PAGE_ROOT_ID)
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
          .height($r('app.float.vp_24'))
          .width($r('app.float.vp_24'))
        Text('删除')
          .fontColor($r('sys.color.font_on_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .margin({ left: $r('app.float.vp_8') })
      }
      .width($r('app.float.vp_312'))
      .id(COURSE_PAGE_DELETE_BUTTON_ID)
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
    this.isSelectDelete = false
    this.propOrderInfo.orderInfos = this.propOrderInfo.orderInfos.filter((it: OrderInfo) => it.isDelete === false)
  }

  // 是否全选
  isSelectAllClick() {
    if (!this.isSelectAll) {
      this.propOrderInfo.orderInfos.forEach((item: OrderInfo) => {
        item.isDelete = true;
      })
      this.selectCount = this.propOrderInfo.orderInfos.length;
      this.isSelectAll = true
    } else {
      this.propOrderInfo.orderInfos.forEach((item: OrderInfo) => {
        item.isDelete = false;
      })
      this.selectCount = 0
      this.isSelectAll = false
    }
  }

  /**
   * 我的课程列表
   */
  @Builder
  orderInfosBuilder() {
    List({ space: 8 }) {
      ForEach(this.propOrderInfo.orderInfos, ((item: OrderInfo, index: number) => {
        ListItem() {
          Column() {
            Row() {
              Image($r('app.media.ic_avatar'))
                .height($r('app.float.vp_24'))
                .width($r('app.float.vp_24'))
                .margin({ right: '12vp' })
              Text('华为用户')
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
              Blank()
              // 父组件 点击右上角删除按钮显示  否则不显示
              if (this.isSelectDelete) {
                Row() {
                  Image(item.isDelete ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
                    .height($r('app.float.vp_20'))
                    .width($r('app.float.vp_20'))
                    .margin({ right: $r('app.float.vp_8') })
                }
                .id(`course_page_select_item_${index}`)
                .height($r('app.float.vp_24'))
                .onClick(() => {
                  item.isDelete = !item.isDelete
                  if (item.isDelete) {
                    this.selectCount++;
                  } else {
                    this.selectCount--;
                  }
                  if (this.selectCount < this.propOrderInfo.orderInfos.length) {
                    this.isSelectAll = false
                  } else {
                    this.isSelectAll = true
                  }
                })
              }
            }
            .height('24vp')
            .padding({ left: '12vp' })
            .width('100%')

            Column() {
              Row() {
                Text(item.content)
                  .id(`${COURSE_PAGE_ITEM_CONTENT_PREFIX}${index}`)
                  .fontSize($r('sys.float.Body_M'))
                  .width('100%')
                  .fontWeight(FontWeight.Medium)
              }
              .justifyContent(FlexAlign.Start)
              .width('100%')
              .margin({ top: '12vp', bottom: '2vp' })

              Row() {
                Column() {
                  Text(`￥${item.price}`)
                    .fontColor($r('sys.color.multi_color_08'))
                    .id(`${COURSE_PAGE_ITEM_PRICE_PREFIX}${index}`)
                    .fontSize($r('sys.float.Title_S'))
                    .fontWeight(FontWeight.Medium)
                    .textAlign(TextAlign.Start)
                    .width('100%')
                  Text(`已有 ${item.buyNumbers}人 购买`)
                    .id(`${COURSE_PAGE_ITEM_BUYERS_PREFIX}${index}`)
                    .fontWeight(FontWeight.Lighter)
                    .fontSize($r('sys.float.Body_S'))
                    .fontColor('rgb(2, 2, 3)')
                    .textAlign(TextAlign.Start)
                    .width('100%')
                }
                .justifyContent(FlexAlign.Start)
                .width('50%')

                Column() {
                  Row() {
                    Button('查看详情')
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r('sys.float.Body_M'))
                      .id(`${COURSE_PAGE_ITEM_DETAIL_BUTTON_PREFIX}${index}`)
                      .fontColor($r('app.color.system_color_background_white'))
                      .fontWeight(FontWeight.Bold)
                      .backgroundColor('#4B5CC4')
                      .onClick(() => {
                        RouterModule.push({ url: RouterMap.GOOD_COURSE_DETAIL_PAGE, param: item })
                      })
                  }.width('100%')
                  .justifyContent(FlexAlign.End)
                }
                .width('50%')
              }
              .width('100%')
              .height('auto')
            }
            .padding({ left: '24vp', right: '24vp' })
            .width('100%')
          }
          .padding({ top: '16vp', bottom: '16vp' })
          .borderRadius(16)
          .backgroundColor($r('sys.color.background_primary'))
          .height('138vp')
          .width('100%')
        }
        .transition({ type: TransitionType.Delete, opacity: 0 })
        .margin({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), })
        .swipeAction({
          edgeEffect: SwipeEdgeEffect.None,
          end: {
            builder: () => {
              this.courseItemEnd(index)
            },
            actionAreaDistance: 26,
            onStateChange: (state: SwipeActionState) => {
              if (state === SwipeActionState.EXPANDED) {
                this.swiperDel = true
                this.isSelectDelete = false
              } else if (state === SwipeActionState.COLLAPSED) {
                this.swiperDel = false
              }
            },
          }
        })
      }), (item: OrderInfo, index: number) => item.orderNo + index)
    }
    .id(COURSE_PAGE_LIST_ID)
    .scrollBar(BarState.Off)
    .width('100%')
    .padding({
      top: $r('app.float.vp_20'),
      bottom: $r('app.float.vp_46')
    })
  }

  @Builder
  courseItemEnd(index: number) {
    Row() {
      Image($r('app.media.ic_public_trash_red'))
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'))
        .margin({ left: $r('app.float.vp_12') })
        .onClick(() => {
          this.propOrderInfo.orderInfos.splice(index, 1)
        })
    }.padding($r('app.float.vp_4')).justifyContent(FlexAlign.SpaceEvenly)
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
        title: '我的课程'
      })
      Row() {
        Image(this.isSelectAll ? $r('app.media.icon_select_all') : $r('app.media.icon_select_all_off'))
          .id(COURSE_PAGE_SELECT_ALL_ID)
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .onClick(() => {
            this.isSelectAllClick()
          })
          .visibility(this.isSelectDelete ? Visibility.Visible : Visibility.Hidden)
        Image($r('app.media.ic_public_trash'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .opacity(this.swiperDel ? 0.4 : 1)
          .margin({ left: $r('app.float.vp_8') })
      }
      .id(COURSE_PAGE_DELETE_TOGGLE_ID)
      .onClick(() => {
        if (!this.swiperDel && this.propOrderInfo.orderInfos.length > 0) {
          this.isSelectDelete = !this.isSelectDelete
          if (!this.isSelectDelete) {
            this.isSelectAll = false
            this.selectCount = 0
            this.propOrderInfo.orderInfos.forEach((item: OrderInfo) => {
              item.isDelete = false;
            })
          }
        }
      })
    }
    .height($r('app.float.vp_56'))
    .width('100%')
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Builder
export function CoursePageBuilder() {
  CoursePage()
}



