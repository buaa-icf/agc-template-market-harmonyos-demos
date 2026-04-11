import { describe, it, expect } from '@ohos/hypium';
import { MockService, BookState } from '../../Index';

export default function MockServiceTest() {
  describe('MockServiceTest', () => {
    it('returns localized text for each booking state', 0, () => {
      expect(MockService.getBookStateString(BookState.ALL)).assertEqual('全部');
      expect(MockService.getBookStateString(BookState.TO_BE_USE)).assertEqual('待使用');
      expect(MockService.getBookStateString(BookState.COMPLETED)).assertEqual('已完成');
      expect(MockService.getBookStateString(BookState.EXPIRED)).assertEqual('已过期');
      expect(MockService.getBookStateString(BookState.CANCELED)).assertEqual('已取消');
    });

    it('returns empty string for unknown booking state', 0, () => {
      expect(MockService.getBookStateString(-1)).assertEqual('');
    });
  });
}
