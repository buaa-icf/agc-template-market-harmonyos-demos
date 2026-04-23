import { RouterMap, RouterModule } from 'commonlib';
import { IProductItem, SaleState } from 'network/src/main/ets/types/responseTypes/GetProductResp';
import { ProductSearchBuilder } from '../../../../../../../../src/main/ets/pages/ProductSearch';
import { ProductSearchVM } from '../../../../../../../../src/main/ets/viewModels/ProductSearchVM';

const HOST_ROUTE = 'product_search_test_host';
const HOST_ANCHOR_ID = 'product_search_host_anchor';
const OPEN_POPULATED_BUTTON_ID = 'product_search_show_populated';
const OPEN_EMPTY_BUTTON_ID = 'product_search_show_empty';
const DETAIL_PARAM_ID = 'product_search_detail_param';
const DETAIL_BACK_ID = 'product_search_detail_back';

function createProductItems(): IProductItem[] {
  return [
    {
      id: 1001,
      name: 'Stable Income One',
      number: 'PRD-1001',
      type: 1,
      saleType: SaleState.FOR_SALE,
      redemptionCycle: 'T+1',
      annualizedRate: 3.45,
      annualizedCycle: '7-day annualized',
      tip: '低波动',
      risk: 'R2',
      title: '现金管理',
      minimumPurchaseAmount: 100,
      eachCost: 1,
      performanceExplanation: 'test product'
    },
    {
      id: 1002,
      name: 'Growth Select Two',
      number: 'PRD-1002',
      type: 2,
      saleType: SaleState.FOR_SALE,
      redemptionCycle: 'T+2',
      annualizedRate: 4.12,
      annualizedCycle: 'Since launch annualized',
      tip: '精选组合',
      risk: 'R3',
      title: '稳健成长',
      minimumPurchaseAmount: 1000,
      eachCost: 10,
      performanceExplanation: 'test product'
    }
  ];
}

@Entry
@ComponentV2
struct Index {
  private vm: ProductSearchVM = ProductSearchVM.instance;

  aboutToAppear(): void {
    this.openHost();
  }

  private resetProducts(): void {
    this.vm.total = 0;
    this.vm.searchText = '';
    this.vm.productList = [];
  }

  private openHost(): void {
    this.resetProducts();
    RouterModule.clear();
    RouterModule.getStack().pushPathByName(HOST_ROUTE, null);
  }

  private openSearch(populated: boolean): void {
    this.resetProducts();
    this.vm.productList = populated ? createProductItems() : [];
    this.vm.searchText = populated ? 'stable' : '';
    RouterModule.clear();
    RouterModule.getStack().pushPathByName(HOST_ROUTE, null);
    RouterModule.getStack().pushPathByName(RouterMap.PRODUCT_SEARCH, null);
  }

  private detailId(): string {
    const param = RouterModule.getNavParam<number>({ url: RouterMap.PRODUCT_INFO });
    return param === undefined ? 'unknown' : param.toString();
  }

  @Builder
  private hostPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Text('Product Search Test Host')
          .id(HOST_ANCHOR_ID)

        Button('Show Product Search')
          .id(OPEN_POPULATED_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openSearch(true);
          })

        Button('Show Empty Product Search')
          .id(OPEN_EMPTY_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openSearch(false);
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding(16)
    }
    .hideTitleBar(true)
  }

  @Builder
  private detailPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Text(`Detail:${this.detailId()}`)
          .id(DETAIL_PARAM_ID)

        Button('Back To Product Search Host')
          .id(DETAIL_BACK_ID)
          .onClick(() => {
            this.openHost();
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding(16)
    }
    .hideTitleBar(true)
  }

  @Builder
  private routerMap(name: string) {
    if (name === HOST_ROUTE) {
      this.hostPage();
    } else if (name === RouterMap.PRODUCT_SEARCH) {
      ProductSearchBuilder();
    } else if (name === RouterMap.PRODUCT_INFO) {
      this.detailPage();
    }
  }

  build() {
    Navigation(RouterModule.getStack()) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%')
    .navDestination(this.routerMap)
  }
}
