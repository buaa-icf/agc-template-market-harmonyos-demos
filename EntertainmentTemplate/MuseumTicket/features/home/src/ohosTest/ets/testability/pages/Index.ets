import { RouterMap, RouterModule } from 'commonlib';
import { RecommendBar } from '../../../../../../../../src/main/ets/component/RecommendBar';
import { RecommendListItem } from '../../../../../../../../src/main/ets/types/Index';
import { HomePageVM } from '../../../../../../../../src/main/ets/viewModels/HomePageVM';

const TRANSPARENT_PIXEL: string =
  'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==';

const HOST_ANCHOR_ID = 'recommend_bar_host_anchor';
const POPULATED_BUTTON_ID = 'recommend_bar_show_populated';
const EMPTY_BUTTON_ID = 'recommend_bar_show_empty';
const DETAIL_PARAM_ID = 'recommend_bar_detail_param';
const DETAIL_BACK_ID = 'recommend_bar_detail_back';
const HOST_ROUTE = 'recommend_bar_host';

interface PerformanceDetailParam {
  id: string;
}

function cloneRecommendItem(item: RecommendListItem): RecommendListItem {
  return {
    id: item.id,
    img: item.img,
    name: item.name,
    detail: item.detail,
    price: item.price,
  };
}

function createPopulatedItems(): RecommendListItem[] {
  return [
    {
      id: 'rec-1',
      img: TRANSPARENT_PIXEL,
      name: 'Echoes of Civilisation',
      detail: 'Guided artefact tour and themed experience',
      price: 68,
    },
    {
      id: 'rec-2',
      img: TRANSPARENT_PIXEL,
      name: 'Silk Road Journey',
      detail: 'Immersive exhibition route recommendation',
      price: 88,
    },
  ];
}

@Entry
@ComponentV2
struct Index {
  @Local private scenario: string = 'populated';
  private vm: HomePageVM = HomePageVM.instance;

  aboutToAppear() {
    this.openHost('populated');
  }

  private applyScenario(scenario: string) {
    this.scenario = scenario;
    if (scenario === 'empty') {
      this.vm.recommendList = [];
      return;
    }
    this.vm.recommendList = createPopulatedItems().map(cloneRecommendItem);
  }

  private openHost(scenario: string) {
    this.applyScenario(scenario);
    RouterModule.clear();
    RouterModule.getStack().pushPathByName(HOST_ROUTE, null);
  }

  private detailId(): string {
    const detailParam = RouterModule.getNavParam<PerformanceDetailParam>({ url: RouterMap.PERFORMANCE_DETAIL });
    return detailParam?.id ?? 'unknown';
  }

  @Builder
  detailPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Text(`Detail:${this.detailId()}`)
          .id(DETAIL_PARAM_ID);

        Button('Back To Host')
          .id(DETAIL_BACK_ID)
          .onClick(() => {
            this.openHost(this.scenario);
          });
      }
      .padding(16)
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center);
    }
    .hideTitleBar(true);
  }

  @Builder
  destinationBuilder(name: string) {
    if (name === HOST_ROUTE) {
      this.hostPage();
    } else if (name === RouterMap.PERFORMANCE_DETAIL) {
      this.detailPage();
    }
  }

  @Builder
  hostPage() {
    NavDestination() {
      Column({ space: 12 }) {
        Text('RecommendBar Host').id(HOST_ANCHOR_ID);
        Text(this.scenario).id('recommend_bar_scenario_label');
        Row({ space: 12 }) {
          Button('Show Populated')
            .id(POPULATED_BUTTON_ID)
            .onClick(() => {
              this.openHost('populated');
            });
          Button('Show Empty')
            .id(EMPTY_BUTTON_ID)
            .onClick(() => {
              this.openHost('empty');
            });
        }
        RecommendBar();
      }
      .padding(16)
      .width('100%')
      .height('100%');
    }
    .hideTitleBar(true);
  }

  build() {
    Navigation(RouterModule.getStack()) {
    }
    .navDestination(this.destinationBuilder)
    .hideNavBar(true)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%');
  }
}
