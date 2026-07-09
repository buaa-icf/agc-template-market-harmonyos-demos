import { PersonalSettingBuilder } from '../../../../../../../../src/main/ets/pages/mine/PersonalSetting';
import { CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';

@Entry
@ComponentV2
struct Index {
  pathStack: NavPathStack = new NavPathStack();
  vm: CommonModel = CommonModel.instance;

  @Builder
  navDestinationBuilder(name: string, param?: Object) {
    if (name === 'PersonalSetting') {
      PersonalSettingBuilder();
    }
  }

  aboutToAppear(): void {
    AppStorage.setOrCreate('topRectHeight', 0);
    this.vm.navStack = this.pathStack;
    this.pathStack.pushPathByName('PersonalSetting', undefined);
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Text('Personal Setting UITest Host')
          .id('personal_setting_test_host_anchor')
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .navDestination(this.navDestinationBuilder);
  }
}
