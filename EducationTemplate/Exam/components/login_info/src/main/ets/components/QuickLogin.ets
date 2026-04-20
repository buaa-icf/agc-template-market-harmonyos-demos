/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { AccountUtil } from '../utils/AccountUtil';
import { UserInfo } from '../model/UserInfo';
import { ErrorCode } from '../model/ErrorCode';
import { AgreementDialog } from './AgreementDialog';

@ComponentV2
export struct QuickLogin {
  logTag: string = 'QuickLoginButtonComponent';
  domainId: number = 0x0000;
  // 是否显示半屏模态页面
  @Param isBindContentCover: boolean = false;
  // 是否勾选协议
  @Local isSelected: boolean = false;
  // 参考华为账号开发指南获取匿名手机号
  @Local quickLoginAnonymousPhone: string = '';
  //传入的图标按钮
  @Param @Require icon: ResourceStr
  //自定义登录颜色
  @Param @Require loginBtnBgColor: string | ResourceStr
  //app名字
  @Param @Require appName: string = ''
  // 是否为mock数据
  @Local isMock: boolean = true;
  // 展示用户服务协议、隐私协议和华为账号用户认证协议
  privacyText: loginComponentManager.PrivacyText[] = [{
    text: '已阅读并同意',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《用户服务协议》',
    tag: '用户服务协议',
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: '《' + this.appName + '隐私协议》',
    tag: '隐私协议',
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: '和',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《华为账号用户认证协议》',
    tag: '华为账号用户认证协议',
    type: loginComponentManager.TextType.RICH_TEXT
  }];
  /*
* 华为一键登录点击事件
* */
  @Event onLoginWithHuaweiID: () => void = () => {
  }
  /*
   * 隐私协议点击事件
   * */
  @Event onPrivacyPolicy: () => void = () => {
  }
  /*
   * 服务协议点击事件
   * */
  @Event onServicePolicy: () => void = () => {
  }
  /*
   * 华为用户账号认证点击事件
   * */
  @Event onHYAccountRouter: () => void = () => {
  }
  /*
  * 模态弹窗消失事件
  * */
  @Event shouldDismiss: () => void = () => {
  }
  private static USER_AUTHENTICATION_TAG = '华为账号用户认证协议';
  private static USER_SERVICE_TAG = '用户服务协议';
  private static USER_PRIVACY_TAG = '隐私协议';
  // 构造LoginWithHuaweiIDButton组件的控制器
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      /**
       * 当应用使用自定义的登录页时，如果用户未同意协议，需要设置协议状态为NOT_ACCEPTED，当用户同意协议后再设置
       * 协议状态为ACCEPTED，才可以使用华为账号一键登录功能
       */
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        this.handleLoginWithHuaweiIDButton(error, response);
      })
      .onClickEvent((error: BusinessError) => {
        if (error) {
          this.dealAllError(error);
          return;
        }
      });
  agreementDialog: CustomDialogController = new CustomDialogController({
    builder: AgreementDialog({
      privacyText: this.privacyText,
      cancel: () => {
        this.agreementDialog.close();
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
      },
      confirm: () => {
        this.agreementDialog.close();
        this.isSelected = true;
        if (this.isMock) {
          this.onLoginWithHuaweiID()
          let prop: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())! as UserInfo
          if (!prop.name) {
            prop.name = '华为用户'
          }
          prop.isLogin = true
          prop.id = 0
          prop.cellphone = '177******96'
          prop.address = 'xxx省xxx市'
          return
        }
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
        // 调用此方法，同意协议与登录一并完成，无需再次点击登录按钮
        this.controller.continueLogin(() => {
        });
      },
      clickHyperlinkText: (tag) => {
        this.agreementDialog.close();
        if (tag === QuickLogin.USER_AUTHENTICATION_TAG) {
          this.onHYAccountRouter();
        } else if (tag === QuickLogin.USER_SERVICE_TAG) {
          this.onServicePolicy()
        } else if (tag === QuickLogin.USER_PRIVACY_TAG) {
          this.onPrivacyPolicy()
        }
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  // 错误处理
  dealAllError(_error: BusinessError): void {
  }

  // Toast提示
  showToast(resource: string) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: resource,
        duration: 2000
      });
    } catch (error) {
      //在此处进行异常处理
    }
  }

  handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    // 本地mock登录
    if (this.isMock) {
      if (this.isSelected) {
        this.onLoginWithHuaweiID()
        let prop = AppStorageV2.connect(UserInfo, () => new UserInfo())!
        prop.isLogin = true
        if (!prop.name) {
          prop.name = '华为用户'
        }
        prop.id = 0
        prop.cellphone = '177******96'
        prop.address = 'xxx省xxx市'
      } else {
        this.agreementDialog.open();
      }
      return
    }
    if (error) {
      if (error.code === ErrorCode.ERROR_CODE_NETWORK_ERROR) {
        this.showToast('网络异常，请检查网络设置。');
      } else if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        // 未同意协议，弹出协议弹框，推荐使用该回调方式
        this.agreementDialog.open();
      } else if (error.code === ErrorCode.ERROR_CODE_LOGIN_OUT) {
        // 华为账号未登录提示
        this.showToast('华为账号未登录，请重试');
      } else if (error.code === ErrorCode.ERROR_CODE_NOT_SUPPORTED) {
        // 不支持该scopes或permissions提示
        this.showToast('该scopes或permissions不支持');
      } else if (error.code === ErrorCode.ERROR_CODE_PARAMETER_ERROR) {
        // 参数错误提示
        this.showToast('参数错误');
      } else {
        // 其他提示系统或服务异常
        this.showToast('服务或网络异常，请稍后重试');
      }
      return;
    }
    try {
      if (this.isSelected) {
        if (response) {
          this.onLoginWithHuaweiID()
        }
      } else {
        this.agreementDialog.open();
      }
    } catch (err) {
      AlertDialog.show(
        {
          message: '服务或网络异常，请稍后重试',
          offset: { dx: 0, dy: -12 },
          alignment: DialogAlignment.Bottom,
          autoCancel: false,
          confirm: {
            value: '知道了',
            action: () => {
            }
          }
        }
      );
    }
  }

  aboutToAppear(): void {
    if (AccountUtil.getQuickLoginAnonymousPhone()) {
      this.isMock = false
      this.quickLoginAnonymousPhone = AccountUtil.getQuickLoginAnonymousPhone()
    } else {
      this.quickLoginAnonymousPhone = '177******96'
      this.isMock = true
    }
  }

  @Builder
  CoverLogin() {
    Column() {
      Column() {
        Column() {
          Image(this.icon)
            .id('quick_login_cover_icon')
            .width(48)
            .height(48)
            .draggable(false)
            .copyOption(CopyOptions.None)
            .onComplete(() => {
            })
            .onError(() => {
            })
          Column() {
            Text(this.quickLoginAnonymousPhone)
              .id('quick_login_cover_phone')
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              .fontSize(36)
              .lineHeight(48)
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .constraintSize({ maxWidth: '100%', minHeight: 48 })
              .textAlign(TextAlign.Center)
            Text('华为账号绑定号码')
              .id('quick_login_cover_desc')
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .fontWeight(FontWeight.Regular)
              .lineHeight(19)
              .textAlign(TextAlign.Center)
              .maxLines(1)
              .constraintSize({ maxWidth: '100%' })
              .margin({
                top: 8
              })
          }.margin({
            top: 64
          })

          Column() {
            LoginWithHuaweiIDButton({
              params: {
                // LoginWithHuaweiIDButton支持的样式
                style: loginComponentManager.Style.BUTTON_CUSTOM,
                customButtonParams: {
                  backgroundColor: this.loginBtnBgColor
                },
                // 账号登录按钮在登录过程中展示加载态
                extraStyle: {
                  buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                    show: true
                  })
                },
                // LoginWithHuaweiIDButton的边框圆角半径
                borderRadius: 24,
                // LoginWithHuaweiIDButton支持的登录类型
                loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                // LoginWithHuaweiIDButton支持按钮的样式跟随系统深浅色模式切换
                supportDarkMode: true,
                // verifyPhoneNumber：如果华为账号用户在过去90天内未进行短信验证，是否拉起Account Kit提供的短信验证码页面
                verifyPhoneNumber: true
              },
              controller: this.controller
            })
            .id('quick_login_cover_login_button')
          }
          .height(40)
          .width('100%')
          .margin({
            top: 56
          })
        }.width('100%')

        Row() {
          Row() {
            Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
              .id('quick_login_cover_privacy_checkbox')
              .width(24)
              .height(24)
              .focusable(true)
              .focusOnTouch(true)
              .margin({ top: 0 })
              .onChange((value: boolean) => {
                if (value) {
                  this.isSelected = true;
                  this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
                } else {
                  this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
                  this.isSelected = false;
                }
              })
          }

          Row() {
            Text() {
              ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
                if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                  Span(item?.text)
                    .fontColor($r('sys.color.font_secondary'))
                    .fontWeight(FontWeight.Regular)
                    .fontSize($r('sys.float.Body_S'))
                } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
                  Span(item?.text)
                    .fontColor($r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)
                    .fontSize($r('sys.float.Body_S'))
                    .focusable(true)
                    .focusOnTouch(true)
                    .onClick(() => {
                      // 应用需要根据item.tag实现协议页面的跳转逻辑
                      if (item.tag === QuickLogin.USER_SERVICE_TAG) {
                        this.onServicePolicy()
                      }
                      if (item.tag === QuickLogin.USER_PRIVACY_TAG) {
                        this.onPrivacyPolicy()
                      }
                      if (item.tag === QuickLogin.USER_AUTHENTICATION_TAG) {
                        this.onHYAccountRouter()
                      }
                    })
                }
              }, (item: loginComponentManager.PrivacyText) => item.text.toString())
            }
            .id('quick_login_cover_privacy_text')
            .width('100%')
          }
          .margin({ left: 12 })
          .layoutWeight(1)
          .constraintSize({ minHeight: 24 })
        }
        .alignItems(VerticalAlign.Top)
        .margin({
          top: 16,
          bottom: 16
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .constraintSize({ minHeight: '100%' })
      .margin({
        left: 16,
        right: 16
      })
    }
    .backgroundColor(Color.White)
    .id('quick_login_cover_root')
    .width('100%')
    .height('100%')
    .padding({ top: '154vp' })
  }

  @Builder
  DefaultLogin() {
    Column() {
      Column() {
        Column() {
          Image(this.icon)
            .width(48)
            .height(48)
            .draggable(false)
            .copyOption(CopyOptions.None)
            .onComplete(() => {
            })
            .onError(() => {
            })
          Column() {
            Text(this.quickLoginAnonymousPhone)
              .fontSize(36)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              .constraintSize({ maxWidth: '100%', minHeight: 48 })
              .lineHeight(48)
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textAlign(TextAlign.Center)
            Text('华为账号绑定号码')
              .fontWeight(FontWeight.Regular)
              .maxLines(1)
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .lineHeight(19)
              .constraintSize({ maxWidth: '100%' })
              .textAlign(TextAlign.Center)
              .margin({
                top: 8
              })
          }.margin({ top: 48 });
        }.width('100%')

        Column().layoutWeight(1)
        Column() {
          LoginWithHuaweiIDButton({
            params: {
              // LoginWithHuaweiIDButton支持的样式
              style: loginComponentManager.Style.BUTTON_CUSTOM,
              customButtonParams: {
                backgroundColor: this.loginBtnBgColor
              },
              // 账号登录按钮在登录过程中展示加载态
              extraStyle: {
                buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                  show: true
                })
              },
              // LoginWithHuaweiIDButton的边框圆角半径
              borderRadius: 24,
              // LoginWithHuaweiIDButton支持的登录类型
              loginType: loginComponentManager.LoginType.QUICK_LOGIN,
              // LoginWithHuaweiIDButton支持按钮的样式跟随系统深浅色模式切换
              supportDarkMode: true,
              // verifyPhoneNumber：如果华为账号用户在过去90天内未进行短信验证，是否拉起Account Kit提供的短信验证码页面
              verifyPhoneNumber: true
            },
            controller: this.controller
          })
            .height(40)
            .width('100%')
          Row() {
            Row() {
              Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
                .width(24)
                .height(24)
                .focusable(true)
                .focusOnTouch(true)
                .margin({ top: 0 })
                .onChange((value: boolean) => {
                  if (value) {
                    this.isSelected = true;
                    this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
                  } else {
                    this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
                    this.isSelected = false;
                  }
                })
            }

            Row() {
              Text() {
                ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
                  if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                    Span(item?.text)
                      .fontColor($r('sys.color.font_secondary'))
                      .fontWeight(FontWeight.Regular)
                      .fontSize($r('sys.float.Body_S'))
                  } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
                    Span(item?.text)
                      .fontColor($r('sys.color.font_primary'))
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r('sys.float.Body_S'))
                      .focusable(true)
                      .focusOnTouch(true)
                      .onClick(() => {
                        // 应用需要根据item.tag实现协议页面的跳转逻辑
                        if (item.tag === QuickLogin.USER_SERVICE_TAG) {
                          this.onServicePolicy()
                        }
                        if (item.tag === QuickLogin.USER_PRIVACY_TAG) {
                          this.onPrivacyPolicy()
                        }
                        if (item.tag === QuickLogin.USER_AUTHENTICATION_TAG) {
                          this.onHYAccountRouter()
                        }
                      })
                  }
                }, (item: loginComponentManager.PrivacyText) => item.text.toString())
              }
              .width('100%')
            }
            .margin({ left: 12 })
            .layoutWeight(1)
            .constraintSize({ minHeight: 24 })
          }
          .alignItems(VerticalAlign.Top)
          .margin({ top: 20, bottom: 16 })
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({
        top: 80,
        bottom: 20,
        left: 16,
        right: 16
      });
    }
    .width('100%')
    .height(500)
  }

  build() {
    Column() {
      if (this.isBindContentCover) {
        Text()
          .bindContentCover(true, this.CoverLogin(), {
            backgroundColor: Color.White,
            onWillDisappear: () => {
              this.shouldDismiss();
            }
          })
      } else {
        Text()
          .bindSheet(true, this.DefaultLogin(), {
            // Text绑定半模态转场
            height: SheetSize.FIT_CONTENT, // 半模态高度
            dragBar: true, // 是否显示控制条
            backgroundColor: Color.White,
            showClose: true, // 是否显示关闭图标
            shouldDismiss: ((sheetDismiss: SheetDismiss) => { // 半模态页面交互式关闭回调函数
              this.shouldDismiss();
              sheetDismiss.dismiss();
            })
          })
      }
    }
    .width('100%')
    .height('100%')
  }
}
