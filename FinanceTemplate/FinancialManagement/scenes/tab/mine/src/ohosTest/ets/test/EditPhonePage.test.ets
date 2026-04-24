import { describe, beforeEach, afterEach, it, expect } from '@ohos/hypium';
import { EditPhonePageVM } from '../../../main/ets/viewModels/EditPhonePageVM';
import { IUserInfo } from 'network';
import { MockStorageMap } from 'network/src/main/ets/mocks/Constants';

const mockUser: IUserInfo = {
  loginToken: 'test-token',
  id: 1,
  name: 'TestUser',
  nickname: 'TestNick',
  sex: 'male',
  cellphone: '12345678901',
  birthday: '1990-01-01',
  avatar: '',
};

export default function EditPhonePageTest() {
  describe('EditPhonePageTest', () => {
    beforeEach(() => {
      EditPhonePageVM.instance.clear();
      AppStorage.delete(MockStorageMap.USER_INFO);
    });

    afterEach(() => {
      EditPhonePageVM.instance.clear();
      AppStorage.delete(MockStorageMap.USER_INFO);
    });

    it('init_loadsUserInfoAndCellphoneFromStorage', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      EditPhonePageVM.instance.init();
      expect(EditPhonePageVM.instance.userInfo !== undefined).assertTrue();
      expect(EditPhonePageVM.instance.cellphone).assertEqual(mockUser.cellphone);
    });

    it('init_doesNothingWhenStorageHasNoUserInfo', 0, () => {
      EditPhonePageVM.instance.init();
      expect(EditPhonePageVM.instance.userInfo === undefined).assertTrue();
      expect(EditPhonePageVM.instance.cellphone).assertEqual('');
    });

    it('clear_resetsUserInfoAndCellphone', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      EditPhonePageVM.instance.init();
      expect(EditPhonePageVM.instance.userInfo !== undefined).assertTrue();
      EditPhonePageVM.instance.clear();
      expect(EditPhonePageVM.instance.userInfo === undefined).assertTrue();
      expect(EditPhonePageVM.instance.cellphone).assertEqual('');
    });

    it('modify_returnsEarlyWhenUserInfoIsUndefined', 0, () => {
      const vm = EditPhonePageVM.instance;
      expect(vm.userInfo === undefined).assertTrue();
      vm.modify();
      expect(vm.cellphone).assertEqual('');
    });

    it('modify_doesNotProceedWhenCellphoneIsEmpty', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      const vm = EditPhonePageVM.instance;
      vm.init();
      vm.cellphone = '';
      vm.modify();
      expect(vm.cellphone).assertEqual('');
    });

    it('modify_doesNotProceedWhenCellphoneIsTenDigits', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      const vm = EditPhonePageVM.instance;
      vm.init();
      vm.cellphone = '1234567890';
      vm.modify();
      expect(vm.cellphone).assertEqual('1234567890');
    });

    it('modify_doesNotProceedWhenCellphoneIsTwelveDigits', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      const vm = EditPhonePageVM.instance;
      vm.init();
      vm.cellphone = '123456789012';
      vm.modify();
      expect(vm.cellphone).assertEqual('123456789012');
    });

    it('modify_proceedsWhenCellphoneIsExactlyElevenDigits', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      const vm = EditPhonePageVM.instance;
      vm.init();
      vm.cellphone = '12345678901';
      let threw = false;
      try {
        vm.modify();
      } catch (e) {
        threw = true;
      }
      expect(threw).assertFalse();
    });
  });
}
