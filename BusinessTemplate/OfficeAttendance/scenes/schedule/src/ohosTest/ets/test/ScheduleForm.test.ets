import { afterAll, beforeAll, describe, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const driver: Driver = Driver.create();

const HOST_ANCHOR_ID: string = 'schedule_form_test_host_anchor';
const FORM_ROOT_ID: string = 'schedule_form_root';
const TITLE_INPUT_ID: string = 'titleID';
const ALL_DAY_TOGGLE_ID: string = 'schedule_form_all_day_toggle';
const START_TIME_VALUE_ID: string = 'schedule_form_start_time_value';
const END_TIME_VALUE_ID: string = 'schedule_form_end_time_value';
const REPEAT_TRIGGER_ID: string = 'schedule_form_repeat_trigger';
const REPEAT_VALUE_ID: string = 'schedule_form_repeat_value';
const REMINDER_VALUE_ID: string = 'schedule_form_reminder_value';
const WEEKLY_REPEAT_OPTION_ID: string = 'schedule_form_repeat_option_4';

const INITIAL_START_TIME: string = '2026-03-02 09:30';
const INITIAL_END_TIME: string = '2026-03-02 10:30';
const ALL_DAY_START_TIME: string = '2026-03-02';
const ALL_DAY_END_TIME: string = '2026-03-02';

async function findById(id: string, timeout: number = 3000): Promise<Component> {
  const component: Component = await driver.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find component with id: ${id}`);
  }
  return component;
}

async function readText(id: string): Promise<string> {
  return await (await findById(id)).getText();
}

async function assertTextEquals(id: string, expected: string): Promise<void> {
  const actual: string = await readText(id);
  if (actual !== expected) {
    throw new Error(`Unexpected text for ${id}: expected "${expected}", got "${actual}"`);
  }
}

async function clickById(id: string): Promise<void> {
  await (await findById(id)).click();
  await driver.waitForIdle(500, 5000);
}

async function waitForForm(): Promise<void> {
  await driver.waitForIdle(1000, 10000);
  await findById(HOST_ANCHOR_ID, 10000);
  await findById(FORM_ROOT_ID, 10000);
  await findById(TITLE_INPUT_ID, 10000);
}

export default function ScheduleFormTest(): void {
  describe('ScheduleFormTest', () => {
    beforeAll(async () => {
      await waitForForm();
    });

    afterAll(async () => {
      await driver.waitForIdle(500, 5000);
    });

    it('renders_the_seeded_schedule_form', 0, async () => {
      await findById(TITLE_INPUT_ID);
      await assertTextEquals(START_TIME_VALUE_ID, INITIAL_START_TIME);
      await assertTextEquals(END_TIME_VALUE_ID, INITIAL_END_TIME);
      await findById(REPEAT_VALUE_ID);
      await findById(REMINDER_VALUE_ID);
    });

    it('switches_to_all_day_and_reformats_the_schedule_range', 0, async () => {
      await clickById(ALL_DAY_TOGGLE_ID);
      await assertTextEquals(START_TIME_VALUE_ID, ALL_DAY_START_TIME);
      await assertTextEquals(END_TIME_VALUE_ID, ALL_DAY_END_TIME);
      await findById(REMINDER_VALUE_ID);
    });

    it('selects_a_weekly_repeat_rule_from_the_menu', 0, async () => {
      const previousValue: string = await readText(REPEAT_VALUE_ID);
      await clickById(REPEAT_TRIGGER_ID);
      await clickById(WEEKLY_REPEAT_OPTION_ID);

      const weeklyValue: string = await readText(REPEAT_VALUE_ID);
      if (weeklyValue === previousValue) {
        throw new Error(`Repeat value did not change after selecting weekly: ${weeklyValue}`);
      }
    });
  });
}
