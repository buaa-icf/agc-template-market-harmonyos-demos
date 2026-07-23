import { AgencyTaskCalender } from '../../../../../../../../src/main/ets/agency/components/AgencyTaskCalender';

@Entry
@Component
struct Index {
  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      AgencyTaskCalender()

      Text('agency_calendar_test_host')
        .id('agency_calendar_test_host_anchor')
        .fontSize(1)
        .fontColor(Color.Transparent)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
