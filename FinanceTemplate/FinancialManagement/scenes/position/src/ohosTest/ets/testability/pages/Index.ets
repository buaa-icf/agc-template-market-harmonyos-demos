import { RouterMap, RouterModule } from 'commonlib'
import { ITransactionItem } from 'network/src/main/ets/types/responseTypes/GetTransactionRecordListResp'
import { TransactionSearchVM } from '../main/ets/viewModels/TransactionSearchVM'
import { TransactionSearchBuilder } from '../main/ets/pages/TransactionSearch'

const HOST_ROUTE: string = 'transaction_search_test_host'
const HOST_PAGE_ID: string = 'transaction_search_host_page'
const POPULATED_BUTTON_ID: string = 'transaction_search_host_populated'
const EMPTY_BUTTON_ID: string = 'transaction_search_host_empty'
const DETAIL_PARAM_ID: string = 'transaction_search_detail_param'
const DETAIL_BACK_ID: string = 'transaction_search_detail_back'

function createTransactions(): ITransactionItem[] {
  return [
    {
      id: 101,
      type: 2,
      amount: 1200,
      share: 12,
      date: '2025-03-01',
      productName: 'Alpha Fund',
      bankCardNo: '62220001',
    },
    {
      id: 102,
      type: 3,
      amount: 980,
      share: 9,
      date: '2025-03-02',
      productName: 'Beta Income',
      bankCardNo: '62220002',
    },
    {
      id: 103,
      type: 4,
      amount: 560,
      share: 5,
      date: '2025-03-03',
      productName: 'Gamma Cash',
      bankCardNo: '62220003',
    }
  ]
}

@Entry
@ComponentV2
export struct Index {
  private openSearch(items: ITransactionItem[]): void {
    const vm = TransactionSearchVM.instance
    vm.searchText = ''
    vm.total = items.length
    vm.transactionList = items
    RouterModule.clear()
    RouterModule.push({ url: HOST_ROUTE })
    RouterModule.push({ url: RouterMap.TRANSACTION_SEARCH })
  }

  private openHost(): void {
    RouterModule.clear()
    RouterModule.push({ url: HOST_ROUTE })
  }

  private currentDetailId(): number {
    return RouterModule.getNavParam<number>({ url: RouterMap.TRANSACTION_RECORD_INFO }) ?? -1
  }

  aboutToAppear(): void {
    this.openSearch(createTransactions())
  }

  @Builder
  hostPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Text('Transaction Search Host')
          .id(HOST_PAGE_ID)

        Button('Open Populated Search')
          .id(POPULATED_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openSearch(createTransactions())
          })

        Button('Open Empty Search')
          .id(EMPTY_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openSearch([])
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
  detailPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Text(`Detail:${this.currentDetailId()}`)
          .id(DETAIL_PARAM_ID)

        Button('Back To Host')
          .id(DETAIL_BACK_ID)
          .onClick(() => {
            this.openHost()
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
  routerMap(name: string) {
    if (name === HOST_ROUTE) {
      this.hostPage()
    } else if (name === RouterMap.TRANSACTION_SEARCH) {
      TransactionSearchBuilder()
    } else if (name === RouterMap.TRANSACTION_RECORD_INFO) {
      this.detailPage()
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
