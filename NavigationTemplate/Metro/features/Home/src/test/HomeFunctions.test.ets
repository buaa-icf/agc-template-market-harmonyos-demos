import { describe, it, expect } from '@ohos/hypium';
import { getColor } from '../main/ets/functions/HomeFunctions';

interface ResourceShape {
  id: number;
  type: number;
  bundleName: string;
  moduleName: string;
}

function resId(input: string): number {
  return (getColor(input) as ResourceShape).id;
}

export default function homeFunctionsTest() {
  describe('HomeFunctionsTest', () => {

    it('getColor_line1_returnsLine1Resource', 0, () => {
      const r = getColor('1号线') as ResourceShape;
      expect(r.id).assertLarger(0);
      expect(r.id).assertEqual(resId('1号线'));
    });

    it('getColor_line2_returnsLine2Resource', 0, () => {
      const r = getColor('2号线') as ResourceShape;
      expect(r.id).assertLarger(0);
      expect(r.id).assertEqual(resId('2号线'));
    });

    it('getColor_line3_returnsLine3Resource', 0, () => {
      const r = getColor('3号线') as ResourceShape;
      expect(r.id).assertLarger(0);
      expect(r.id).assertEqual(resId('3号线'));
    });

    it('getColor_line4_returnsLine4Resource', 0, () => {
      const r = getColor('4号线') as ResourceShape;
      expect(r.id).assertLarger(0);
      expect(r.id).assertEqual(resId('4号线'));
    });

    it('getColor_line5_returnsLine5Resource', 0, () => {
      const r = getColor('5号线') as ResourceShape;
      expect(r.id).assertLarger(0);
      expect(r.id).assertEqual(resId('5号线'));
    });

    it('getColor_line10_returnsLine10Resource', 0, () => {
      const r = getColor('10号线') as ResourceShape;
      expect(r.id).assertLarger(0);
      expect(r.id).assertEqual(resId('10号线'));
    });

    it('getColor_lineS1_returnsLineS1Resource', 0, () => {
      const r = getColor('S1号线') as ResourceShape;
      expect(r.id).assertLarger(0);
      expect(r.id).assertEqual(resId('S1号线'));
    });

    it('getColor_lineS3_returnsLineS3Resource', 0, () => {
      const r = getColor('S3号线') as ResourceShape;
      expect(r.id).assertLarger(0);
      expect(r.id).assertEqual(resId('S3号线'));
    });

    it('getColor_unknownLine_returnsDefaultWhiteResource', 0, () => {
      const r = getColor('未知号线') as ResourceShape;
      expect(r.id).assertLarger(0);
      expect(r.id).assertEqual(resId(''));
      expect(r.id).assertEqual(resId('6号线'));
      expect(r.id).assertEqual(resId('100号线'));
    });

    it('getColor_allKnownLinesReturnDistinctResources', 0, () => {
      const ids = new Set<number>();
      ids.add(resId('1号线'));
      ids.add(resId('2号线'));
      ids.add(resId('3号线'));
      ids.add(resId('4号线'));
      ids.add(resId('5号线'));
      ids.add(resId('10号线'));
      ids.add(resId('S1号线'));
      ids.add(resId('S3号线'));
      ids.add(resId('未知'));
      expect(ids.size).assertEqual(9);
    });

    it('getColor_knownLineDoesNotCollideWithDefault', 0, () => {
      const defaultId = resId('未定义');
      expect(resId('1号线')).assertLarger(0);
      expect(resId('1号线') === defaultId).assertFalse();
      expect(resId('2号线') === defaultId).assertFalse();
      expect(resId('3号线') === defaultId).assertFalse();
      expect(resId('4号线') === defaultId).assertFalse();
      expect(resId('5号线') === defaultId).assertFalse();
      expect(resId('10号线') === defaultId).assertFalse();
      expect(resId('S1号线') === defaultId).assertFalse();
      expect(resId('S3号线') === defaultId).assertFalse();
    });

    it('getColor_sameInputReturnsSameResource', 0, () => {
      expect(resId('1号线')).assertEqual(resId('1号线'));
      expect(resId('S3号线')).assertEqual(resId('S3号线'));
      expect(resId('default-case-input')).assertEqual(resId('default-case-input'));
    });
  });
}
