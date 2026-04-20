import { describe, it, expect } from '@ohos/hypium';
import { UserInfo } from '../main/ets/model/User';
import { BasicUserInfo } from '../main/ets/model/BasicUserInfo';

export default function userTest() {
  describe('UserInfoTest', () => {
    it('toBasicUserInfo_shouldMapAllFields', 0, () => {
      const userInfo: UserInfo = new UserInfo();
      userInfo.uid = 1001;
      userInfo.userNo = 'U2026';
      userInfo.nickName = 'Alice';
      userInfo.profilePictureUrl = 'https://example.com/a.png';
      userInfo.isVip = 1;
      userInfo.realNameAuthFlag = 1;
      userInfo.gender = 2;

      const basic: BasicUserInfo = UserInfo.toBasicUserInfo(userInfo);

      expect(basic.uid).assertEqual(1001);
      expect(basic.userNo).assertEqual('U2026');
      expect(basic.nickName).assertEqual('Alice');
      expect(basic.profileUrl).assertEqual('https://example.com/a.png');
      expect(basic.isVip).assertEqual(1);
      expect(basic.realNameAuthFlag).assertEqual(1);
      expect(basic.gender).assertEqual(2);
    });

    it('toBasicUserInfo_shouldReturnBasicUserInfoInstance', 0, () => {
      const userInfo: UserInfo = new UserInfo();
      const basic: BasicUserInfo = UserInfo.toBasicUserInfo(userInfo);
      expect(basic instanceof BasicUserInfo).assertTrue();
    });

    it('toBasicUserInfo_shouldKeepDefaultNullsWhenSourceNotSet', 0, () => {
      const userInfo: UserInfo = new UserInfo();
      const basic: BasicUserInfo = UserInfo.toBasicUserInfo(userInfo);

      expect(basic.uid).assertNull();
      expect(basic.userNo).assertNull();
      expect(basic.nickName).assertNull();
      expect(basic.profileUrl).assertNull();
      expect(basic.isVip).assertNull();
      expect(basic.gender).assertNull();
      expect(basic.realNameAuthFlag).assertEqual(0);
    });

    it('toBasicUserInfo_shouldNotCopyHwUnionId', 0, () => {
      const userInfo: UserInfo = new UserInfo();
      userInfo.hwUnionId = 'union-xyz';
      const basic: BasicUserInfo = UserInfo.toBasicUserInfo(userInfo);
      expect(basic.hwUnionId).assertNull();
    });

    it('toBasicUserInfo_shouldHandleZeroAndEmptyValues', 0, () => {
      const userInfo: UserInfo = new UserInfo();
      userInfo.uid = 0;
      userInfo.userNo = '';
      userInfo.nickName = '';
      userInfo.profilePictureUrl = '';
      userInfo.isVip = 0;
      userInfo.realNameAuthFlag = 0;
      userInfo.gender = 0;

      const basic: BasicUserInfo = UserInfo.toBasicUserInfo(userInfo);

      expect(basic.uid).assertEqual(0);
      expect(basic.userNo).assertEqual('');
      expect(basic.nickName).assertEqual('');
      expect(basic.profileUrl).assertEqual('');
      expect(basic.isVip).assertEqual(0);
      expect(basic.realNameAuthFlag).assertEqual(0);
      expect(basic.gender).assertEqual(0);
    });

    it('toBasicUserInfo_shouldReturnNewInstanceEachCall', 0, () => {
      const userInfo: UserInfo = new UserInfo();
      userInfo.uid = 7;
      const a: BasicUserInfo = UserInfo.toBasicUserInfo(userInfo);
      const b: BasicUserInfo = UserInfo.toBasicUserInfo(userInfo);
      expect(a === b).assertFalse();
      expect(a.uid).assertEqual(b.uid);
    });
  });
}
