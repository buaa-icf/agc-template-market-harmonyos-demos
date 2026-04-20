import { QuickLogin } from '../../../../main/ets/components/QuickLogin';

const QUICK_LOGIN_HOST_ANCHOR_ID: string = 'quick_login_cover_test_host_anchor';

@Entry
@ComponentV2
struct Index {
  @Local private servicePolicyClicked: boolean = false;
  @Local private privacyPolicyClicked: boolean = false;
  @Local private accountRouterClicked: boolean = false;

  build() {
    Column({ space: 12 }) {
      Text('QuickLogin Cover UITest Host')
        .id(QUICK_LOGIN_HOST_ANCHOR_ID)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)

      QuickLogin({
        isBindContentCover: true,
        icon: $r('app.media.icon_exam_login'),
        loginBtnBgColor: '#4B5CC4',
        appName: 'Exam',
        onLoginWithHuaweiID: () => {
        },
        onPrivacyPolicy: () => {
          this.privacyPolicyClicked = true;
        },
        onServicePolicy: () => {
          this.servicePolicyClicked = true;
        },
        onHYAccountRouter: () => {
          this.accountRouterClicked = true;
        }
      })
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16);
  }
}
