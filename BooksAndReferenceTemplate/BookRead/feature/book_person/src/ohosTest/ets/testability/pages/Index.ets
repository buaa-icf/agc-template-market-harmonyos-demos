import { Constants, TCRouter } from 'common';
import { MyInfoCard } from '../../../../../../../../src/main/ets/comp/MyInfoCard';
import { AboutPage } from '../../../../../../../../src/main/ets/views/AboutPage';
import { UserInfo } from 'base_common';

const HOST_ROUTE = 'my_info_card_test_host';
const CARD_ROUTE = 'my_info_card_test_card';
const ABOUT_PAGE_ROUTE = 'about_page_test_page';
const HOST_GUEST_BUTTON_ID = 'my_info_card_test_open_guest';
const HOST_NON_MEMBER_BUTTON_ID = 'my_info_card_test_open_non_member';
const HOST_MEMBER_BUTTON_ID = 'my_info_card_test_open_member';
const HOST_ABOUT_PAGE_BUTTON_ID = 'about_page_test_open';
const CARD_RETURN_BUTTON_ID = 'my_info_card_test_card_return_host';
const LOGIN_RETURN_BUTTON_ID = 'my_info_card_test_login_return_host';
const MEMBER_CENTER_RETURN_BUTTON_ID = 'my_info_card_test_member_return_host';
const LOGIN_MARKER_ID = 'my_info_card_test_login_page';
const MEMBER_CENTER_MARKER_ID = 'my_info_card_test_member_center_page';
const CARD_SCENARIO_MARKER_ID = 'my_info_card_test_card_scenario';

interface TestUserInfoOptions {
  nickName: string;
  telephone: string;
  level: number;
  isMembership: boolean;
}

function buildUserInfo(options: TestUserInfoOptions): UserInfo {
  const userInfo = new UserInfo();
  userInfo.id = 'test-user';
  userInfo.nickName = options.nickName;
  userInfo.telephone = options.telephone;
  userInfo.level = options.level;
  userInfo.isLogin = true;
  userInfo.isMembership = options.isMembership;
  return userInfo;
}

@Entry
@ComponentV2
struct Index {
  @Local private currentScenarioLabel: string = '';

  aboutToAppear(): void {
    TCRouter.init();
    TCRouter.replace(HOST_ROUTE);
    AppStorage.setOrCreate('userInfo', undefined);
  }

  private openGuestCard(): void {
    this.currentScenarioLabel = 'guest';
    AppStorage.setOrCreate('userInfo', undefined);
    TCRouter.push(CARD_ROUTE);
  }

  private openNonMemberCard(): void {
    this.currentScenarioLabel = 'non_member';
    AppStorage.setOrCreate('userInfo', buildUserInfo({
      nickName: '测试用户',
      telephone: '13812345678',
      level: 2,
      isMembership: false
    }));
    TCRouter.push(CARD_ROUTE);
  }

  private openMemberCard(): void {
    this.currentScenarioLabel = 'member';
    AppStorage.setOrCreate('userInfo', buildUserInfo({
      nickName: '会员用户',
      telephone: '13987654321',
      level: 6,
      isMembership: true
    }));
    TCRouter.push(CARD_ROUTE);
  }

  private openAboutPage(): void {
    AppStorage.setOrCreate('userInfo', undefined);
    TCRouter.push(ABOUT_PAGE_ROUTE);
  }

  @Builder
  private hostPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Button('打开游客态')
          .id(HOST_GUEST_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            this.openGuestCard();
          })

        Button('打开已登录非会员态')
          .id(HOST_NON_MEMBER_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            this.openNonMemberCard();
          })

        Button('打开已登录会员态')
          .id(HOST_MEMBER_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            this.openMemberCard();
          })

        Button('打开关于页')
          .id(HOST_ABOUT_PAGE_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            this.openAboutPage();
          })
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.Center)
      .padding(16)
    }
    .hideTitleBar(true)
  }

  @Builder
  private cardPage() {
    NavDestination() {
      Column({ space: 12 }) {
        Text(this.currentScenarioLabel)
          .id(CARD_SCENARIO_MARKER_ID)
          .fontSize(12)
          .fontColor('#666666')

        Button('返回测试首页')
          .id(CARD_RETURN_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            TCRouter.pop();
          })

        MyInfoCard()
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .padding(16)
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
  }

  @Builder
  private loginPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Text('登录页')
          .id(LOGIN_MARKER_ID)
          .fontSize(24)

        Button('返回测试首页')
          .id(LOGIN_RETURN_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            TCRouter.pop();
            TCRouter.pop();
          })
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.Center)
      .padding(16)
    }
    .hideTitleBar(true)
  }

  @Builder
  private memberCenterPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Text('会员中心页')
          .id(MEMBER_CENTER_MARKER_ID)
          .fontSize(24)

        Button('返回测试首页')
          .id(MEMBER_CENTER_RETURN_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            TCRouter.pop();
            TCRouter.pop();
          })
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.Center)
      .padding(16)
    }
    .hideTitleBar(true)
  }

  @Builder
  private routerMap(name: string) {
    if (name === HOST_ROUTE) {
      this.hostPage();
    } else if (name === CARD_ROUTE) {
      this.cardPage();
    } else if (name === ABOUT_PAGE_ROUTE) {
      AboutPage();
    } else if (name === Constants.LOGIN_ROUTE) {
      this.loginPage();
    } else if (name === Constants.MEMBER_CENTER_ROUTE) {
      this.memberCenterPage();
    }
  }

  build() {
    Navigation(TCRouter.getStack()) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .navDestination(this.routerMap);
  }
}
