import { Good, GoodRouter, OrderDetailRouter, RouterMap } from 'common';
import { GoodDetailPageBuilder } from 'order';

const HOST_ANCHOR_ID: string = 'order_detail_test_host_anchor';
const OPEN_PAGE_BUTTON_ID: string = 'order_detail_test_open_page';
const OPEN_GOOD_DETAIL_BUTTON_ID: string = 'good_detail_test_open_page';

@Entry
@ComponentV2
struct Index {
  @Provider('pageStack') pageStack: NavPathStack = new NavPathStack();
  private packageGood: Good = {
    id: '5',
    name: 'Package target',
    logo: 'TeaDrinkOrders/good_pkg_logo.png',
    bigImg: ['TeaDrinkOrders/good_pkg_logo.png'],
    money: '75.4',
    content: 'Package target',
    sales: '200',
    specType: '3',
    details: 'TeaDrinkOrders/good_pkg_logo.png',
    num: 1,
    spec: [],
    boxMoney: '1',
  };

  @Builder
  testNavDestinationBuilder(name: string, param?: Object) {
    if (name === RouterMap.GOOD_DETAIL_PAGE) {
      GoodDetailPageBuilder();
    }
  }

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

        Button('Open Good Detail (package)')
          .id(OPEN_GOOD_DETAIL_BUTTON_ID)
          .onClick(() => {
            this.pageStack.pushPathByName(
              RouterMap.GOOD_DETAIL_PAGE,
              { goodInfo: this.packageGood } as GoodRouter,
            );
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.testNavDestinationBuilder);
  }
}
