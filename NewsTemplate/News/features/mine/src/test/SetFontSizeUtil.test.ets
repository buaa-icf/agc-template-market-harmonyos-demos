import { describe, it, expect } from '@ohos/hypium';
import { SetFontSizeUtil } from '../main/ets/utils/SetFontSizeUtil';

export default function setFontSizeUtilTest() {
  describe('SetFontSizeUtilTest', () => {

    it('getTextByFontSize_12_returnsSmall', 0, () => {
      expect(SetFontSizeUtil.getTextByFontSize(12)).assertEqual('小');
    });

    it('getTextByFontSize_14_returnsStandard', 0, () => {
      expect(SetFontSizeUtil.getTextByFontSize(14)).assertEqual('标准');
    });

    it('getTextByFontSize_16_returnsLarge', 0, () => {
      expect(SetFontSizeUtil.getTextByFontSize(16)).assertEqual('大');
    });

    it('getTextByFontSize_18_returnsExtraLarge', 0, () => {
      expect(SetFontSizeUtil.getTextByFontSize(18)).assertEqual('特大');
    });

    it('getTextByFontSize_20_returnsSuperLarge', 0, () => {
      expect(SetFontSizeUtil.getTextByFontSize(20)).assertEqual('超大');
    });

    it('getTextByFontSize_defaultBranch_returnsStandard', 0, () => {
      expect(SetFontSizeUtil.getTextByFontSize(0)).assertEqual('标准');
      expect(SetFontSizeUtil.getTextByFontSize(10)).assertEqual('标准');
      expect(SetFontSizeUtil.getTextByFontSize(13)).assertEqual('标准');
      expect(SetFontSizeUtil.getTextByFontSize(15)).assertEqual('标准');
      expect(SetFontSizeUtil.getTextByFontSize(100)).assertEqual('标准');
      expect(SetFontSizeUtil.getTextByFontSize(-1)).assertEqual('标准');
    });

    it('getTextByFontSize_floatInputNotMatched_returnsStandard', 0, () => {
      expect(SetFontSizeUtil.getTextByFontSize(12.5)).assertEqual('标准');
      expect(SetFontSizeUtil.getTextByFontSize(14.0)).assertEqual('标准');
    });

    it('getTextByFontSize_allMappedSizesAreDistinctExceptStandard', 0, () => {
      const s12 = SetFontSizeUtil.getTextByFontSize(12);
      const s14 = SetFontSizeUtil.getTextByFontSize(14);
      const s16 = SetFontSizeUtil.getTextByFontSize(16);
      const s18 = SetFontSizeUtil.getTextByFontSize(18);
      const s20 = SetFontSizeUtil.getTextByFontSize(20);
      const sDefault = SetFontSizeUtil.getTextByFontSize(999);
      expect(s12).assertEqual('小');
      expect(s16).assertEqual('大');
      expect(s18).assertEqual('特大');
      expect(s20).assertEqual('超大');
      expect(s14 === sDefault).assertTrue();
      const nonStandardSet = new Set<string>([s12, s16, s18, s20]);
      expect(nonStandardSet.size).assertEqual(4);
    });

    it('getTextByFontSize_sameInputReturnsSameOutput', 0, () => {
      expect(SetFontSizeUtil.getTextByFontSize(12)).assertEqual(SetFontSizeUtil.getTextByFontSize(12));
      expect(SetFontSizeUtil.getTextByFontSize(20)).assertEqual(SetFontSizeUtil.getTextByFontSize(20));
      expect(SetFontSizeUtil.getTextByFontSize(999)).assertEqual(SetFontSizeUtil.getTextByFontSize(999));
    });
  });
}
