import { loginComponentManager } from '@kit.AccountKit';
import { AgreementDialog } from '../../../../main/ets/view/AgreementView';
import { QuickLoginPage } from '../../../../main/ets/pages/QuickLoginPage';

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
  emptyDialogController: CustomDialogController = this.createEmptyDialogController();

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

  createEmptyDialogController(): CustomDialogController {
    return new CustomDialogController({
      builder: AgreementDialog({
        privacyText: [],
        cancel: () => {
          this.emptyDialogController.close();
        },
        confirm: () => {
          this.emptyDialogController.close();
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
      NavDestination() {
        Column({ space: 16 }) {
          Text('Terms of Service Test Destination')
            .id('agreement_terms_page_anchor')
          Button('Back')
            .id('agreement_terms_page_back')
            .onClick(() => {
              this.pathStack.pop();
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
      .hideTitleBar(true)
    } else if (name === 'PrivacyPolicyPage') {
      NavDestination() {
        Column({ space: 16 }) {
          Text('Privacy Policy Test Destination')
            .id('agreement_privacy_page_anchor')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
      .hideTitleBar(true)
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

        Button('Open Empty Agreement Dialog')
          .id('agreement_test_open_empty_dialog')
          .onClick(() => {
            this.emptyDialogController = this.createEmptyDialogController();
            this.emptyDialogController.open();
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
