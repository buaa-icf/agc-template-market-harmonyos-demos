import { RouterMap, RouterModule } from 'commonlib';
import { AddVisitorPageBuilder } from '../../../../../../../../src/main/ets/pages/AddVisitorPage';
import { Contacts } from '../../../../../../../../src/main/ets/types/Index';
import { MinePageVM } from '../../../../../../../../src/main/ets/viewModels/MinePageVM';

const HOST_ROUTE = 'add_visitor_test_host';
const HOST_ANCHOR_ID = 'add_visitor_host_anchor';
const POPULATED_BUTTON_ID = 'add_visitor_show_populated';
const EMPTY_BUTTON_ID = 'add_visitor_show_empty';

function createPopulatedContactInfo(): Contacts {
  return {
    personID: 'test-contact-001',
    name: '测试参观人',
    cardType: '身份证',
    cardID: '110101199003079876',
    phone: '13812345678'
  };
}

@Entry
@ComponentV2
struct Index {
  private vm: MinePageVM = MinePageVM.instance;

  aboutToAppear(): void {
    this.openHost();
  }

  private openHost(): void {
    this.vm.clear();
    RouterModule.clear();
    RouterModule.getStack().pushPathByName(HOST_ROUTE, null);
  }

  private openAddVisitor(contactInfo: Contacts | undefined): void {
    this.vm.contactInfo = contactInfo;
    RouterModule.clear();
    RouterModule.getStack().pushPathByName(HOST_ROUTE, null);
    RouterModule.getStack().pushPathByName(RouterMap.ADD_VISITOR, null);
  }

  @Builder
  private hostPage() {
    NavDestination() {
      Column({ space: 16 }) {
        Text('Add Visitor Host')
          .id(HOST_ANCHOR_ID)

        Button('打开预填联系人页')
          .id(POPULATED_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openAddVisitor(createPopulatedContactInfo());
          })

        Button('打开空白联系人页')
          .id(EMPTY_BUTTON_ID)
          .width('100%')
          .onClick(() => {
            this.openAddVisitor(undefined);
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
