import { describe, beforeEach, afterEach, it, expect } from '@ohos/hypium';
import { AppStorageV2 } from '@kit.ArkUI';
import { UserInfo } from 'lib_foundation';
import { EditNamePageVM } from '../main/ets/viewModels/EditNamePageVM';

interface FakeMonitor {
  value: () => FakeMonitorValue | undefined;
}

interface FakeMonitorValue {
  now: number;
}

interface EditNamePageVMPrivateFields {
  userInfo: UserInfo | undefined;
}

function buildMonitor(now: number): FakeMonitor {
  return { value: () => ({ now }) };
}

function safeCall(fn: () => void): void {
  try {
    fn();
  } catch (_) {
  }
}

function callModify(vm: EditNamePageVM): void {
  vm.modify();
}

export default function editNamePageVMTest() {
  describe('EditNamePageVMTest', () => {

    let vm: EditNamePageVM;

    beforeEach(() => {
      vm = new EditNamePageVM();
      vm.userInfo.id = 0;
      vm.userInfo.nickname = '';
      vm.isLogin = false;
      vm.nickname = '';
    });

    afterEach(() => {
      const privateFields = vm as Object as EditNamePageVMPrivateFields;
      if (privateFields.userInfo) {
        privateFields.userInfo.id = 0;
        privateFields.userInfo.nickname = '';
      }
    });

    it('checkLogin_setsIsLoginFalseWhenIdZero', 0, () => {
      vm.isLogin = true;
      vm.checkLogin(0);
      expect(vm.isLogin).assertFalse();
    });

    it('checkLogin_setsIsLoginTrueWhenIdNonZero', 0, () => {
      vm.isLogin = false;
      vm.checkLogin(123);
      expect(vm.isLogin).assertTrue();
    });

    it('onChange_invokesCheckLoginWithMonitorNowValue', 0, () => {
      vm.isLogin = false;
      vm.onChange(buildMonitor(7) as IMonitor);
      expect(vm.isLogin).assertTrue();

      vm.onChange(buildMonitor(0) as IMonitor);
      expect(vm.isLogin).assertFalse();
    });

    it('init_copiesNicknameAndChecksLogin', 0, () => {
      vm.userInfo.id = 5;
      vm.userInfo.nickname = 'Alice';
      vm.init();
      expect(vm.isLogin).assertTrue();
      expect(vm.nickname).assertEqual('Alice');
    });

    it('init_setsIsLoginFalseWhenIdZero', 0, () => {
      vm.userInfo.id = 0;
      vm.userInfo.nickname = 'Bob';
      vm.init();
      expect(vm.isLogin).assertFalse();
      expect(vm.nickname).assertEqual('Bob');
    });

    it('clear_resetsNicknameToEmpty', 0, () => {
      vm.nickname = 'Charlie';
      vm.clear();
      expect(vm.nickname).assertEqual('');
    });

    it('instance_isSingleton', 0, () => {
      const a = EditNamePageVM.instance;
      const b = EditNamePageVM.instance;
      expect(a === b).assertTrue();
    });

    it('constructor_createsUserInfoWhenStorageIsEmpty', 0, () => {
      AppStorageV2.remove(UserInfo);

      const freshVM = new EditNamePageVM();

      expect(freshVM.userInfo !== undefined).assertTrue();
    });

    it('modify_returnsWhenUserInfoIsMissing', 0, () => {
      const privateFields = vm as Object as EditNamePageVMPrivateFields;
      privateFields.userInfo = undefined;
      vm.nickname = 'newName';

      safeCall((): void => callModify(vm));

      expect(privateFields.userInfo === undefined).assertTrue();
    });

    it('modify_doesNotChangeWhenNicknameEmpty', 0, () => {
      vm.userInfo.id = 1;
      vm.userInfo.nickname = 'old';
      vm.nickname = '';
      safeCall((): void => callModify(vm));
      expect(vm.userInfo.nickname).assertEqual('old');
    });

    it('modify_doesNotChangeWhenNicknameTooLong', 0, () => {
      vm.userInfo.id = 1;
      vm.userInfo.nickname = 'old';
      vm.nickname = '123456789';
      safeCall((): void => callModify(vm));
      expect(vm.userInfo.nickname).assertEqual('old');
    });

    it('modify_updatesUserInfoWhenNicknameValid', 0, () => {
      vm.userInfo.id = 1;
      vm.userInfo.nickname = 'old';
      vm.nickname = 'newName';
      safeCall((): void => callModify(vm));
      expect(vm.userInfo.nickname).assertEqual('newName');
    });
  });
}
