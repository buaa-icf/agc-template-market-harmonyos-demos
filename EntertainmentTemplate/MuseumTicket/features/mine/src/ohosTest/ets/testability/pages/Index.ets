import { RouterMap, RouterModule } from 'commonlib';
import { RecommendBar } from '../../../../../../../../src/main/ets/components/RecommendBar';
import { AddVisitorPageBuilder } from '../../../../../../../../src/main/ets/pages/AddVisitorPage';
import { EditVisitorPageBuilder } from '../../../../../../../../src/main/ets/pages/EditVisitorPage';
import { Contacts, RecommendListItem } from '../../../../../../../../src/main/ets/types/Index';
import { MinePageVM } from '../../../../../../../../src/main/ets/viewModels/MinePageVM';

const HOST_ROUTE = 'add_visitor_test_host';
const HOST_ANCHOR_ID = 'add_visitor_host_anchor';
const POPULATED_BUTTON_ID = 'add_visitor_show_populated';
const EMPTY_BUTTON_ID = 'add_visitor_show_empty';
const EDIT_POPULATED_BUTTON_ID = 'edit_visitor_show_populated';
const RECOMMEND_POPULATED_BUTTON_ID = 'mine_recommend_show_populated';
const RECOMMEND_EMPTY_BUTTON_ID = 'mine_recommend_show_empty';
const RECOMMEND_DETAIL_PARAM_ID = 'mine_recommend_detail_param';
const RECOMMEND_DETAIL_BACK_ID = 'mine_recommend_detail_back';

interface PerformanceDetailParam {
  id: string;
}

function createPopulatedContactInfo(): Contacts {
  return {
    personID: 'test-contact-001',
    name: 'Test Visitor',
    cardType: 'Identity Card',
    cardID: '110101199003079876',
    phone: '13812345678'
  };
}

function createRecommendItems(): RecommendListItem[] {
  return [
    {
      id: 'mine-rec-1',
      img: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==',
      name: 'Mine Collection Tour',
      detail: 'Personalised museum route from mine page',
      price: 58
    },
    {
      id: 'mine-rec-2',
      img: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==',
      name: 'Family Audio Guide',
      detail: 'Recommended guide package for visitors',
      price: 76
    }
  ];
}

@Entry
@ComponentV2
struct Index {
  @Local private recommendScenario: string = 'idle';
  private vm: MinePageVM = MinePageVM.instance;

  aboutToAppear(): void {
    this.openHost();
  }

  private openHost(): void {
    this.vm.clear();
    this.vm.recommendList = [];
    this.recommendScenario = 'idle';
    RouterModule.clear();
    RouterModule.getStack().pushPathByName(HOST_ROUTE, null);
  }

  private openAddVisitor(contactInfo: Contacts | undefined): void {
    this.vm.contactInfo = contactInfo;
    this.vm.recommendList = [];
    this.recommendScenario = 'idle';
    RouterModule.clear();
    RouterModule.getStack().pushPathByName(HOST_ROUTE, null);
    RouterModule.getStack().pushPathByName(RouterMap.ADD_VISITOR, null);
  }

  private openEditVisitor(contactInfo: Contacts): void {
    this.vm.clear();
    this.vm.recommendList = [];
    this.recommendScenario = 'idle';
    RouterModule.clear();
    RouterModule.getStack().pushPathByName(HOST_ROUTE, null);
    RouterModule.push({ url: RouterMap.EDIT_VISITOR, param: { contactInfo: contactInfo } });
  }

  private openRecommend(scenario: string): void {
    this.recommendScenario = scenario;
    this.vm.recommendList = scenario === 'empty' ? [] : createRecommendItems();
    RouterModule.clear();
    RouterModule.getStack().pushPathByName(HOST_ROUTE, null);
  }

  private recommendDetailId(): string {
    const detailParam = RouterModule.getNavParam<PerformanceDetailParam>({ url: RouterMap.PERFORMANCE_DETAIL });
    return detailParam?.id ?? 'unknown';
  }

  @Builder
  private hostPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Text('Mine Test Host')
          .id(HOST_ANCHOR_ID)

        Button('Open Add Visitor With Data')
          .id(POPULATED_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openAddVisitor(createPopulatedContactInfo());
          })

        Button('Open Empty Add Visitor')
          .id(EMPTY_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openAddVisitor(undefined);
          })

        Button('Open Edit Visitor')
          .id(EDIT_POPULATED_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openEditVisitor(createPopulatedContactInfo());
          })

        Button('Show Mine Recommend')
          .id(RECOMMEND_POPULATED_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openRecommend('populated');
          })

        Button('Show Empty Mine Recommend')
          .id(RECOMMEND_EMPTY_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openRecommend('empty');
          })

        RecommendBar()
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding(16)
    }
    .hideTitleBar(true)
  }

  @Builder
  private recommendDetailPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Text(`Detail:${this.recommendDetailId()}`)
          .id(RECOMMEND_DETAIL_PARAM_ID)

        Button('Back To Mine Recommend Host')
          .id(RECOMMEND_DETAIL_BACK_ID)
          .onClick(() => {
            this.openRecommend(this.recommendScenario === 'empty' ? 'empty' : 'populated');
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
    } else if (name === RouterMap.ADD_VISITOR) {
      AddVisitorPageBuilder();
    } else if (name === RouterMap.EDIT_VISITOR) {
      EditVisitorPageBuilder();
    } else if (name === RouterMap.PERFORMANCE_DETAIL) {
      this.recommendDetailPage();
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
