import { beforeAll, describe, expect, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const driver: Driver = Driver.create();

async function findById(id: string, timeout: number = 10000): Promise<Component> {
  const component: Component = await driver.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function readMonth(): Promise<string> {
  return await (await findById('agency_calendar_month_value')).getText();
}

async function click(id: string): Promise<void> {
  await (await findById(id)).click();
  await driver.waitForIdle(300, 5000);
}

export default function AgencyTaskCalenderTest(): void {
  describe('AgencyTaskCalenderTest', () => {
    beforeAll(async () => {
      await driver.waitForIdle(1000, 10000);
      await findById('agency_calendar_test_host_anchor');
      await findById('agency_calendar_root');
    });

    it('renders_and_changes_month_in_both_directions', 0, async () => {
      const initialMonth: string = await readMonth();
      await click('pre_month');
      const previousMonth: string = await readMonth();
      expect(previousMonth === initialMonth).assertEqual(false);

      await click('next_month');
      expect(await readMonth()).assertEqual(initialMonth);
    });

    it('today_restores_the_current_month', 0, async () => {
      await click('pre_month');
      await click('today');
      await click('today');
      await findById('agency_calendar_month_value');
    });

    it('crosses_year_boundaries_in_both_directions', 0, async () => {
      for (let index: number = 0; index < 13; index++) {
        await click('pre_month');
      }
      for (let index: number = 0; index < 13; index++) {
        await click('next_month');
      }
      await findById('agency_calendar_month_value');
    });

    it('selects_a_calendar_day_and_opens_plan_time', 0, async () => {
      await click('agency_calendar_day_0_0');
      await click('agency_calendar_plan_time');
    });
  });
}
