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

import { AppStorageV2 } from '@kit.ArkUI';
import { OrderInfo, OrderState, SampleOrderInfo, SampleCollectInfo, TopTabsBuilder } from 'commonlib'
import { RouterMap, RouterModule } from 'router_module'
import { MyDataSource, GoodCourse } from '../viewModel/CourseHomeModel'
import { UserInfo } from 'login_info';

@ComponentV2
export struct GoodCourseDetailPage {
  private swiperController: SwiperController = new SwiperController();
  private data: MyDataSource = new MyDataSource([]);
  @Local goodCourse: GoodCourse =
    new GoodCourse('111', false, '一级建造师精华题库中级班', $r('app.media.ic_avatar'), '华为用户',
      '更新时间：2025-04-16',
      '课程简介：适合零基础学习人员使用，配置资料提供下载', '全部科目：13个科目', '有效期限：不限制')
  @Local isShow: boolean = false
  @Local prop: SampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
  @Local propCollect: SampleCollectInfo = AppStorageV2.connect(SampleCollectInfo, () => new SampleCollectInfo())!;
  @Local logoUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  courseName: string = '';

  aboutToAppear(): void {
    let list: string[] = [];
    list.push('app.media.ic_questionDetail_banner')
    list.push('app.media.ic_questionDetail_banner')
    list.push('app.media.ic_questionDetail_banner')
    list.push('app.media.ic_questionDetail_banner')
    list.push('app.media.ic_questionDetail_banner')
    this.data = new MyDataSource(list);
    // 获取科目名称
    let temp: OrderInfo | string | undefined = RouterModule.getNavParam({ url: RouterMap.GOOD_COURSE_DETAIL_PAGE })
    if (temp) {
      if (temp instanceof OrderInfo) {
        this.courseName = temp.content
        this.goodCourse.id = temp.id
      } else {
        this.courseName = temp
      }
    }
    //匹配收藏课程 的ID 是否收藏
    this.propCollect.orderInfos.forEach((it: OrderInfo) => {
      if (it.id === this.goodCourse.id) {
        this.goodCourse.isCollect = true
      }
    })
  }

