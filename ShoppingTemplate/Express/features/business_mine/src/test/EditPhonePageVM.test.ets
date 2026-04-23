import { describe, beforeEach, afterEach, it, expect } from '@ohos/hypium';
import { EditPhonePageVM } from '../main/ets/viewModels/EditPhonePageVM';

interface FakeMonitor {
  value: () => FakeMonitorValue | undefined;
}

interface FakeMonitorValue {
  now: number;
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

function callModify(vm: EditPhonePageVM): void {
  vm.modify();
}

export default function editPhonePageVMTest() {
  describe('EditPhonePageVMTest', () => {

    let vm: EditPhonePageVM;

    beforeEach(() => {
      vm = new EditPhonePageVM();
      vm.userInfo.id = 0;
      vm.userInfo.cellphone = '';
      vm.isLogin = false;
      vm.cellphone = '';
    });

    afterEach(() => {
      vm.userInfo.id = 0;
      vm.userInfo.cellphone = '';
    });

    it('checkLogin_setsIsLoginFalseWhenIdZero', 0, () => {
      vm.isLogin = true;
      vm.checkLogin(0);
      expect(vm.isLogin).assertFalse();
    });

    it('checkLogin_setsIsLoginTrueWhenIdNonZero', 0, () => {
      vm.isLogin = false;
      vm.checkLogin(99);
      expect(vm.isLogin).assertTrue();
    });

    it('onChange_invokesCheckLoginWithMonitorNowValue', 0, () => {
      vm.isLogin = false;
      vm.onChange(buildMonitor(8) as IMonitor);
      expect(vm.isLogin).assertTrue();

      vm.onChange(buildMonitor(0) as IMonitor);
      expect(vm.isLogin).assertFalse();
    });

    it('init_copiesCellphoneAndChecksLogin', 0, () => {
      vm.userInfo.id = 5;
      vm.userInfo.cellphone = '13800000000';
      vm.init();
      expect(vm.isLogin).assertTrue();
      expect(vm.cellphone).assertEqual('13800000000');
    });

    it('init_setsIsLoginFalseWhenIdZero', 0, () => {
      vm.userInfo.id = 0;
      vm.userInfo.cellphone = '13900000000';
      vm.init();
      expect(vm.isLogin).assertFalse();
      expect(vm.cellphone).assertEqual('13900000000');
    });

    it('clear_resetsCellphoneToEmpty', 0, () => {
      vm.cellphone = '13800000000';
      vm.clear();
      expect(vm.cellphone).assertEqual('');
    });

    it('instance_isSingleton', 0, () => {
      const a = EditPhonePageVM.instance;
      const b = EditPhonePageVM.instance;
      expect(a === b).assertTrue();
    });

    it('modify_doesNotChangeWhenCellphoneEmpty', 0, () => {
      vm.userInfo.id = 1;
      vm.userInfo.cellphone = '13800000000';
      vm.cellphone = '';
      safeCall((): void => callModify(vm));
      expect(vm.userInfo.cellphone).assertEqual('13800000000');
    });

    it('modify_doesNotChangeWhenCellphoneNotElevenDigits', 0, () => {
      vm.userInfo.id = 1;
      vm.userInfo.cellphone = '13800000000';
      vm.cellphone = '12345';
      safeCall((): void => callModify(vm));
      expect(vm.userInfo.cellphone).assertEqual('13800000000');
    });

    it('modify_updatesUserInfoWhenCellphoneValid', 0, () => {
      vm.userInfo.id = 1;
      vm.userInfo.cellphone = '13800000000';
      vm.cellphone = '13912345678';
      safeCall((): void => callModify(vm));
      expect(vm.userInfo.cellphone).assertEqual('13912345678');
    });
  });
}
