import { Constants, NavHeaderBar, TCRouter, UserInfoUtil,
  AggregatedPaymentPicker, ChannelType, MockApi, MemberPackage } from 'common';
import { promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { MemberCenterVM } from '../viewmodel/MemberCenterVM';

const MEMBER_CENTER_PAGE_ROOT_ID = 'member_center_page_root';
const MEMBER_CENTER_PACKAGE_CARD_PREFIX = 'member_center_package_card_';
const MEMBER_CENTER_AGREEMENT_CHECKBOX_ID = 'member_center_agreement_checkbox';
const MEMBER_CENTER_AGREEMENT_LINK_ID = 'member_center_agreement_link';
const MEMBER_CENTER_OPEN_NOW_BUTTON_ID = 'member_center_open_now';

@Preview
@ComponentV2
export struct MemberCenterPage {
  vm: MemberCenterVM = new MemberCenterVM();

  aboutToAppear(): void {
    this.vm.getMemberPackages();
  }

  updateMembership() {
    // 使用新的UserInfoUtil更新会员状态
    UserInfoUtil.updateMembership();
    // 触发事件通知其他页面更新会员状态
    emitter.emit(Constants.LOGIN_CHANGE);
  }

  build() {
    NavDestination() {
      Stack() {
        Image($r('app.media.bg'))
          .width(Constants.FULL_SIZE)
          .height(180)
          .backgroundColor('#F0F2F5');

        Column() {
          NavHeaderBar({
            title: $r('app.string.member_center'),
            hasBackButton: true,
            hasBgColor: false,
            isMainPage: false,
          })

          Column({ space: 8 }) {
            Text($r('app.string.member_packages'))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
              .alignSelf(ItemAlign.Start)

            List({ space: 8 }) {
              ForEach(this.vm.memberPackages, (item: MemberPackage) => {
                ListItem() {
                  Column() {
                    Column() {
                      Text(item.title)
                        .fontSize(15)
                        .fontWeight(FontWeight.Medium)
                        .fontColor($r('sys.color.font_primary'))
                      Text() {
                        Span('￥').fontSize(10)
                        Span(item.price.toString()).fontWeight(FontWeight.Bold)
                      }
                      .fontSize(16)
                      .fontColor(this.vm.selectId === item.id ? '#562E15' : $r('sys.color.font_primary'))
                      .margin({ top: 6 })
                    }
                    .backgroundColor(this.vm.selectId === item.id ? '#FFFCF2' : $r('sys.color.background_primary'))
                    .padding({ top: 16, bottom: 18 })
                    .width(104)

                    Text(item.description)
                      .fontSize(12)
                      .fontColor(this.vm.selectId === item.id ? '#562E15' : $r('sys.color.font_primary'))
                      .width(104)
                      .height(26)
                      .backgroundColor(this.vm.selectId === item.id ? '#F8E6CE' : '#0D000000')
                      .textAlign(TextAlign.Center)
                  }
                  .id(MEMBER_CENTER_PACKAGE_CARD_PREFIX + item.id.toString())
                  .clip(true)
                  .border({
                    width: this.vm.selectId === item.id ? 2 : 1,
                    color: this.vm.selectId === item.id ? '#F8E6CE' : '#0D000000',
                    radius: 8,
                  })
                  .onClick(() => {
                    this.vm.selectId = item.id;
                  })
                }
              }, (item: MemberPackage) => item.id.toString())
            }
            .listDirection(Axis.Horizontal)
            .height(124)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .clip(false)
            .width(Constants.FULL_SIZE)
          }
          .width(Constants.FULL_SIZE)
          .height(172)
          .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 0, bottomRight: 0 })
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          .position({ x: 0, y: 100 })
          .alignItems(HorizontalAlign.Start)
          .clip(false)

          Column({ space: 16 }) {
            Text($r('app.string.member_privileges'))
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))

            Column({ space: 16 }) {
              Row() {
                Image($r('app.media.ad'))
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .fillColor('#E3922F')
                Column() {
                  Text($r('app.string.no_ads'))
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                  Text($r('app.string.no_ads_desc'))
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 8 })
              }

              Row() {
                Image($r('app.media.ask'))
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .fillColor('#E3922F')
                Column() {
                  Text($r('app.string.priority_consultation'))
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                  Text($r('app.string.priority_consultation_desc'))
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 8 })
              }

              Row() {
                Image($r('app.media.cs'))
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .fillColor('#E3922F')
                Column() {
                  Text($r('app.string.exclusive_service'))
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                  Text($r('app.string.exclusive_service_desc'))
                    .fontSize(12)
                    .fontColor($r('sys.color.font_secondary'))
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 8 })
              }
            }
            .width('100%')
            .padding(12)
            .border({ width: 1, color: '#E39331', radius: 16 })
            .alignItems(HorizontalAlign.Start)
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 200 })
        }
        .id(MEMBER_CENTER_PAGE_ROOT_ID)
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.Start)
        .height(Constants.FULL_SIZE)

        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Checkbox({ name: `1`, group: `membershipPrivacy` })
              .id(MEMBER_CENTER_AGREEMENT_CHECKBOX_ID)
              .select($$this.vm.selectCheckbox)
              .height(24)
              .width(24)
              .selectedColor('#E39331')
              .shape(CheckBoxShape.CIRCLE)

            Row({ space: 4 }) {
              Text($r('app.string.agree_member_agreement'))
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))

              Text($r('app.string.member_agreement'))
                .id(MEMBER_CENTER_AGREEMENT_LINK_ID)
                .fontSize(12)
                .fontColor('#E39331')
                .onClick(() => {
                  TCRouter.push(Constants.MEMBER_AGREEMENT_ROUTE);
                })
            }
          }

          Button($r('app.string.open_now'))
            .id(MEMBER_CENTER_OPEN_NOW_BUTTON_ID)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('#E39331')
            .width(Constants.FULL_SIZE)
            .bindSheet($$this.vm.isShow, this.paymentChannelSheet(),
              { showClose: false, height: '45%' })
            .onClick(() => {
              if (!this.vm.selectCheckbox) {
                promptAction.showToast({ message: $r('app.string.agree_member_agreement_tip') });
                return;
              }

              // 获取各支付方式的预下单信息
              this.vm.wxOrderReq = MockApi.getWxPreOrderInfo();
              this.vm.hwOrderStr = MockApi.getHuaweiOrderInfo();
              MockApi.getAliPreOrderInfo().then((res) => {
                this.vm.aliOrderStr = res;
                this.vm.isShow = true;
              });
            })
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 34 })
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: -126 })
        .width(Constants.FULL_SIZE)
      }
      .alignContent(Alignment.Top)
    }
    .hideTitleBar(true)
  }

  @Builder
  paymentChannelSheet() {
    AggregatedPaymentPicker({
      amount: this.vm.memberPackages.find(pkg => pkg.id === this.vm.selectId)?.price || 0,
      channelInfo: [{
        channelType: ChannelType.HUAWEI_PAY,
        name: '华为支付',
        icon: $r('app.media.hwpay'),
        preOrderInfo: this.vm.hwOrderStr,
      }, {
        channelType: ChannelType.WECHAT_PAY,
        preOrderInfo: this.vm.wxOrderReq,
        appId: MockApi.WX_APP_ID,
        icon: $r('app.media.wechat'),
        name: '微信支付',
        event: () => {
          this.vm.isShow = false;
        },
      }, {
        channelType: ChannelType.ALI_PAY,
        name: '支付宝支付',
        icon: $r('app.media.alipay'),
        preOrderInfo: this.vm.aliOrderStr,
      }],
      paySuccessEvent: (type: ChannelType) => {
        promptAction.showToast({
          message: '支付成功~',
          duration: 2000,
        });
        this.updateMembership();
        TCRouter.pop();
        this.vm.isShow = false;
      },
    });
  }
}
