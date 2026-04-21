@Entry
@Component
struct Index {
  build() {
    Column({ space: 16 }) {
      Text('homePage Instrument Host')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)

      Text('PracticeModeInstrumentTest is running in this host page.')
        .fontSize(18)

      Text('This page replaces the default Hello World testability page.')
        .fontSize(16)
        .opacity(0.8)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(24)
  }
}
