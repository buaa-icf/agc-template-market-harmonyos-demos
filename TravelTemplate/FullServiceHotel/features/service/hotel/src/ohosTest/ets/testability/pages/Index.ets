import { hotelOrderPageBuilder } from '../../../../../../../../src/main/ets/pages/HotelOrderPage';

const HOST_ANCHOR_ID = 'hotel_order_test_host_anchor';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Text('Hotel order test host')
        .id(HOST_ANCHOR_ID)
        .fontSize(1)
        .opacity(0.01)
      hotelOrderPageBuilder()
    }
    .width('100%')
    .height('100%')
  }
}
