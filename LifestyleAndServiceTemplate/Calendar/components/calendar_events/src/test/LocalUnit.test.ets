import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { EVENT_TYPE } from '../main/ets/constants/Constants';
import { UserEventItem } from '../main/ets/model/UserEventModel';

export default function localUnitTest() {
  describe('localUnitTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    });
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    });
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    });
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    });
    it('assertContain', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let a = 'abc';
      let b = 'b';
      // Defines a variety of assertion methods, which are used to declare expected boolean conditions.
      expect(a).assertContain(b);
      expect(a).assertEqual(a);
    });

    it('copyFrom should deep copy editable event fields', 0, () => {
      let source = new UserEventItem();
      source.id = 'source-id';
      source.eventId = 12;
      source.eventType = EVENT_TYPE.TODO;
      source.content = 'buy milk';
      source.date[0].time = '08:30';
      source.date[1].time = '18:30';
      source.date[0].isLunar = true;
      source.date[0].lunarDate = '三月初九';
      source.repeatType = '每天';
      source.remindList = ['提前5分钟'];
      source.remarks = 'from source';
      source.isDone = true;

      let target = new UserEventItem();
      target.copyFrom(source);

      source.content = 'mutated';
      source.date[0].time = '09:30';
      source.remindList[0] = '不提醒';
      source.remarks = 'changed';

      expect(target.id).assertEqual('source-id');
      expect(target.eventId).assertEqual(12);
      expect(target.eventType).assertEqual(EVENT_TYPE.TODO);
      expect(target.content).assertEqual('buy milk');
      expect(target.date[0].time).assertEqual('08:30');
      expect(target.date[1].time).assertEqual('18:30');
      expect(target.date[0].isLunar).assertEqual(true);
      expect(target.date[0].lunarDate).assertEqual('三月初九');
      expect(target.repeatType).assertEqual('每天');
      expect(target.remindList[0]).assertEqual('提前5分钟');
      expect(target.remarks).assertEqual('from source');
      expect(target.isDone).assertEqual(true);
    });

    it('copyFrom can preserve identity fields', 0, () => {
      let source = new UserEventItem();
      source.id = 'source-id';
      source.eventId = 88;
      source.content = 'draft content';
      source.eventType = EVENT_TYPE.BIRTHDAY;

      let target = new UserEventItem();
      target.id = 'target-id';
      target.eventId = 99;

      target.copyFrom(source, false);

      expect(target.id).assertEqual('target-id');
      expect(target.eventId).assertEqual(99);
      expect(target.content).assertEqual('draft content');
      expect(target.eventType).assertEqual(EVENT_TYPE.BIRTHDAY);
    });
  });
}
