import { beforeEach, afterEach, describe, expect, it } from '@ohos/hypium';
import { UserInfo } from 'base_common';
import { RechargePage } from '../main/ets/views/RechargePage';

export default function RechargePageTest() {
  describe('RechargePageTest', () => {
    let page: RechargePage;

    beforeEach(() => {
      page = new RechargePage();
      AppStorage.setOrCreate('userInfo', undefined);
      AppStorage.setOrCreate('bookCoins', undefined);
    });

    afterEach(() => {
      AppStorage.setOrCreate('userInfo', undefined);
      AppStorage.setOrCreate('bookCoins', undefined);
    });

    it('updates stored user book coins and syncs bookCoins storage', 0, () => {
      const userInfo: UserInfo = new UserInfo();
      userInfo.bookCoins = 120;
      AppStorage.setOrCreate('userInfo', userInfo);

      page.updateBookCoins(30);

      const savedUserInfo: UserInfo = AppStorage.get('userInfo') as UserInfo;
      expect(savedUserInfo.bookCoins).assertEqual(150);
      expect(AppStorage.get('bookCoins') as number).assertEqual(150);
    });

    it('falls back to the default balance when stored user book coins is empty', 0, () => {
      const userInfo: UserInfo = new UserInfo();
      AppStorage.setOrCreate('userInfo', userInfo);

      page.updateBookCoins(25);

      const savedUserInfo: UserInfo = AppStorage.get('userInfo') as UserInfo;
      expect(savedUserInfo.bookCoins).assertEqual(125);
      expect(AppStorage.get('bookCoins') as number).assertEqual(125);
    });

    it('keeps storage untouched when no user info exists', 0, () => {
      page.updateBookCoins(25);

      expect(AppStorage.get('userInfo') === undefined).assertEqual(true);
      expect(AppStorage.get('bookCoins') === undefined).assertEqual(true);
    });
  });
}
