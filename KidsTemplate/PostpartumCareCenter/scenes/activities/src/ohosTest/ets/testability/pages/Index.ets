import { ActivityBookingBuilder } from '../../../../main/ets/view/ActivityBooking';

@Entry
@ComponentV2
struct Index {
  build() {
    Column() {
      Text('ActivityBookingHost')
        .id('activity_booking_test_host')
        .fontSize(16)
        .margin({ bottom: 8 });

      ActivityBookingBuilder();
    }
    .width('100%')
    .height('100%');
  }
}
