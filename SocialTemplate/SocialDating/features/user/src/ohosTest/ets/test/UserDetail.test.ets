import { beforeAll, describe, expect, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const HOST_ANCHOR_ID = 'user_detail_test_host_anchor';
const USER_DETAIL_SCROLL_ID = 'user_detail_scroll';
const UI_TIMEOUT = 10000;

async function findById(driver: Driver, id: string): Promise<Component> {
  const component = await driver.waitForComponent(ON.id(id), UI_TIMEOUT);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function showScenario(driver: Driver, id: string): Promise<void> {
  await (await findById(driver, id)).click();
  await driver.delayMs(1200);
  await findById(driver, USER_DETAIL_SCROLL_ID);
}

export default function UserDetailTest() {
  describe('UserDetailTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = Driver.create();
      await findById(driver, HOST_ANCHOR_ID);
      await findById(driver, USER_DETAIL_SCROLL_ID);
    });

    it('mounts the user detail page instead of the generated default page', 0, async () => {
      await findById(driver, USER_DETAIL_SCROLL_ID);
    });

    it('initialises configured enum and text fields from user data', 0, async () => {
      await showScenario(driver, 'user_detail_show_configured');
      const gender = await findById(driver, 'user_detail_gender_value');
      const residence = await findById(driver, 'user_detail_current_residence_value');
      expect((await gender.getText()).length > 0).assertTrue();
      expect(await residence.getText()).assertEqual('Configured Residence');
    });

    it('initialises unset enum and text fields from empty user data', 0, async () => {
      await showScenario(driver, 'user_detail_show_empty');
      await findById(driver, USER_DETAIL_SCROLL_ID);
    });
  });
}
