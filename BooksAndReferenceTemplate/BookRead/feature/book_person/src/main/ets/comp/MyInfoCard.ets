import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { font } from '@kit.ArkUI';
import { AvatarIcon, SelectAvatarCard } from './SelectAvatarCard';
import { Constants, TCRouter, UserInfoModel, UserInfoUtil } from 'common';
import UserAuthIcon from '@ohos.userIAM.userAuthIcon';
import { UserInfo } from 'base_common';
@ComponentV2
export struct MyInfoCard {
  @Local userName: string = ''
  @Local userTel: string = ''
  @Local isLogin: boolean = false
  @Local avatarIcon: AvatarIcon = new AvatarIcon('');
  @Local isMembership: boolean = false
  @Local level: number = 1
  @Local levelString: string = 'LV0'
  @Local userInfoModel: UserInfoModel = UserInfoUtil.getUserInfoModel();

  aboutToAppear(): void {
    // 初始化用户信息
    UserInfoUtil.init();
    this.loadUserInfo();
    emitter.on(Constants.LOGIN_CHANGE, () => {
      this.loadUserInfo();
    });
  }

  onPageShow(): void {
    // 页面显示时刷新用户信息，确保从会员中心返回时状态是最新的
    UserInfoUtil.loadUserInfo();
    this.loadUserInfo();
  }

  loadUserInfo() {
    const userInfoFromStorage: UserInfo = AppStorage.get('userInfo') as UserInfo;
    if (userInfoFromStorage) {
      this.userInfoModel.updateFromUserInfo(userInfoFromStorage);
      console.log('userInfo' + JSON.stringify(this.userInfoModel))
      this.isLogin = true;
      this.userName = this.userInfoModel.nickName || '';
      this.userTel = this.userInfoModel.telephone || '';
      this.avatarIcon.avatarUrl = this.userInfoModel.avatarUrl || '';
      this.isMembership = this.userInfoModel.isMembership || false;
      this.level = userInfoFromStorage.level || 1;
      this.levelString = 'LV' + this.level;
      if (this.userTel) {
        this.userTel = `${this.userTel.substring(0, this.userTel.length - 8)}****${this.userTel.substring(this.userTel.length - 4)}`;
      }
    } else {
      this.isLogin = false;
      this.userName = '';
      this.userTel = '';
      this.avatarIcon.avatarUrl = '';
      this.isMembership = false;
      this.level = 1;
      this.levelString = 'LV0';
    }
  }

  showLoginPrompt() {
    const promptAction = this.getUIContext().getPromptAction();

    promptAction.showDialog({
      title: '提示',
      message: '需要先登录才能使用此功能',
      buttons: [
        {
          text: '取消',
          color: '#999999'
        },
        {
          text: '去登录',
          color: '#E3922F'
        }
      ]
    }).then((result) => {
      if (result.index === 1) {
        // 用户点击了'去登录'
        TCRouter.push(Constants.LOGIN_ROUTE);
      }
      // 用户点击了'取消'，不做任何操作
    }).catch(() => {
      // 异常处理
    });
  }

  @Builder
  membershipBuilder() {
    Stack() {
      Image($r('app.media.ic_vip_on'))
        .width(32)
        .height(32)
        .objectFit(ImageFit.Contain)

      Column({ space: 2 }) {
        Text('阅读听书会员')
          .fontColor('#D17E18')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text('开通会员享受购书折扣')
          .fontColor('#D17E18')
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 40 })

      Button((this.isLogin && this.isMembership) ? $r('app.string.member_center') : $r('app.string.open_member'),
        { controlSize: ControlSize.SMALL })
        .id('my_info_card_membership_action')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor('#E3922F')
        .margin({ left: 220 })
        .onClick(() => {
          if (!this.isLogin) {
            this.showLoginPrompt();
          } else {
            TCRouter.push(Constants.MEMBER_CENTER_ROUTE);
          }
        })
    }
    .height(64)
    .width(Constants.FULL_SIZE)
    .borderRadius(12)
    .padding({
      top:12,
      left:13,
      right:12
    })
    .alignContent(Alignment.TopStart)
    .backgroundImage($r('app.media.vipcard_background'))
    .backgroundImageSize({width:Constants.FULL_SIZE, height:64})
  }

  change() {
    if (this.userTel) {
      this.userTel =
        `${this.userTel.substring(0, this.userTel.length - 8)}****${this.userTel.substring(this.userTel.length - 4)}`
    }
    this.isLogin = !!this.userTel
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        if (this.isLogin) {
          SelectAvatarCard({ avatarIcon: this.avatarIcon, isLogin: this.isLogin })
        } else {
          Image($r('app.media.ic_default_hd'))
            .id('my_info_card_guest_avatar')
            .width(64)
            .height(64)
            .borderRadius(50)
            .onClick(() => {
              TCRouter.push(Constants.LOGIN_ROUTE);
            })
        }
        if (this.isLogin) {
          Column() {
            Row({space:4}) {
              Text(this.userName)
                .fontSize(24)
                .fontWeight(500)
                .height(32)
                .textAlign(TextAlign.Start)
            }
            .height(32)
            .width(Constants.FULL_SIZE)

            Row(){
              if (this.isMembership){
                Row() {
                  Image($r('app.media.ic_vip_on'))
                    .height(20)
                    .width(17.7)
                    .objectFit(ImageFit.Contain)
                    .margin({
                      left:8,
                      right:8
                    })
                  Text('VIP会员')
                    .height(16)
                    .width(43)
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .margin({
                      top:8,
                      bottom:8
                    })
                    .fontColor('#E6E08A21')
                }
                .height(28)
                .width(96)
                .margin({top:4})
                .borderRadius(8)
                .backgroundColor('#FCF2CC')
              } else {
                Row() {
                  Image($r('app.media.ic_vip_off'))
                    .height(20)
                    .width(17.7)
                    .objectFit(ImageFit.Contain)
                    .margin({
                      left:8,
                      right:8
                    })
                  Text($r('app.string.vip_off'))
                    .height(16)
                    .width(36)
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .margin({
                      top:8,
                      bottom:8
                    })
                }
                .height(28)
                .width(96)
                .margin({top:4})
                .borderRadius(8)
                .backgroundColor($r('sys.color.comp_background_secondary'))
              }
            }
            .height(32)
            .width(Constants.FULL_SIZE)
          }
          .height(64)
          .width(Constants.FULL_SIZE)
          .justifyContent(FlexAlign.SpaceBetween)

        } else {
          Row() {
            Text('去登录')
              .fontSize(24)
              .fontWeight(500)
              .height(32)
              .width(Constants.FULL_SIZE)
              .textAlign(TextAlign.Start)
              .align(Alignment.Center)
          }
          .id('my_info_card_guest_login')
          .height(64)
          .width(230)
          .onClick(() => {
            TCRouter.push(Constants.LOGIN_ROUTE);
          })
        }
      }
      this.membershipBuilder()
    }
    .id('my_info_card_root')
    .height(164)
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
      top: 12,
      bottom: 12,
    })
  }

  // 错误处理
  dealAllError(error: BusinessError<Object>): void {
    hilog.error(0x0000, 'testTag',
      `Failed to login, errorCode is ${error.code}, errorMessage is ${error.message}`);
    const uiContext = this.getUIContext?.();
    if (uiContext) {
      const promptAction = uiContext.getPromptAction();
      promptAction.showToast({ message: '账号关联失败' });
    }
  }
}
