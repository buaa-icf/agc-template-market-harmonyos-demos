import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { RouterModule, UserInfo } from 'lib_foundation';

const TAG = '[EditNamePageVM]';

@ObservedV2
export class EditNamePageVM {
  private static _instance: EditNamePageVM;
  @Trace isLogin: boolean = false
  @Trace nickname: string = ''
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
    if (!EditNamePageVM._instance) {
      EditNamePageVM._instance = new EditNamePageVM();
    }
    return EditNamePageVM._instance;
  }

  init() {
    if (!this.userInfo) {
      this.nickname = ''
      return
    }
    this.checkLogin(this.userInfo.id)
    this.nickname = this.userInfo.nickname
  }

  clear() {
    this.nickname = ''
  }

  modify() {
    if (!this.userInfo) {
      return
    }
    if (!this.nickname) {
      promptAction.showToast({
        message: '昵称不能为空',
        duration: 2000,
        alignment: Alignment.Center
      });
      return
    }
    if (this.nickname.length > 8) {
      promptAction.showToast({
        message: '昵称不能超过8位',
        duration: 2000,
        alignment: Alignment.Center
      });
      return
    }
    this.userInfo.nickname = this.nickname
    promptAction.showToast({ message: '修改成功！', alignment: Alignment.Center })
    RouterModule.pop()
  }
}
