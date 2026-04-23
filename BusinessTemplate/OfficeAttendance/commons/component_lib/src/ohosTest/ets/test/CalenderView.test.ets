import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID = 'calender_view_test_host_anchor';
const SHOW_MONTH_ID = 'calender_view_show_month';
const SELECTED_DAY_ID = 'calender_view_selected_day';
const CHANGE_MONTH_COUNT_ID = 'calender_view_change_month_count';

async function findById(id: string, timeout: number = 8000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function getTextById(id: string, timeout: number = 5000): Promise<string> {
  return await (await findById(id, timeout)).getText();
}

async function waitForText(id: string, expected: string, timeout: number = 5000): Promise<void> {
  const deadline = new Date().getTime() + timeout;
  let last: string = '';
  while (new Date().getTime() <= deadline) {
    last = await getTextById(id, Math.min(timeout, 1000));
    if (last === expected) {
      return;
    }
    await DRIVER.waitForIdle(200, 1000);
  }
  throw new Error(`Unexpected text for ${id}: expected "${expected}", got "${last}"`);
}

export default function calenderViewTest() {
  describe('CalenderViewTest', () => {
    beforeAll(async () => {
      await DRIVER.waitForIdle(1000, 10000);
      await findById(HOST_ANCHOR_ID, 12000);
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('refresh_initializes_month_and_selected_day_on_appear', 0, async () => {
      await waitForText(SHOW_MONTH_ID, 'month:2026-5', 8000);
      const selectedDayText = await getTextById(SELECTED_DAY_ID);
      expect(selectedDayText.indexOf('day:2026-5-') === 0).assertTrue();
      const dayStr = selectedDayText.substring('day:2026-5-'.length);
      const dayNum = Number(dayStr);
      expect(dayNum >= 1 && dayNum <= 31).assertTrue();
    });

    it('refresh_notifies_change_month_callback_at_least_once', 0, async () => {
      const text = await getTextById(CHANGE_MONTH_COUNT_ID);
      expect(text.indexOf('cm:') === 0).assertTrue();
      const count = Number(text.substring('cm:'.length));
      expect(count >= 1).assertTrue();
    });
  });
}
