import { describe, expect, it } from '@ohos/hypium';
import { IUserInfo } from '../main/ets/model/IResponse';
import { AppStorageBank, UserInfo } from '../main/ets/model/ObserveModel';

export default function ObserveModelTest() {
  describe('ObserveModelTest', () => {
    it('copies every response field into the shared user information model', 0, () => {
      AppStorageBank.userInfo = new UserInfo();
      const source: IUserInfo = {
        loginToken: 'token-1', id: 7, name: 'name', nickname: 'nickname', sex: 'female', cellphone: '13800000000',
        birthday: '2000-01-01', avatar: 'avatar.png', isVip: true, points: 99, couponList: [1, 2], realNameAuthFlag: 1
      };

      AppStorageBank.updateUserInfo(source);

      expect(AppStorageBank.userInfo.loginToken).assertEqual('token-1');
      expect(AppStorageBank.userInfo.id).assertEqual(7);
      expect(AppStorageBank.userInfo.nickname).assertEqual('nickname');
      expect(AppStorageBank.userInfo.points).assertEqual(99);
      expect(AppStorageBank.userInfo.couponList.length).assertEqual(2);
      expect(AppStorageBank.userInfo.realNameAuthFlag).assertEqual(1);
    });
  });
}
