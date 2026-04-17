import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID = 'schedule_form_test_host_anchor';
const FORM_ROOT_ID = 'schedule_form_root';
const TITLE_INPUT_ID = 'titleID';
const DESCRIPTION_INPUT_ID = 'description';
const START_TIME_VALUE_ID = 'schedule_form_start_time_value';
const END_TIME_VALUE_ID = 'schedule_form_end_time_value';
const REPEAT_TRIGGER_ID = 'schedule_form_repeat_trigger';
const REPEAT_VALUE_ID = 'schedule_form_repeat_value';
const REMINDER_VALUE_ID = 'schedule_form_reminder_value';
const REPEAT_WEEKLY_OPTION_ID = 'schedule_form_repeat_option_4';

async function findByText(text: string, timeout: number = 5000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.text(text), timeout);
  if (component === null) {
    throw new Error(`Unable to find text: ${text}`);
  }
  return component;
}

async function findById(id: string, timeout: number = 5000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function clickById(id: string, timeout: number = 5000): Promise<void> {
  await (await findById(id, timeout)).click();
  await DRIVER.waitForIdle(500, 5000);
}

async function inputTextById(id: string, text: string, timeout: number = 5000): Promise<void> {
  const component = await findById(id, timeout);
  await component.click();
  await component.inputText(text);
  await DRIVER.waitForIdle(500, 5000);
}

async function getTextById(id: string, timeout: number = 5000): Promise<string> {
  return await (await findById(id, timeout)).getText();
}

async function assertTextVisible(text: string, timeout: number = 5000): Promise<void> {
  await findByText(text, timeout);
}

async function waitForTextValueById(id: string, expected: string, timeout: number = 5000): Promise<void> {
  const deadline = new Date().getTime() + timeout;
  while (new Date().getTime() <= deadline) {
    const actual = await getTextById(id, Math.min(timeout, 1000));
    if (actual === expected) {
      return;
    }
    await DRIVER.waitForIdle(200, 1000);
  }

  const actual = await getTextById(id, Math.min(timeout, 1000));
  throw new Error(`Unexpected text for ${id}: expected ${expected}, got ${actual}`);
}

async function waitForFormLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(HOST_ANCHOR_ID, 10000);
  await findById(FORM_ROOT_ID, 10000);
  await findById(TITLE_INPUT_ID, 10000);
}

export default function ScheduleFormTest() {
  describe('ScheduleFormTest', () => {
    beforeAll(async () => {
      await waitForFormLoaded();
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_renders_and_updates_schedule_form_state', 0, async () => {
      await assertTextVisible('地点');
      await assertTextVisible('全天');
      await assertTextVisible('开始');
      await assertTextVisible('结束');
      await assertTextVisible('重复');
      await assertTextVisible('提醒');

      await waitForTextValueById(START_TIME_VALUE_ID, '2026-03-02 09:30');
      await waitForTextValueById(END_TIME_VALUE_ID, '2026-03-02 10:30');
      await waitForTextValueById(REPEAT_VALUE_ID, '不重复');
      await waitForTextValueById(REMINDER_VALUE_ID, '30分钟前');

      await inputTextById(TITLE_INPUT_ID, '双周例会');
      await waitForTextValueById(TITLE_INPUT_ID, '双周例会');

      await inputTextById(DESCRIPTION_INPUT_ID, '带周报');
      await waitForTextValueById(DESCRIPTION_INPUT_ID, '带周报');

      await clickById(REPEAT_TRIGGER_ID);
      await clickById(REPEAT_WEEKLY_OPTION_ID, 10000);
      await waitForTextValueById(REPEAT_VALUE_ID, '每周');

    });
  });
}
