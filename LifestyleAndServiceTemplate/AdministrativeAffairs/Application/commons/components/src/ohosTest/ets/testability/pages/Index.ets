import { Constants } from 'common';
import { AboutUsPage } from '../../../../../../../../src/main/ets/components/AboutUs';

const ABOUT_US_SUGGESTION_TARGET_ID: string = 'about_us_test_suggestion_target';
const ABOUT_US_FEEDBACK_TARGET_ID: string = 'about_us_test_feedback_target';
const ABOUT_US_HOST_PAGE_ID: string = 'about_us_test_host_page';
const ABOUT_US_OPEN_BUTTON_ID: string = 'about_us_test_open_button';

@Entry
@ComponentV2
struct Index {
  @Provider('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    AppStorage.setOrCreate('topRectHeight', 0);
    this.pageInfos.clear();
    this.pageInfos.pushPathByName('host', null);
  }

  @Builder
  private pageMap(name: string) {
    if (name === 'host') {
      this.hostPage();
    } else if (name === 'aboutUs') {
      AboutUsPage();
    } else if (name === 'suggestion') {
      this.suggestionTargetPage();
    } else if (name === 'feedback') {
      this.feedbackTargetPage();
    }
  }

  @Builder
  private hostPage() {
    NavDestination() {
      Column() {
        Button('open-about-us')
          .id(ABOUT_US_OPEN_BUTTON_ID)
          .onClick(() => {
            this.pageInfos.pushPathByName('aboutUs', null);
          });
      }
      .id(ABOUT_US_HOST_PAGE_ID)
      .width(Constants.FULL_PERCENT_WIDTH)
      .height(Constants.FULL_PERCENT_HEIGHT)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    }
    .hideTitleBar(true);
  }

  @Builder
  private suggestionTargetPage() {
    NavDestination() {
      Column() {
        Text('suggestion-page')
          .id(ABOUT_US_SUGGESTION_TARGET_ID);
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .height(Constants.FULL_PERCENT_HEIGHT)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    }
    .hideTitleBar(true);
  }

  @Builder
  private feedbackTargetPage() {
    NavDestination() {
      Column() {
        Text('feedback-page')
          .id(ABOUT_US_FEEDBACK_TARGET_ID);
      }
      .width(Constants.FULL_PERCENT_WIDTH)
      .height(Constants.FULL_PERCENT_HEIGHT)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    }
    .hideTitleBar(true);
  }

  build() {
    Navigation(this.pageInfos) {
    }
    .hideTitleBar(true)
    .hideNavBar(true)
    .mode(NavigationMode.Stack)
    .width(Constants.FULL_PERCENT_WIDTH)
    .height(Constants.FULL_PERCENT_HEIGHT)
    .navDestination(this.pageMap);
  }
}
