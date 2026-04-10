import { loginComponentManager } from '@kit.AccountKit';
import { AgreementDialog } from '../../../../main/ets/view/AgreementView';
import { PrivacyPolicyPage } from '../../../../main/ets/pages/PrivacyPolicyPage';
import { QuickLoginPage } from '../../../../main/ets/pages/QuickLoginPage';
import { TermsOfServicePage } from '../../../../main/ets/pages/TermsOfServicePage';

@Entry
@ComponentV2
struct Index {
  pathStack: NavPathStack = new NavPathStack();
  privacyText: loginComponentManager.PrivacyText[] = [{
    text: $r('app.string.agree'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: $r('app.string.shopping_user_agreement'),
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: $r('app.string.and'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: $r('app.string.shopping_privacy_policy'),
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: $r('app.string.end'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }];
  dialogController: CustomDialogController = this.createDialogController();

  createDialogController(): CustomDialogController {
    return new CustomDialogController({
      builder: AgreementDialog({
        privacyText: this.privacyText,
        cancel: () => {
          this.dialogController.close();
        },
        confirm: () => {
          this.dialogController.close();
        },
        pathStack: this.pathStack
      }),
      autoCancel: false,
      alignment: DialogAlignment.Center
    });
  }

  @Builder
  navDestinationBuilder(name: string, param?: Object) {
    if (name === 'QuickLoginPage') {
      QuickLoginPage();
    } else if (name === 'TermsOfServicePage') {
      TermsOfServicePage();
    } else if (name === 'PrivacyPolicyPage') {
      PrivacyPolicyPage();
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: 16 }) {
        Text('Agreement Dialog UITest Host')
          .id('agreement_test_host_anchor')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)

        Button('Open Agreement Dialog')
          .id('agreement_test_open_dialog')
          .onClick(() => {
            this.dialogController = this.createDialogController();
            this.dialogController.open();
          })

        Text('Quick Login UITest Host')
          .id('quick_login_test_host_anchor')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)

        Button('Open Quick Login Page')
          .id('quick_login_test_open_page')
          .onClick(() => {
            this.pathStack.pushPathByName('QuickLoginPage', null);
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
    .navDestination(this.navDestinationBuilder);
  }
}
