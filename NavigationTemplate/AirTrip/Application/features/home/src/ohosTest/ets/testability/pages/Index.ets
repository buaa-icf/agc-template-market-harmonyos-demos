import { homePageBuilder } from '../../../../../../../../src/main/ets/pages/HomePage';

@Entry
@ComponentV2
struct Index {
  build() {
    Column() {
      Text('Home test host')
        .id('home_test_host_anchor')
      homePageBuilder()
    }
    .width('100%')
    .height('100%')
  }
}
