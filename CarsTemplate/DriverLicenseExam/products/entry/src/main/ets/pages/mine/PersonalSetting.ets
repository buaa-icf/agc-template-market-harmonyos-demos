import { CustomContentDialog } from '@kit.ArkUI';
import { AccountUtil, CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';
import { CommonConstants } from '@ohos_agcit/driver_license_exam_guide';

@Builder
export function PersonalSettingBuilder() {
  PersonalSetting();
}

@Entry
@ComponentV2
struct PersonalSetting {
  @Local isShow: boolean = false;
  topRectHeight: number = AppStorage.get('topRectHeight') || 0;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  vm: CommonModel = CommonModel.instance;



  // 退出登录对话框
  logOutDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '账号退出登录',
      contentBuilder: () => {
        this.logOutContent();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.logOutDialogController.close();
          },
        },
        {
          value: $r('app.string.confirm'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            AccountUtil.loginOut();
            this.vm.navStack.pop();
          },
        },
      ],
    }),
  });

  // 退出登陆
  @Builder
  logOutContent() {
    Column() {
      Row() {
        Text('请确认是否退出当前账户？')
          .id('personal_setting_logout_dialog_content')
          .fontSize(14);
      };
    }
    .width('100%')
    .borderRadius(16)
    .margin({
      left: '4%',
      right: '4%',
      bottom: 5,
    });
  }



  build() {
    NavDestination() {
      Column(){
        Column({ space: 12 }) {
          Row() {
            Text('隐私政策')
              .fontSize(16)
              .margin({ left: 18 })

            Blank()
            Image($r('app.media.dark_triangle'))
              .width(20)
              .height(20)
              .margin({ right: 18 })
          }
          .onClick(() => {
            this.vm.navStack.pushPathByName('PrivacyAgreement', undefined)
          })
          .id('personal_setting_item_privacy_policy')
          .width(328)
          .height(61)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .padding({ top: 20, bottom: 20 })

          Row() {
            Text('用户协议')
              .fontSize(16)
              .margin({ left: 18 })

            Blank()
            Image($r('app.media.dark_triangle'))
              .width(20)
              .height(20)
              .margin({ right: 18 })
          }
          .onClick(() => {
            this.vm.navStack.pushPathByName('PrivacyAgreement', undefined)
          })
          .id('personal_setting_item_user_agreement')
          .width(328)
          .height(61)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .padding({ top: 20, bottom: 20 })
        }
        .width(CommonConstants.FULL_WIDTH)


        Blank()
        Row() {
          Text($r('app.string.log_out'))
            .fontSize(16)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .justifyContent(FlexAlign.Center)
        .width(304)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#808080')
        .margin({
          left: 28,
          right: 28,
          bottom: 50
        })
        .id('personal_setting_logout_button')

        .onClick(() => {
          this.logOutDialogController.open();
        })
      }
      .width('100%')
      .height('100%')
      .padding({ top: 12, left: '4%', right: '4%' })
    }
    .backgroundColor('#F1F3F5')
    .title('个人设置')
    .padding({
      top: px2vp(this.topRectHeight) + 10,
    })

  }
}



@Extend(Text)
function textExtend() {
  .fontSize(16)
  .fontFamily('鸿蒙黑体')
  .fontWeight(FontWeight.Medium)
  .opacity(0.9)
  .fontColor($r('sys.color.black'));
}
