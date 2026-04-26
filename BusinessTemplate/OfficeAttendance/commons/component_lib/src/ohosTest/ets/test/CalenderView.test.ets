import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

interface Bounds {
  left: number;
  top: number;
  right: number;
  bottom: number;
}

const DRIVER = Driver.create();
const HOST_ANCHOR_ID = 'calender_view_test_host_anchor';
const SHOW_MONTH_ID = 'calender_view_show_month';
const SELECTED_DAY_ID = 'calender_view_selected_day';
const CHANGE_MONTH_COUNT_ID = 'calender_view_change_month_count';
const GESTURE_AREA_ID = 'calender_view_gesture_area';

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

async function getBounds(id: string): Promise<Bounds> {
  const c = await findById(id);
  const rect = await c.getBounds();
  const r: Bounds = { left: rect.left, top: rect.top, right: rect.right, bottom: rect.bottom };
  return r;
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

    it('changeMonthByGesture_swipe_right_goes_to_previous_month', 0, async () => {
      const before = await getTextById(SHOW_MONTH_ID);
      const beforeMonth = Number(before.substring('month:2026-'.length));
      const bounds = await getBounds(GESTURE_AREA_ID);
      const midY = Math.floor((bounds.top + bounds.bottom) / 2);
      const startX = bounds.left + 40;
      const endX = bounds.right - 40;
      await DRIVER.swipe(startX, midY, endX, midY, 600);
      await DRIVER.waitForIdle(500, 5000);

      const expectedMonth = beforeMonth - 1 < 0 ? 11 : beforeMonth - 1;
      const expectedYear = beforeMonth - 1 < 0 ? 2025 : 2026;
      await waitForText(SHOW_MONTH_ID, `month:${expectedYear}-${expectedMonth}`, 8000);
    });

    it('changeMonthByGesture_swipe_left_goes_to_next_month', 0, async () => {
      const before = await getTextById(SHOW_MONTH_ID);
      const beforeYear = Number(before.substring('month:'.length, before.indexOf('-')));
      const beforeMonth = Number(before.substring(before.indexOf('-') + 1));
      const bounds = await getBounds(GESTURE_AREA_ID);
      const midY = Math.floor((bounds.top + bounds.bottom) / 2);
      const startX = bounds.right - 40;
      const endX = bounds.left + 40;
      await DRIVER.swipe(startX, midY, endX, midY, 600);
      await DRIVER.waitForIdle(500, 5000);

      const expectedMonth = beforeMonth + 1 < 12 ? beforeMonth + 1 : 0;
      const expectedYear = beforeMonth + 1 < 12 ? beforeYear : beforeYear + 1;
      await waitForText(SHOW_MONTH_ID, `month:${expectedYear}-${expectedMonth}`, 8000);
    });

    it('changeMonthByGesture_small_offset_does_not_change_month', 0, async () => {
      const before = await getTextById(SHOW_MONTH_ID);
      const bounds = await getBounds(GESTURE_AREA_ID);
      const midY = Math.floor((bounds.top + bounds.bottom) / 2);
      const startX = Math.floor((bounds.left + bounds.right) / 2);
      const endX = startX + 5;
      await DRIVER.swipe(startX, midY, endX, midY, 400);
      await DRIVER.waitForIdle(500, 3000);

      const after = await getTextById(SHOW_MONTH_ID);
      expect(after).assertEqual(before);
    });

    it('refresh_notifies_change_month_callback_at_least_once', 0, async () => {
      const text = await getTextById(CHANGE_MONTH_COUNT_ID);
      expect(text.indexOf('cm:') === 0).assertTrue();
      const count = Number(text.substring('cm:'.length));
      expect(count >= 1).assertTrue();
    });
  });
}
