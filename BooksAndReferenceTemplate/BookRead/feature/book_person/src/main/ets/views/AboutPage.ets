import { Constants, NavHeaderBar, ReturnButton } from 'common';
import { AvatarIcon } from '../comp/SelectAvatarCard';
import { call } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { baseActionSheet } from 'base_common';
import { UserInfo } from 'base_common';

const ABOUT_PAGE_ROOT_ID = 'about_page_root';
const ABOUT_PAGE_CONTACT_SERVICE_ROW_ID = 'about_page_contact_service_row';
const ABOUT_PAGE_PHONE_SHEET_ID = 'about_page_phone_sheet';
const ABOUT_PAGE_CALL_BUTTON_ID = 'about_page_make_call_button';
const ABOUT_PAGE_CANCEL_BUTTON_ID = 'about_page_cancel_call_button';

@ComponentV2
export struct AboutPage {
  @Local userInfo: UserInfo | undefined = undefined;
  @Local avatarIcon: AvatarIcon | undefined = undefined;
  @Local isSelectCalendar: boolean = false;
  @Local isModifyNickName: boolean = false;
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '关于',
        hasBackButton: true,
        hasBgColor: true,
        isMainPage: false,
      })
      Column({space: 24}) {
        Image($r('app.media.startIcon'))
          .width(72)
          .height(72)
          .borderRadius(16)
          .objectFit(ImageFit.Contain)
        Column(){
          Text('阅读')
            .width(328)
            .height(40)
            .fontSize(30)
            .fontWeight(500)
            .textAlign(TextAlign.Center)
          Text('业务描述')
            .width(328)
            .height(19)
            .fontSize(14)
            .fontWeight(400)
            .fontColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
        }
        this.aboutCardView()
      }
      .id(ABOUT_PAGE_ROOT_ID)
      .padding({
        left:16,
        right:16,
        top:24
      })
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
    }
    .hideTitleBar(true)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  aboutCardView(){
    Column({space : 11}){
      Row(){
        Column(){
          Text('版本信息')
            .fontSize(16)
            .fontWeight(FontWeight.Normal)
            .width(100)
            .height(22)
            .textAlign(TextAlign.Start)
          Text('1.0.23.300')
            .fontSize(12)
            .fontWeight(FontWeight.Normal)
            .width(100)
            .height(16)
            .textAlign(TextAlign.Start)
            .fontColor($r('sys.color.font_secondary'))
        }
        .padding({
          left:6,
          right:6
        })
        Row({space :4}){
          Text('检查更新')
            .width(48)
            .height(16)
            .fontSize(12)
            .fontWeight(FontWeight.Normal)
            .textAlign(TextAlign.Start)
            .fontColor($r('sys.color.font_secondary'))
          Row(){
            Image($r('app.media.ic_arrow_right'))
              .width(7)
              .height(14)
              .objectFit(ImageFit.Contain)
          }
          .width(16)
          .height(16)
          .padding({
            top:1,
            bottom:1,
            left:4.5,
            right:4.5
          })
        }
        .padding({
          left:6,
          right:6
        })
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left:12,
        right:12
      })

      Divider()
        .width(Constants.FULL_SIZE)
      Row(){
        Column(){
          Text('客服电话')
            .fontSize(16)
            .fontWeight(FontWeight.Normal)
            .width(100)
            .height(22)
            .textAlign(TextAlign.Start)
          Text('000000')
            .fontSize(12)
            .fontWeight(FontWeight.Normal)
            .width(100)
            .height(16)
            .textAlign(TextAlign.Start)
            .fontColor($r('sys.color.font_secondary'))
        }
        .padding({
          left:6,
          right:6
        })
        Row({space :4}){
          Row(){
            Image($r('app.media.ic_arrow_right'))
              .width(7)
              .height(14)
              .objectFit(ImageFit.Contain)
          }
          .width(16)
          .height(16)
          .padding({
            top:1,
            bottom:1,
            left:4.5,
            right:4.5
          })
        }
        .padding({
          left:6,
          right:6
        })
      }
      .width(Constants.FULL_SIZE)
      .id(ABOUT_PAGE_CONTACT_SERVICE_ROW_ID)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left:12,
        right:12
      })
      .onClick(() => { baseActionSheet.show({
        id: 'PhoneSheetBuilder',
        title: { title: '联系客服' },
        height: SheetSize.FIT_CONTENT,
        backgroundColor: $r('app.color.pure_white'),
        customContent: () => {
          this.PhoneSheetBuilder()
        },
      })
      })
    }
    .width(Constants.FULL_SIZE)
    .borderRadius(16)
    .backgroundColor('#ffffff')
    .padding({
      top:12,
      bottom:12
    })
  }

  @Builder
  PhoneSheetBuilder() {
    Column({ space: 12 }) {
      Text('000000')
        .fontSize(18)
        .fontWeight('medium')
      Row({ space: 8 }) {
        Text('一键拨号')
          .fontSize(16)
          .fontWeight('medium')
          .fontColor($r('app.color.pure_white'))
      }
      .id(ABOUT_PAGE_CALL_BUTTON_ID)
      .padding({ top: 10, bottom: 10 })
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .borderRadius(20)
      .backgroundColor('#E84026')
      .onClick(() => {
        call.makeCall('000000',
          (err: BusinessError) => {
            if (err) {
              console.error(`makeCall fail, err->${JSON.stringify(err)}`);
            } else {
              console.log(`makeCall success`);
            }
          });
      })

      Row() {
        Text('取消')
          .fontSize(16)
          .fontWeight('medium')
          .fontColor('#ffffff')
      }
      .id(ABOUT_PAGE_CANCEL_BUTTON_ID)
      .padding({ top: 10, bottom: 10 })
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .borderRadius(20)
      .backgroundColor(Color.Gray)
      .onClick(() => {
        baseActionSheet.close('PhoneSheetBuilder')
      })
    }
    .id(ABOUT_PAGE_PHONE_SHEET_ID)
    .width('90%')
    .padding({
      left: 12,
      right: 12,
      bottom: 16,
      top: 16
    })
    .margin({ bottom: 40, left: 16, right: 16 })
    .backgroundColor($r('app.color.pure_white'))
    .borderRadius(16)
  }
}
