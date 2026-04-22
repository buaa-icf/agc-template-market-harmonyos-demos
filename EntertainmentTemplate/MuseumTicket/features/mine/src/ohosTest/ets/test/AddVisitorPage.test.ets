import { beforeAll, describe, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const UI_TIMEOUT = 10000;
const IDLE_DELAY = 1200;
const HOST_ANCHOR_ID = 'add_visitor_host_anchor';
const POPULATED_BUTTON_ID = 'add_visitor_show_populated';
const EMPTY_BUTTON_ID = 'add_visitor_show_empty';
const SAVE_BUTTON_ID = 'add_visitor_save_button';
const CANCEL_BUTTON_ID = 'add_visitor_cancel_button';

async function waitForIdle(driver: Driver, delayMs: number = IDLE_DELAY): Promise<void> {
  await driver.delayMs(delayMs);
}

async function findById(driver: Driver, id: string, timeout: number = UI_TIMEOUT): Promise<Component> {
  const component = await driver.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

export default function AddVisitorPageTest() {
  describe('AddVisitorPageTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = Driver.create();
      await waitForIdle(driver, 2000);
      await findById(driver, HOST_ANCHOR_ID);
    });

    it('build_renders_contact_form', 0, async () => {
      await (await findById(driver, POPULATED_BUTTON_ID)).click();
      await waitForIdle(driver);

      await findById(driver, 'add_visitor_name_label');
      await findById(driver, 'add_visitor_name_input');
      await findById(driver, 'add_visitor_card_type_label');
      await findById(driver, 'add_visitor_card_type_value');
      await findById(driver, 'add_visitor_card_id_input');
      await findById(driver, 'add_visitor_phone_input');
      await findById(driver, SAVE_BUTTON_ID);
      await findById(driver, CANCEL_BUTTON_ID);
    });

    it('build_can_close_and_reopen_page', 0, async () => {
      await (await findById(driver, EMPTY_BUTTON_ID)).click();
      await waitForIdle(driver);

      await (await findById(driver, CANCEL_BUTTON_ID)).click();
      await waitForIdle(driver);

      const closedSaveButton = await driver.findComponent(ON.id(SAVE_BUTTON_ID));
      if (closedSaveButton !== null) {
        throw new Error('add_visitor_save_button should disappear after closing the page.');
      }

      await (await findById(driver, EMPTY_BUTTON_ID)).click();
      await waitForIdle(driver);
      await findById(driver, SAVE_BUTTON_ID);
    });
  });
}
