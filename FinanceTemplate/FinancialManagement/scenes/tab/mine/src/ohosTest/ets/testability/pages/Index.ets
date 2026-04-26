import { EditNamePage, EditNamePageBuilder } from '../../../../../../../../src/main/ets/pages/EditNamePage';
import { EditPhonePage, EditPhonePageBuilder } from '../../../../../../../../src/main/ets/pages/EditPhonePage';

const HOST_ANCHOR_ID = 'mine_ohostest_anchor';

@Entry
@Component
struct Index {
  @State stack: NavPathStack = new NavPathStack();
  @State scenario: number = 0;

  @Builder
  routeBuilder(name: string) {
    if (name === 'EditNamePage') {
      EditNamePageBuilder()
    } else if (name === 'EditPhonePage') {
      EditPhonePageBuilder()
    }
  }

  build() {
    Navigation(this.stack) {
      Column() {
        Column({ space: 8 }) {
          Text('Mine ohosTest Host')
            .id(HOST_ANCHOR_ID)
            .fontSize(16)
          Row({ space: 6 }) {
            Button('S0').id('btn_s0').onClick(() => {
              this.scenario = 0;
              this.stack.clear();
            })
            Button('S1').id('btn_s1').onClick(() => {
              this.scenario = 1;
            })
            Button('S2').id('btn_s2').onClick(() => {
              this.scenario = 2;
            })
            Button('S3').id('btn_s3').onClick(() => {
              this.scenario = 0;
              this.stack.pushPathByName('EditNamePage', null);
            })
            Button('S4').id('btn_s4').onClick(() => {
              this.scenario = 0;
              this.stack.pushPathByName('EditPhonePage', null);
            })
            Button('Pop').id('btn_pop').onClick(() => {
              this.stack.pop();
            })
          }
        }
        .padding(8)
        .width('100%')
        .height(160)

        Stack() {
          if (this.scenario === 1) {
            EditNamePage()
          } else if (this.scenario === 2) {
            EditPhonePage()
          } else {
            Text('idle').id('scenario_idle')
          }
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .navDestination(this.routeBuilder)
  }
}
