const TOPIC_PAGE_HOST_ANCHOR_ID: string = 'topic_page_instrument_host_anchor';
const PRACTICE_MODE_SUITE_LABEL: string = 'PracticeModeInstrumentTest Host';

@Entry
@ComponentV2
struct Index {
  build() {
    Column({ space: 12 }) {
      Text('topicPage Instrument Host')
        .id(TOPIC_PAGE_HOST_ANCHOR_ID)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)

      Text(PRACTICE_MODE_SUITE_LABEL)
        .fontSize(16)
        .fontColor($r('sys.color.font_secondary'))

      Text('Current suite: PracticeModeInstrumentTest')
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center);
  }
}