  @Builder
  topBuilder() {
    Row() {
      Row() {
        Row() {
          Image($r('app.media.ic_backward')).width(30).height(30).margin({ right: 10 })
            .onClick(() => {
              RouterModule.pop()
            })
        }
      }.justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Row() {
        Image($r('app.media.icon_search'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .margin({ right: $r('app.float.vp_10') })
        Image($r('app.media.ic_more')).width($r('app.float.vp_40')).height($r('app.float.vp_40'))
      }.justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .padding({ left: 16, right: 16 })
    .height(56)
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  swiperBuilder() {
    Swiper(this.swiperController) {
      LazyForEach(this.data, (item: string) => {
        Image($r(item)).width('100%').height(190)
          .interpolation(ImageInterpolation.High)
      }, (item: string) => item)
    }
    .cachedCount(2)
    .margin({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_12') })
    .index(1)
    .autoPlay(true)
    .interval(3000)
    .loop(true)
    .duration(1000)
    .itemSpace(0)
    .indicator( // 设置圆点导航点样式
      new DotIndicator()
        .itemWidth($r('app.float.vp_8'))
        .itemHeight($r('app.float.vp_8'))
        .selectedItemWidth($r('app.float.vp_16'))
        .selectedItemHeight($r('app.float.vp_8'))
        .color(Color.Gray)
        .selectedColor(Color.Blue)
        .maxDisplayCount(9))
    .curve(Curve.Linear)
  }

  @Builder
  subjectBuilder() {
    Column() {
      Text(this.courseName !== '' ? this.courseName : this.goodCourse.title)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('app.float.vp_25') })
      Row() {
        Image(this.goodCourse.icon)
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .margin({ right: $r('app.float.vp_4') })
        Column() {
          Text(this.goodCourse.name).fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: $r('app.float.vp_4') })
          Text(this.goodCourse.time).fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .margin({ bottom: $r('app.float.vp_16') })
        }.alignItems(HorizontalAlign.Start)
      }.width('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Top)

      Text(this.goodCourse.introduction)
        .fontColor($r('sys.color.font_secondary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .width('100%')
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular)
        .margin({ top: $r('app.float.vp_12') })
      Text(this.goodCourse.allSubject)
        .fontColor($r('sys.color.font_secondary'))
        .width('100%')
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular)
        .margin({ top: $r('app.float.vp_2'), bottom: $r('app.float.vp_2') })
      Text(this.goodCourse.effectTime).fontColor($r('sys.color.font_secondary'))
        .width('100%')
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular)
    }
    .width('100%')
    .padding($r('app.float.vp_12'))
    .borderRadius($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.background_primary'))
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  selectBuilder() {
    Row() {
      Row() {
        Column() {
          Image($r('app.media.ic_share'))
            .width($r('app.float.vp_20'))
            .height($r('app.float.vp_20'))
            .margin({ bottom: $r('app.float.vp_2') })
          Text('分享')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Medium)
        }.margin({ right: $r('app.float.vp_8') })
        .onClick(() => {
          this.showToast('暂不支持分享')
        })

        Column() {
          Image(this.goodCourse.isCollect ? $r('app.media.ic_star') : $r('app.media.icon_star'))
            .width($r('app.float.vp_20'))
            .height($r('app.float.vp_20'))
            .margin({ bottom: $r('app.float.vp_4') })
          Text('收藏')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Medium)
        }.onClick(() => {
          if (!this.logoUser.isLogin) {
            RouterModule.push({ url: RouterMap.LOGIN_PAGE })
            return
          }
          this.goodCourse.isCollect = !this.goodCourse.isCollect
          // 如果未收藏 加入收藏
          if (this.goodCourse.isCollect) {
            let orderNo = '202506' + Date.now()
            let content = this.courseName
            let orderInfo =
              new OrderInfo(this.goodCourse.id, this.goodCourse.isCollect, OrderState.All, orderNo, content, false)
            this.propCollect.orderInfos.unshift(orderInfo)
            this.showToast('收藏成功~');
          } else {
            this.propCollect.orderInfos = this.propCollect.orderInfos.filter((it: OrderInfo) => {
              return it.id !== this.goodCourse.id
            })
            this.showToast('取消收藏~');
          }
        })
      }.justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Text('￥288 立即购买')
        .padding({
          left: $r('app.float.vp_20'),
          right: $r('app.float.vp_20'),
          top: $r('app.float.vp_8'),
          bottom: $r('app.float.vp_8')
        })
        .width('80%')
        .textAlign(TextAlign.Center)
        .borderRadius($r('app.float.vp_20'))
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor('rgb(232, 64, 38)')
        .bindSheet(this.isShow, this.paymentChannelSheet(),
          {
            height: '65%',
            onDisappear: () => {
              this.isShow = false
            }
          })
        .onClick(() => {
          if (this.logoUser.isLogin) {
            this.isShow = true
          } else {
            RouterModule.push({ url: RouterMap.LOGIN_PAGE })
          }
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_6'),
      bottom: $r('app.float.vp_6')
    })
    .width('100%')
    .height($r('app.float.vp_56'))
    .backgroundColor($r('sys.color.background_primary'))
  }

  // 课程详情
  @Builder
  courseDetailsBuilder() {
    Row() {
      Text('课程详情')
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)
    }.width('100%')
    .padding({ top: $r('app.float.vp_16'), bottom: $r('app.float.vp_16') })
    .justifyContent(FlexAlign.Center)

    // 课程详情图片
    Image($r('app.media.icon_courseDetail'))
      .interpolation(ImageInterpolation.High)
      .width('100%')
      .objectFit(ImageFit.Cover)
      .margin({ bottom: $r('app.float.vp_16') })
  }

  @Builder
  paymentChannelSheet() {
    Column({ space: $r('app.float.vp_12') }) {
      Text('Payment Method')
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)

      Button('Pay Success (Mock)')
        .width('100%')
        .onClick(() => {
          this.onPayResult(true)
        })

      Button('Pay Fail (Mock)')
        .width('100%')
        .onClick(() => {
          this.onPayResult(false)
        })
    }
    .width('100%')
    .padding($r('app.float.vp_16'))
  }

  private onPayResult(success: boolean): void {
    let sampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
    let orderNo = '202506' + Date.now()
    let content = this.courseName
    let state: OrderState = success ? OrderState.Paid : OrderState.WaitToPay
    let orderInfo = new OrderInfo(this.goodCourse.id, this.goodCourse.isCollect, state, orderNo, content, false)
    if (!success) {
      orderInfo.startTime = Date.now()
      sampleOrderInfo.orderInfos.push(orderInfo)
      AppStorageV2.connect(SampleOrderInfo, () => sampleOrderInfo)!;
      this.showToast('Payment failed~');
    } else {
      sampleOrderInfo.orderInfos.unshift(orderInfo)
      this.showToast('Payment succeeded~');
    }
    RouterModule.pop();
    this.isShow = false;
  }

  showToast(message: string) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 2000
      });
    } catch (error) {
      //在此处进行异常处理
    }
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        // 标题
        TopTabsBuilder({ bgColor: $r('sys.color.background_primary'), showBackButton: true })
          .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), bottom: $r('app.float.vp_12') })
        // 滚动详情页
        Scroll() {
          Column() {
            // banner
            this.swiperBuilder()
            // 科目
            this.subjectBuilder()
            // 课程详情
            this.courseDetailsBuilder()
          }
          .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), top: $r('app.float.vp_12') })
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
        }
        .backgroundColor($r('sys.color.comp_background_gray'))
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        // 收藏分享、支付
        this.selectBuilder()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
  }
}

@Builder
export function GoodCourseDetailBuilder() {
  GoodCourseDetailPage()
}
