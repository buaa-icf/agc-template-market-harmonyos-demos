import { ActivityModel } from '@ohos_agcit/postpartum_care_center_utils';
import { ActivityBookingBuilder } from '../../../../../../../../src/main/ets/view/ActivityBooking';

@Entry
@Component
struct Index {
  @State private pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    const activity = ActivityModel.createEmptyActivity();
    activity.id = 1;
    activity.name = 'UI_TEST_ACTIVITY';
    this.pathStack.pushPathByName('ActivityBooking', activity, false);
  }

  @Builder
  pageMap(name: string) {
    if (name === 'ActivityBooking') {
      ActivityBookingBuilder();
    }
  }

  build() {
    Column() {
      Text('ActivityBookingHost')
        .id('activity_booking_test_host')
        .fontSize(16)
        .margin({ bottom: 8 });
      Navigation(this.pathStack) {
      }
      .hideTitleBar(true)
      .hideNavBar(true)
      .mode(NavigationMode.Stack)
      .layoutWeight(1)
      .width('100%')
      .navDestination(this.pageMap);
    }
    .width('100%')
    .height('100%');
  }
}
