import { Constants, NavHeaderBar, TCRouter,
  AggregatedPaymentPicker, ChannelType, MockApi, RechargePackage, RechargeRecord } from 'common';
import { promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { RechargeVM } from '../viewmodel/RechargeVM';
import { RechargeRecordVM } from '../viewmodel/RechargeRecordVM';
import { UserInfo } from 'base_common';

const RECHARGE_PAGE_ROOT_ID = 'recharge_page_root';
const RECHARGE_RECORD_LINK_ID = 'recharge_page_record_link';
const RECHARGE_PACKAGE_CARD_PREFIX = 'recharge_page_package_card_';
const RECHARGE_AGREEMENT_CHECKBOX_ID = 'recharge_page_agreement_checkbox';
const RECHARGE_AGREEMENT_LINK_ID = 'recharge_page_agreement_link';
const RECHARGE_SUBMIT_BUTTON_ID = 'recharge_page_submit';

@Preview
@ComponentV2
export struct RechargePage {
  vm: RechargeVM = new RechargeVM();

  aboutToAppear(): void {
    this.vm.getRechargePackages();
  }

  updateBookCoins(amount: number) {
    // 更新用户书币余额
    const userInfoFromStorage: UserInfo = AppStorage.get('userInfo') as UserInfo;
    if (userInfoFromStorage) {
      userInfoFromStorage.bookCoins = (userInfoFromStorage.bookCoins || 100) + amount;
      AppStorage.setOrCreate('userInfo', userInfoFromStorage);
      AppStorage.setOrCreate('bookCoins', userInfoFromStorage.bookCoins);
    }
    // 触发事件通知其他页面更新余额
    emitter.emit(Constants.LOGIN_CHANGE);
  }

  build() {
    NavDestination() {
      Stack() {
        Image($r('app.media.rbg'))
          .height(350)
          .objectFit(ImageFit.Fill)
          .backgroundColor('#F0F2F5');

        Image($r('app.media.rbg2'))
          .width(140)
          .height(120)
          .position({ x: '100%', y: 100 })
          .translate({ x: -140, y: 0 })
          .objectFit(ImageFit.Fill);

        Column() {
          NavHeaderBar({
            title: '充值',
            hasBackButton: true,
            hasBgColor: false,
            isMainPage: false,
          })

          Column({ space: 12 }) {
            Row() {
              Text('选择充值套餐')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_primary'))

              Text('充值记录')
                .id(RECHARGE_RECORD_LINK_ID)
                .fontSize(14)
                .fontColor('#E39331')
                .onClick(() => {
                  TCRouter.push(Constants.RECHARGE_RECORD_ROUTE);
                })
            }
            .width(Constants.FULL_SIZE)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)

            Grid() {
              ForEach(this.vm.rechargePackages, (item: RechargePackage) => {
                GridItem() {
                  Column({ space: 8 }) {
                    Column({ space: 4 }) {
                      Text(`${item.coins}`)
                        .fontSize(24)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.vm.selectId === item.id ? '#E39331' : $r('sys.color.font_primary'))

                      Text('书币')
                        .fontSize(12)
                        .fontColor($r('sys.color.font_secondary'))

                      if (item.bonus && item.bonus > 0) {
                        Text(`送${item.bonus}`)
                          .fontSize(10)
                          .fontColor('#E39331')
                      }

                      Text() {
                        Span('￥').fontSize(12)
                        Span(item.price.toString()).fontWeight(FontWeight.Bold)
                      }
                      .fontSize(16)
                      .fontColor(this.vm.selectId === item.id ? '#E39331' : $r('sys.color.font_primary'))
                      .margin({ top: 8 })
                    }
                    .padding({ top: item.isRecommended ? 16 : 20, bottom: 16 })
                    .width(Constants.FULL_SIZE)
                  }
                  .width(Constants.FULL_SIZE)
                  .height(130)
                  .id(RECHARGE_PACKAGE_CARD_PREFIX + item.id.toString())
                  .backgroundColor(this.vm.selectId === item.id ? '#FFF8F0' : $r('sys.color.background_primary'))
                  .border({
                    width: this.vm.selectId === item.id ? 2 : 1,
                    color: this.vm.selectId === item.id ? '#E39331' : '#E5E5E5',
                    radius: 12,
                  })
                  .onClick(() => {
                    this.vm.selectId = item.id;
                  })
                }
              }, (item: RechargePackage) => item.id.toString())
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .height(292)
            .width(Constants.FULL_SIZE)
          }
          .width(Constants.FULL_SIZE)
          .backgroundColor($r('sys.color.background_primary'))
          .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 0, bottomRight: 0 })
          .padding({ left: 16, right: 16, top: 20, bottom: 10 })
          .position({ x: 0, y: 210 })
          .alignItems(HorizontalAlign.Start)

          Column({ space: 16 }) {
            Text('充值说明')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .alignSelf(ItemAlign.Start)

            Column({ space: 8 }) {
              Text('• 书币可用于购买付费图书和章节')
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
                .alignSelf(ItemAlign.Start)

              Text('• 充值成功后书币将立即到账')
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
                .alignSelf(ItemAlign.Start)

              Text('• 书币不可提现，仅限在本应用内使用')
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
                .alignSelf(ItemAlign.Start)
            }
            .alignItems(HorizontalAlign.Start)
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 470 })
        }
        .id(RECHARGE_PAGE_ROOT_ID)
        .padding({ left: 0, right: 0 })
        .justifyContent(FlexAlign.Start)

        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Checkbox({ name: `recharge_agreement`, group: `rechargeAgreement` })
              .id(RECHARGE_AGREEMENT_CHECKBOX_ID)
              .select($$this.vm.selectCheckbox)
              .height(24)
              .width(24)
              .selectedColor('#E39331')
              .shape(CheckBoxShape.CIRCLE)

            Row({ space: 4 }) {
              Text('我已阅读并同意')
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))

              Text('充值协议')
                .id(RECHARGE_AGREEMENT_LINK_ID)
                .fontSize(12)
                .fontColor('#E39331')
                .onClick(() => {
                  // 可以跳转到充值协议页面
                  promptAction.showToast({ message: '充值协议页面' });
                })
            }
          }

          Button('立即充值')
            .id(RECHARGE_SUBMIT_BUTTON_ID)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('#E39331')
            .width(Constants.FULL_SIZE)
            .height(48)
            .bindSheet($$this.vm.isShow, this.paymentChannelSheet(),
              { showClose: false, height: '45%' })
            .onClick(() => {
              if (!this.vm.selectCheckbox) {
                promptAction.showToast({ message: '请先同意充值协议' });
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
      amount: this.vm.rechargePackages.find(pkg => pkg.id === this.vm.selectId)?.price || 0.01,
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
        // 支付成功后更新书币余额
        const selectedPackage = this.vm.rechargePackages.find(pkg => pkg.id === this.vm.selectId);
        if (selectedPackage) {
          const totalCoins = selectedPackage.coins + (selectedPackage.bonus || 0);
          this.updateBookCoins(totalCoins);

          // 保存充值记录
          const timestamp = Date.now();
          const rechargeRecord: RechargeRecord = {
            id: `${timestamp}_${selectedPackage.id}`,
            orderId: RechargeRecordVM.generateOrderId(),
            coins: selectedPackage.coins,
            bonus: selectedPackage.bonus || 0,
            totalCoins: totalCoins,
            amount: selectedPackage.price,
            timestamp: timestamp,
            date: RechargeRecordVM.formatDateTime(timestamp)
          };
          
          RechargeRecordVM.saveRechargeRecord(rechargeRecord);

          promptAction.showToast({
            message: `充值成功！获得${totalCoins}书币`,
            duration: 2000,
          });
        }

        TCRouter.pop();
        this.vm.isShow = false;
      },
    });
  }
} 
