import { describe, beforeEach, afterEach, it, expect } from '@ohos/hypium'
import { EditNamePageVM } from '../../../main/ets/viewModels/EditNamePageVM'
import { MockStorageMap } from 'network/src/main/ets/mocks/Constants'
import { IUserInfo } from 'network'

const mockUser: IUserInfo = {
  loginToken: 'tok',
  id: 1,
  name: 'Alice',
  nickname: 'ali',
  sex: 'F',
  cellphone: '13800000000',
  birthday: '2000-01-01',
  avatar: '',
}

export default function EditNamePageVMTest() {
  describe('EditNamePageVMTest', () => {
    beforeEach(() => {
      EditNamePageVM.instance.clear()
      AppStorage.delete(MockStorageMap.USER_INFO)
    })

    afterEach(() => {
      EditNamePageVM.instance.clear()
      AppStorage.delete(MockStorageMap.USER_INFO)
    })

    // singleton
    it('instance_returnsSameObjectEachTime', 0, () => {
      const a = EditNamePageVM.instance
      const b = EditNamePageVM.instance
      expect(a === b).assertTrue()
    })

    // init: AppStorage has USER_INFO
    it('init_setsUserInfoAndNicknameWhenStorageHasUser', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      EditNamePageVM.instance.init()
      expect(EditNamePageVM.instance.userInfo !== undefined).assertTrue()
      expect(EditNamePageVM.instance.nickname).assertEqual('ali')
    })

    // init: AppStorage empty
    it('init_leavesUserInfoUndefinedWhenStorageEmpty', 0, () => {
      EditNamePageVM.instance.init()
      expect(EditNamePageVM.instance.userInfo === undefined).assertTrue()
      expect(EditNamePageVM.instance.nickname).assertEqual('')
    })

    // clear
    it('clear_resetsUserInfoAndNicknameToDefaults', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      EditNamePageVM.instance.init()
      expect(EditNamePageVM.instance.userInfo !== undefined).assertTrue()
      EditNamePageVM.instance.clear()
      expect(EditNamePageVM.instance.userInfo === undefined).assertTrue()
      expect(EditNamePageVM.instance.nickname).assertEqual('')
    })

    // modify: userInfo undefined early return
    it('modify_returnsEarlyWhenUserInfoIsUndefined', 0, () => {
      const vm = EditNamePageVM.instance
      expect(vm.userInfo === undefined).assertTrue()
      vm.nickname = 'test'
      vm.modify()
      expect(vm.nickname).assertEqual('test')
    })

    // modify: empty nickname early return
    it('modify_returnsEarlyWhenNicknameIsEmpty', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      const vm = EditNamePageVM.instance
      vm.init()
      vm.nickname = ''
      vm.modify()
      expect(vm.nickname).assertEqual('')
    })

    // modify: nickname length > 8 early return
    it('modify_returnsEarlyWhenNicknameExceedsEightChars', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      const vm = EditNamePageVM.instance
      vm.init()
      vm.nickname = 'toolongname'
      vm.modify()
      expect(vm.nickname).assertEqual('toolongname')
    })

    // modify: nickname exactly 8 chars (boundary — does not early-return)
    it('modify_proceedsWhenNicknameIsExactlyEightChars', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      const vm = EditNamePageVM.instance
      vm.init()
      vm.nickname = '12345678'
      let threw = false
      try {
        vm.modify()
      } catch (e) {
        threw = true
      }
      expect(threw).assertFalse()
    })

    // modify: valid short nickname proceeds without error
    it('modify_proceedsWhenNicknameIsValid', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      const vm = EditNamePageVM.instance
      vm.init()
      vm.nickname = 'newname'
      let threw = false
      try {
        vm.modify()
      } catch (e) {
        threw = true
      }
      expect(threw).assertFalse()
    })
  })
}
