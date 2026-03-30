import { Constants, TCRouter } from 'common';
import { MyInfoCard } from '../../../../../../../../src/main/ets/comp/MyInfoCard';
import { AboutPage } from '../../../../../../../../src/main/ets/views/AboutPage';
import { FeedbackPage } from '../../../../../../../../src/main/ets/views/FeedbackPage';
import { LoginPage } from '../../../../../../../../src/main/ets/views/LoginPage';
import { MemberAgreementPage } from '../../../../../../../../src/main/ets/views/MemberAgreementPage';
import { MemberCenterPage } from '../../../../../../../../src/main/ets/views/MemberCenterPage';
import { RechargePage } from '../../../../../../../../src/main/ets/views/RechargePage';
import { UserInfo } from 'base_common';
import { AppStorageV2 } from '@kit.ArkUI';
import { FeedbackRecord } from 'common';

const HOST_ROUTE = 'my_info_card_test_host';
const CARD_ROUTE = 'my_info_card_test_card';
const ABOUT_PAGE_ROUTE = 'about_page_test_page';
const FEEDBACK_PAGE_ROUTE = 'feedback_page_test_page';
const FEEDBACK_RECORD_ROUTE = 'feedback_record_test_page';
const LOGIN_PAGE_ROUTE = 'login_page_test_page';
const MEMBER_AGREEMENT_PAGE_ROUTE = 'member_agreement_test_page';
const MEMBER_CENTER_PAGE_ROUTE = 'member_center_test_page';
const RECHARGE_PAGE_ROUTE = 'recharge_page_test_page';
const HOST_GUEST_BUTTON_ID = 'my_info_card_test_open_guest';
const HOST_NON_MEMBER_BUTTON_ID = 'my_info_card_test_open_non_member';
const HOST_MEMBER_BUTTON_ID = 'my_info_card_test_open_member';
const HOST_ABOUT_PAGE_BUTTON_ID = 'about_page_test_open';
const HOST_FEEDBACK_PAGE_BUTTON_ID = 'feedback_page_test_open';
const HOST_FEEDBACK_RECORD_BUTTON_ID = 'feedback_page_test_open_record';
const HOST_LOGIN_PAGE_BUTTON_ID = 'login_page_test_open';
const HOST_MEMBER_AGREEMENT_PAGE_BUTTON_ID = 'member_agreement_page_test_open';
const HOST_MEMBER_CENTER_PAGE_BUTTON_ID = 'member_center_page_test_open';
const HOST_RECHARGE_PAGE_BUTTON_ID = 'recharge_page_test_open';
const HOST_FEEDBACK_PAGE_ROOT_ID = 'feedback_page_test_host';
const HOST_FEEDBACK_RECORD_COUNT_ID = 'feedback_page_test_record_count';
const HOST_FEEDBACK_LAST_DESCRIPTION_ID = 'feedback_page_test_last_description';
const HOST_FEEDBACK_LAST_PHONE_ID = 'feedback_page_test_last_phone';
const FEEDBACK_RECORD_ROOT_ID = 'feedback_page_test_record_root';
const FEEDBACK_RECORD_PAGE_COUNT_ID = 'feedback_page_test_record_page_count';
const FEEDBACK_RECORD_PAGE_DESCRIPTION_ID = 'feedback_page_test_record_page_description';
const FEEDBACK_RECORD_PAGE_PHONE_ID = 'feedback_page_test_record_page_phone';
const FEEDBACK_RECORD_PAGE_BACK_BUTTON_ID = 'feedback_page_test_record_page_back';
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
  @Local private feedbackRecord: FeedbackRecord =
    AppStorageV2.connect(FeedbackRecord, 'feedbackRecord', () => new FeedbackRecord())!;

  aboutToAppear(): void {
    TCRouter.init();
    TCRouter.replace(HOST_ROUTE);
    AppStorage.setOrCreate('userInfo', undefined);
    AppStorage.setOrCreate('windowTopHeight', 0);
    this.resetFeedbackRecord();
  }

  private resetFeedbackRecord(): void {
    this.feedbackRecord.feedbackList = [];
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

  private openFeedbackPage(): void {
    this.resetFeedbackRecord();
    TCRouter.push(FEEDBACK_PAGE_ROUTE);
  }

  private openFeedbackRecordPage(): void {
    TCRouter.push(FEEDBACK_RECORD_ROUTE);
  }

  private openLoginPage(): void {
    AppStorage.setOrCreate('userInfo', undefined);
    AppStorage.setOrCreate('membershipStatus', undefined);
    AppStorage.setOrCreate('bookCoins', undefined);
    TCRouter.push(LOGIN_PAGE_ROUTE);
  }

  private openMemberAgreementPage(): void {
    AppStorage.setOrCreate('userInfo', undefined);
    TCRouter.push(MEMBER_AGREEMENT_PAGE_ROUTE);
  }

  private openMemberCenterPage(): void {
    AppStorage.setOrCreate('userInfo', undefined);
    TCRouter.push(MEMBER_CENTER_PAGE_ROUTE);
  }

  private openRechargePage(): void {
    AppStorage.setOrCreate('userInfo', undefined);
    TCRouter.push(RECHARGE_PAGE_ROUTE);
  }

  private latestFeedbackDescription(): string {
    if (this.feedbackRecord.feedbackList.length === 0) {
      return '';
    }

    return this.feedbackRecord.feedbackList[this.feedbackRecord.feedbackList.length - 1].description;
  }

  private latestFeedbackPhone(): string {
    if (this.feedbackRecord.feedbackList.length === 0) {
      return '';
    }

    return this.feedbackRecord.feedbackList[this.feedbackRecord.feedbackList.length - 1].phone;
  }

  @Builder
  private hostPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Column({ space: 8 }) {
          Text(`${this.feedbackRecord.feedbackList.length}`)
            .id(HOST_FEEDBACK_RECORD_COUNT_ID)

          Text(this.latestFeedbackDescription())
            .id(HOST_FEEDBACK_LAST_DESCRIPTION_ID)

          Text(this.latestFeedbackPhone())
            .id(HOST_FEEDBACK_LAST_PHONE_ID)
        }
        .width(Constants.FULL_SIZE)

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

        Button('打开意见反馈页')
          .id(HOST_FEEDBACK_PAGE_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            this.openFeedbackPage();
          })

        Button('打开反馈记录检查页')
          .id(HOST_FEEDBACK_RECORD_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            this.openFeedbackRecordPage();
          })

        Button('打开登录页')
          .id(HOST_LOGIN_PAGE_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            this.openLoginPage();
          })

        Button('打开会员服务协议页')
          .id(HOST_MEMBER_AGREEMENT_PAGE_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            this.openMemberAgreementPage();
          })

        Button('打开会员中心页')
          .id(HOST_MEMBER_CENTER_PAGE_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            this.openMemberCenterPage();
          })

        Button('打开充值页')
          .id(HOST_RECHARGE_PAGE_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            this.openRechargePage();
          })
      }
      .id(HOST_FEEDBACK_PAGE_ROOT_ID)
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.Start)
      .padding(16)
    }
    .hideTitleBar(true)
  }

  @Builder
  private feedbackRecordPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Button('返回测试首页')
          .id(FEEDBACK_RECORD_PAGE_BACK_BUTTON_ID)
          .width(Constants.FULL_SIZE)
          .onClick(() => {
            TCRouter.pop();
          })

        Text(`${this.feedbackRecord.feedbackList.length}`)
          .id(FEEDBACK_RECORD_PAGE_COUNT_ID)

        Text(this.latestFeedbackDescription())
          .id(FEEDBACK_RECORD_PAGE_DESCRIPTION_ID)

        Text(this.latestFeedbackPhone())
          .id(FEEDBACK_RECORD_PAGE_PHONE_ID)
      }
      .id(FEEDBACK_RECORD_ROOT_ID)
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.Start)
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
    } else if (name === FEEDBACK_PAGE_ROUTE) {
      FeedbackPage();
    } else if (name === FEEDBACK_RECORD_ROUTE) {
      this.feedbackRecordPage();
    } else if (name === LOGIN_PAGE_ROUTE) {
      LoginPage({
        disableAutoQuickLogin: true
      });
    } else if (name === MEMBER_AGREEMENT_PAGE_ROUTE) {
      MemberAgreementPage();
    } else if (name === MEMBER_CENTER_PAGE_ROUTE) {
      MemberCenterPage();
    } else if (name === RECHARGE_PAGE_ROUTE) {
      RechargePage();
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
