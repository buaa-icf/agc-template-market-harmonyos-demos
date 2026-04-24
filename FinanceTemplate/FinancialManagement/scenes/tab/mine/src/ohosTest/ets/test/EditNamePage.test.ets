import { describe, beforeEach, afterEach, it, expect } from '@ohos/hypium';
import { EditNamePageVM } from '../../../main/ets/viewModels/EditNamePageVM';
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

export default function EditNamePageTest() {
  describe('EditNamePageTest', () => {
    beforeEach(() => {
      EditNamePageVM.instance.clear();
      AppStorage.delete(MockStorageMap.USER_INFO);
    });

    afterEach(() => {
      EditNamePageVM.instance.clear();
      AppStorage.delete(MockStorageMap.USER_INFO);
    });

    it('init_loadsUserInfoAndNicknameFromStorage', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      EditNamePageVM.instance.init();
      expect(EditNamePageVM.instance.userInfo !== undefined).assertTrue();
      expect(EditNamePageVM.instance.nickname).assertEqual(mockUser.nickname);
    });

    it('init_doesNothingWhenStorageHasNoUserInfo', 0, () => {
      EditNamePageVM.instance.init();
      expect(EditNamePageVM.instance.userInfo === undefined).assertTrue();
      expect(EditNamePageVM.instance.nickname).assertEqual('');
    });

    it('clear_resetsUserInfoAndNickname', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      EditNamePageVM.instance.init();
      expect(EditNamePageVM.instance.userInfo !== undefined).assertTrue();
      EditNamePageVM.instance.clear();
      expect(EditNamePageVM.instance.userInfo === undefined).assertTrue();
      expect(EditNamePageVM.instance.nickname).assertEqual('');
    });

    it('modify_returnsEarlyWhenUserInfoIsUndefined', 0, () => {
      const vm = EditNamePageVM.instance;
      expect(vm.userInfo === undefined).assertTrue();
      vm.modify();
      expect(vm.nickname).assertEqual('');
    });

    it('modify_doesNotProceedWhenNicknameIsEmpty', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      const vm = EditNamePageVM.instance;
      vm.init();
      vm.nickname = '';
      vm.modify();
      expect(vm.nickname).assertEqual('');
    });

    it('modify_doesNotProceedWhenNicknameHasNineChars', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      const vm = EditNamePageVM.instance;
      vm.init();
      vm.nickname = 'NineChars';
      vm.modify();
      expect(vm.nickname).assertEqual('NineChars');
    });

    it('modify_proceedsWhenNicknameIsExactlyEightChars', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      const vm = EditNamePageVM.instance;
      vm.init();
      vm.nickname = '12345678';
      let threw = false;
      try {
        vm.modify();
      } catch (e) {
        threw = true;
      }
      expect(threw).assertFalse();
    });

    it('modify_proceedsWhenNicknameIsOneChar', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      const vm = EditNamePageVM.instance;
      vm.init();
      vm.nickname = 'A';
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
