import { common } from '@kit.AbilityKit';
import { BookApi, Constants, GlobalContext, TCRouter } from 'common';
import { SearchViewModels } from '../../../../../../../../src/main/ets/viewModels/SearchViewModels';
import { SearchPage } from '../../../../../../../../src/main/ets/views/SearchPage';

const HOST_ROUTE = 'search_test_host';
const DEFAULT_HOST_BUTTON_ID = 'search_test_host_open_default';
const RESULT_HOST_BUTTON_ID = 'search_test_host_open_result';
const EMPTY_HOST_BUTTON_ID = 'search_test_host_open_empty';

@Entry
@ComponentV2
struct Index {
  private updateScenario(history: string[]): void {
    const searchViewModel: SearchViewModels = SearchViewModels.instance;
    searchViewModel.keyword = '';
    searchViewModel.historyInfo = history;
    searchViewModel.hotInfo = ['小羊肖恩', '旅途'];
  }

  private openDefaultSearch(): void {
    this.updateScenario(['诛仙', '不存在的词条']);
    TCRouter.push(Constants.SEARCH_ROUTE);
  }

  private openSearchWithResult(): void {
    this.updateScenario(['诛仙']);
    TCRouter.push(Constants.SEARCH_ROUTE);
  }

  private openSearchWithoutResult(): void {
    this.updateScenario(['不存在的词条']);
    TCRouter.push(Constants.SEARCH_ROUTE);
  }

  aboutToAppear(): void {
    const hostContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    GlobalContext.initContext(hostContext);
    BookApi.init('data.json');
    AppStorage.setOrCreate('windowTopHeight', 0);

    TCRouter.init();
    TCRouter.replace(HOST_ROUTE);
    this.openDefaultSearch();
  }

  @Builder
  hostPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Button('打开默认搜索')
          .id(DEFAULT_HOST_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openDefaultSearch();
          })

        Button('打开结果搜索')
          .id(RESULT_HOST_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openSearchWithResult();
          })

        Button('打开空结果搜索')
          .id(EMPTY_HOST_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openSearchWithoutResult();
          })
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.Center)
      .padding(16)
    }
    .hideTitleBar(true)
  }

  @Builder
  routerMap(name: string) {
    if (name === HOST_ROUTE) {
      this.hostPage();
    } else if (name === Constants.SEARCH_ROUTE) {
      SearchPage();
    }
  }

  build() {
    Navigation(TCRouter.getStack()) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .navDestination(this.routerMap);
  }
}
