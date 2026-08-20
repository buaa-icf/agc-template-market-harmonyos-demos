import { MockService, UserFullInfo, UserInfo } from 'commons';
import { MyDetailPage } from '../../../../../../../../src/main/ets/pages/UserDetail';

const HOST_ANCHOR_ID = 'user_detail_test_host_anchor';
const CONFIGURED_SCENARIO_ID = 'user_detail_show_configured';
const EMPTY_SCENARIO_ID = 'user_detail_show_empty';

@Entry
@Component
struct Index {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  @State private generation: number = 0;

  private showConfigured(): void {
    const userInfo = new UserInfo();
    userInfo.gender = 0;
    userInfo.education = 1;
    userInfo.monthlyIncome = 1;
    userInfo.marriageStatus = 1;
    userInfo.hasChildren = 1;
    userInfo.expectationOfChildren = 1;
    userInfo.smoking = 1;
    userInfo.drinking = 1;
    userInfo.hasBuyCar = 1;
    userInfo.house = 1;
    userInfo.whenToMarry = 1;
    userInfo.currentResidence = 'Configured Residence';
    userInfo.originFrom = 'Configured Origin';
    userInfo.ethnicGroup = 'Configured Group';
    userInfo.job = 'Configured Job';
    userInfo.weixinNo = 'configured-weixin';
    userInfo.hobbies = 'Configured Hobby';
    userInfo.selfIntroduction = 'Configured Introduction';
    userInfo.height = 175;
    userInfo.weight = 65;
    userInfo.profilePictureUrl =
      'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==';
    userInfo.birth = '2000-01-01';
    const fullInfo = new UserFullInfo();
    fullInfo.userInfo = userInfo;
    MockService.currentUserFullInfo = fullInfo;
    this.generation++;
  }

  private showEmpty(): void {
    const fullInfo = new UserFullInfo();
    fullInfo.userInfo = new UserInfo();
    MockService.currentUserFullInfo = fullInfo;
    this.generation++;
  }

  build() {
    Stack() {
      Navigation(this.pageStack) {
        if (this.generation % 3 === 0) {
          MyDetailPage()
        } else if (this.generation % 3 === 1) {
          MyDetailPage()
        } else {
          MyDetailPage()
        }
      }
      .hideTitleBar(true)
      .hideToolBar(true)

      Row({ space: 8 }) {
        Button('Configured')
          .id(CONFIGURED_SCENARIO_ID)
          .onClick(() => {
            this.showConfigured();
          })
        Button('Empty')
          .id(EMPTY_SCENARIO_ID)
          .onClick(() => {
            this.showEmpty();
          })
      }
      .align(Alignment.TopEnd)
      .zIndex(10)

      Text('User detail test host')
        .id(HOST_ANCHOR_ID)
        .fontSize(1)
        .opacity(0.01)
        .align(Alignment.TopStart)
    }
    .width('100%')
    .height('100%')
  }
}
