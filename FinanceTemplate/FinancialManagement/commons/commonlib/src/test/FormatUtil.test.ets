import { describe, it, expect } from '@ohos/hypium';
import { FormatUtil } from '../main/ets/utils/FormatUtil';

export default function FormatUtilTest() {
  describe('FormatUtilTest', () => {
    it('returns purchase transaction titles for purchase state codes', 0, () => {
      expect(FormatUtil.getTransactionStateTitle(2, 1)).assertEqual('购买受理中');
      expect(FormatUtil.getTransactionStateTitle(2, 2)).assertEqual('购买成功');
      expect(FormatUtil.getTransactionStateTitle(2, 3)).assertEqual('购买失败');
      expect(FormatUtil.getTransactionStateTitle(2, 4)).assertEqual('已终止');
      expect(FormatUtil.getTransactionStateTitle(2, 0)).assertEqual('购买失败');
    });

    it('returns redeem transaction titles for redeem state codes', 0, () => {
      expect(FormatUtil.getTransactionStateTitle(3, 1)).assertEqual('赎回受理中');
      expect(FormatUtil.getTransactionStateTitle(3, 2)).assertEqual('赎回成功');
      expect(FormatUtil.getTransactionStateTitle(3, 3)).assertEqual('赎回失败');
      expect(FormatUtil.getTransactionStateTitle(3, 4)).assertEqual('已终止');
      expect(FormatUtil.getTransactionStateTitle(3, 99)).assertEqual('赎回失败');
    });

    it('returns matured title for non purchase and redeem transaction types', 0, () => {
      expect(FormatUtil.getTransactionStateTitle(1, 1)).assertEqual('已到期');
      expect(FormatUtil.getTransactionStateTitle(0, 4)).assertEqual('已到期');
    });
  });
}
