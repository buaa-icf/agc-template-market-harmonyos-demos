import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { RouterModule, UserInfo } from 'lib_foundation';

const TAG = '[EditPhonePageVM]';

@ObservedV2
export class EditPhonePageVM {
  private static _instance: EditPhonePageVM;
  @Trace isLogin: boolean = false
  @Trace public cellphone: string = ''
  @Trace userInfo: UserInfo | undefined = AppStorageV2.connect(UserInfo, () => new UserInfo());

  @Monitor('userInfo.id')
  onChange(monitor: IMonitor) {
    const id = monitor.value()?.now as number;
    this.checkLogin(id)
  }

  checkLogin(id: number) {
    if (id === 0) {
      this.isLogin = false
    } else {
      this.isLogin = true
    }
  }

  public static get instance() {
    if (!EditPhonePageVM._instance) {
      EditPhonePageVM._instance = new EditPhonePageVM();
    }
    return EditPhonePageVM._instance;
  }

  init() {
    if (!this.userInfo) {
      this.cellphone = ''
      return
    }
    this.checkLogin(this.userInfo.id)
    this.cellphone = this.userInfo.cellphone
  }

  clear() {
    this.cellphone = ''
  }

  modify() {
    if (!this.userInfo) {
      return
    }
    if (!this.cellphone) {
      promptAction.showToast({
        message: '手机号不能为空',
        duration: 2000,
        alignment: Alignment.Center
      });
      return
    }

    if (this.cellphone.length !== 11) {
      promptAction.showToast({
        message: '手机号不是11位',
        duration: 2000,
        alignment: Alignment.Center
      });
      return
    }

    this.userInfo.cellphone = this.cellphone
    promptAction.showToast({ message: '修改成功！', alignment: Alignment.Center })
    RouterModule.pop()
  }
}
