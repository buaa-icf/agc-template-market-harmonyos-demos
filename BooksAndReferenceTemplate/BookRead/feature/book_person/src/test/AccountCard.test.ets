import { beforeEach, afterEach, describe, expect, it } from '@ohos/hypium';
import { UserInfo } from 'base_common';
import { AccountCard } from '../main/ets/comp/AccountCard';

export default function AccountCardTest() {
  describe('AccountCardTest', () => {
    let card: AccountCard;

    beforeEach(() => {
      AppStorage.setOrCreate('userInfo', undefined);
      AppStorage.setOrCreate('bookCoins', undefined);
      card = new AccountCard();
    });

    afterEach(() => {
      AppStorage.setOrCreate('userInfo', undefined);
      AppStorage.setOrCreate('bookCoins', undefined);
    });

    it('increments existing book coins and refreshes local login state', 0, () => {
      const userInfo: UserInfo = new UserInfo();
      userInfo.bookCoins = 120;
      AppStorage.setOrCreate('userInfo', userInfo);

      card.updateBookCoins(30);

      const savedUserInfo: UserInfo = AppStorage.get('userInfo') as UserInfo;
      expect(savedUserInfo.bookCoins).assertEqual(150);
      expect(AppStorage.get('bookCoins') as number).assertEqual(150);
      expect(card.bookCoins).assertEqual(150);
      expect(card.isLogin).assertEqual(true);
    });

    it('uses the default balance when stored user book coins is empty', 0, () => {
      const userInfo: UserInfo = new UserInfo();
      AppStorage.setOrCreate('userInfo', userInfo);

      card.updateBookCoins(25);

      const savedUserInfo: UserInfo = AppStorage.get('userInfo') as UserInfo;
      expect(savedUserInfo.bookCoins).assertEqual(125);
      expect(AppStorage.get('bookCoins') as number).assertEqual(125);
      expect(card.bookCoins).assertEqual(125);
      expect(card.isLogin).assertEqual(true);
    });

    it('keeps storage untouched when no user info exists', 0, () => {
      card.updateBookCoins(25);

      expect(AppStorage.get('userInfo') === undefined).assertEqual(true);
      expect(AppStorage.get('bookCoins') === undefined).assertEqual(true);
      expect(card.bookCoins).assertEqual(0);
      expect(card.isLogin).assertEqual(false);
    });
  });
}
