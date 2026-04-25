import { describe, beforeEach, afterEach, it, expect } from '@ohos/hypium'
import { EditPhonePageVM } from '../../../main/ets/viewModels/EditPhonePageVM'
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

export default function EditPhonePageVMTest() {
  describe('EditPhonePageVMTest', () => {
    beforeEach(() => {
      EditPhonePageVM.instance.clear()
      AppStorage.delete(MockStorageMap.USER_INFO)
    })

    afterEach(() => {
      EditPhonePageVM.instance.clear()
      AppStorage.delete(MockStorageMap.USER_INFO)
    })

    // singleton
    it('instance_returnsSameObjectEachTime', 0, () => {
      const a = EditPhonePageVM.instance
      const b = EditPhonePageVM.instance
      expect(a === b).assertTrue()
    })

    // init: AppStorage has USER_INFO
    it('init_setsUserInfoAndCellphoneWhenStorageHasUser', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      EditPhonePageVM.instance.init()
      expect(EditPhonePageVM.instance.userInfo !== undefined).assertTrue()
      expect(EditPhonePageVM.instance.cellphone).assertEqual('13800000000')
    })

    // init: AppStorage empty
    it('init_leavesUserInfoUndefinedWhenStorageEmpty', 0, () => {
      EditPhonePageVM.instance.init()
      expect(EditPhonePageVM.instance.userInfo === undefined).assertTrue()
      expect(EditPhonePageVM.instance.cellphone).assertEqual('')
    })

    // clear
    it('clear_resetsUserInfoAndCellphoneToDefaults', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      EditPhonePageVM.instance.init()
      expect(EditPhonePageVM.instance.userInfo !== undefined).assertTrue()
      EditPhonePageVM.instance.clear()
      expect(EditPhonePageVM.instance.userInfo === undefined).assertTrue()
      expect(EditPhonePageVM.instance.cellphone).assertEqual('')
    })

    // modify: userInfo undefined early return
    it('modify_returnsEarlyWhenUserInfoIsUndefined', 0, () => {
      const vm = EditPhonePageVM.instance
      expect(vm.userInfo === undefined).assertTrue()
      vm.cellphone = '13800000000'
      vm.modify()
      expect(vm.cellphone).assertEqual('13800000000')
    })

    // modify: empty cellphone early return
    it('modify_returnsEarlyWhenCellphoneIsEmpty', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      const vm = EditPhonePageVM.instance
      vm.init()
      vm.cellphone = ''
      vm.modify()
      expect(vm.cellphone).assertEqual('')
    })

    // modify: cellphone length < 11 early return
    it('modify_returnsEarlyWhenCellphoneIsTenDigits', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      const vm = EditPhonePageVM.instance
      vm.init()
      vm.cellphone = '1234567890'
      vm.modify()
      expect(vm.cellphone).assertEqual('1234567890')
    })

    // modify: cellphone length > 11 early return
    it('modify_returnsEarlyWhenCellphoneIsTwelveDigits', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      const vm = EditPhonePageVM.instance
      vm.init()
      vm.cellphone = '123456789012'
      vm.modify()
      expect(vm.cellphone).assertEqual('123456789012')
    })

    // modify: exactly 11 digits — proceeds without error
    it('modify_proceedsWhenCellphoneIsExactlyElevenDigits', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      const vm = EditPhonePageVM.instance
      vm.init()
      vm.cellphone = '13800000000'
      let threw = false
      try {
        vm.modify()
      } catch (e) {
        threw = true
      }
      expect(threw).assertFalse()
    })

    // modify: valid cellphone proceeds without error (different valid number)
    it('modify_proceedsWhenCellphoneIsValidElevenDigits', 0, () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser)
      const vm = EditPhonePageVM.instance
      vm.init()
      vm.cellphone = '18912345678'
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
