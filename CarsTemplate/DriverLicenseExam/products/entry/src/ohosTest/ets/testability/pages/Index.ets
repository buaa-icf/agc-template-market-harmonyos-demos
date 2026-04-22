import { PersonalSettingBuilder } from '../../../../../../../../src/main/ets/pages/mine/PersonalSetting';
import { PrivacyAgreementBuilder } from '../../../../../../../../src/main/ets/pages/mine/PrivacyAgreement';
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
    } else if (name === 'PrivacyAgreement') {
      PrivacyAgreementBuilder();
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: 16 }) {
        Text('Personal Setting UITest Host')
          .id('personal_setting_test_host_anchor')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)

        Button('Open Personal Setting Page')
          .id('personal_setting_test_open_page')
          .onClick(() => {
            this.pathStack.pushPathByName('PersonalSetting', undefined);
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
    .onAppear(() => {
      this.vm.navStack = this.pathStack;
    })
    .navDestination(this.navDestinationBuilder);
  }
}

