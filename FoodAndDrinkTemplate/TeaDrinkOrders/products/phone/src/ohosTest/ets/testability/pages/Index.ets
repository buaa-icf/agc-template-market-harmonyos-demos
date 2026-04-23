import { OrderDetailRouter, RouterMap } from 'common';

const HOST_ANCHOR_ID: string = 'order_detail_test_host_anchor';
const OPEN_PAGE_BUTTON_ID: string = 'order_detail_test_open_page';

@Entry
@ComponentV2
struct Index {
  @Provider('pageStack') pageStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageStack) {
      Column({ space: 16 }) {
        Text('Order Detail UITest Host')
          .id(HOST_ANCHOR_ID)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)

        Button('Open Order Detail (orderId=1)')
          .id(OPEN_PAGE_BUTTON_ID)
          .onClick(() => {
            this.pageStack.pushPathByName(
              RouterMap.ORDER_DETAIL_PAGE,
              { orderId: '1', isOrderJump: false } as OrderDetailRouter,
            );
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true);
  }
}
