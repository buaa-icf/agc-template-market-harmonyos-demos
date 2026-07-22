import { MyDetailPage } from '../../../../../../../../src/main/ets/pages/UserDetail';

const HOST_ANCHOR_ID = 'user_detail_test_host_anchor';

@Entry
@Component
struct Index {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      Text('User detail test host')
        .id(HOST_ANCHOR_ID)
        .fontSize(1)
        .opacity(0.01)
      MyDetailPage()
    }
    .width('100%')
    .height('100%')
  }
}
