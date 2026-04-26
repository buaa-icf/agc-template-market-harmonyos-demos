import { TimeCtrl, TimeCtrlBuilder } from '../../../../../../../../src/main/ets/views/settings/TimeCtrl';
import { CommonConstants, GlobalContext } from '@ohos_agcit/children_education_utils';

const HOST_ANCHOR_ID = 'minepage_ohostest_anchor';

@Entry
@ComponentV2
struct Index {
  @Provider(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Local stack: NavPathStack = this.appPathStack;
  @Local scenario: number = 0;

  aboutToAppear(): void {
    // Seed required GlobalContext keys before TimeCtrl onShown reads them.
    const ctx = GlobalContext.getContext();
    ctx.setObject(CommonConstants.TIME_LIMIT, '30分钟');
    ctx.setObject(CommonConstants.LUNCH_START_TIME, '12:00');
    ctx.setObject(CommonConstants.LUNCH_END_TIME, '13:30');
    ctx.setObject(CommonConstants.NIGHT_START_TIME, '21:00');
    ctx.setObject(CommonConstants.NIGHT_END_TIME, '07:00');
    ctx.setObject(CommonConstants.LUNCH_TIME_STATE, true);
    ctx.setObject(CommonConstants.NIGHT_TIME_STATE, true);
  }

  @Builder
  routeBuilder(name: string) {
    if (name === 'TimeCtrl') {
      TimeCtrlBuilder()
    }
  }

  build() {
    Navigation(this.stack) {
      Column() {
        Column({ space: 8 }) {
          Text('Minepage ohosTest Host')
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
              this.scenario = 0;
              this.stack.pushPathByName('TimeCtrl', null);
            })
            Button('Pop').id('btn_pop').onClick(() => {
              this.stack.pop();
            })
          }
        }
        .padding(8)
        .width('100%')
        .height(140)

        Stack() {
          if (this.scenario === 1) {
            TimeCtrl()
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
