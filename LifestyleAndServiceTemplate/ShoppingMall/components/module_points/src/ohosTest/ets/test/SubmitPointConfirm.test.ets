import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const DRIVER: Driver = Driver.create();

const TEST_HOST_ROOT_ID: string = 'submit_point_confirm_test_host_root';
const SCAN_SECTION_ID: string = 'submit_point_confirm_scan_section';
const PHOTO_SECTION_ID: string = 'submit_point_confirm_photo_section';
const SCAN_CLOSE_STATUS_ID: string = 'submit_point_confirm_scan_close_status';
const SCAN_CONFIRM_STATUS_ID: string = 'submit_point_confirm_scan_confirm_status';
const PHOTO_CLOSE_STATUS_ID: string = 'submit_point_confirm_photo_close_status';
const PHOTO_CONFIRM_STATUS_ID: string = 'submit_point_confirm_photo_confirm_status';

const SCAN_TITLE_ID: string = 'scan_point_confirm_title';
const SCAN_CONTENT_ID: string = 'scan_point_confirm_content';
const SCAN_ACTION_ROW_ID: string = 'scan_point_confirm_action_row';
const SCAN_CANCEL_BUTTON_ID: string = 'scan_point_confirm_cancel_button';
const SCAN_SUBMIT_BUTTON_ID: string = 'scan_point_confirm_submit_button';

const PHOTO_TITLE_ID: string = 'photo_point_confirm_title';
const PHOTO_ACTION_ROW_ID: string = 'photo_point_confirm_action_row';
const PHOTO_CANCEL_BUTTON_ID: string = 'photo_point_confirm_cancel_button';
const PHOTO_SUBMIT_BUTTON_ID: string = 'photo_point_confirm_submit_button';

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

async function assertTextById(id: string, expected: string): Promise<void> {
  const text = await (await findById(id)).getText();
  expect(text).assertEqual(expected);
}

async function waitForHostLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(TEST_HOST_ROOT_ID, 10000);
}

export default function submitPointConfirmTest() {
  describe('SubmitPointConfirmTest', () => {
    beforeAll(async () => {
      await waitForHostLoaded();
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('scan_and_photo_duplicate_fragments_are_rendered', 0, async () => {
      await findById(SCAN_SECTION_ID);
      await findById(SCAN_TITLE_ID);
      await findById(SCAN_CONTENT_ID);
      await findById(SCAN_ACTION_ROW_ID);
      await findById(SCAN_CANCEL_BUTTON_ID);
      await findById(SCAN_SUBMIT_BUTTON_ID);

      await findById(PHOTO_SECTION_ID);
      await findById(PHOTO_TITLE_ID);
      await findById(PHOTO_ACTION_ROW_ID);
      await findById(PHOTO_CANCEL_BUTTON_ID);
      await findById(PHOTO_SUBMIT_BUTTON_ID);
    });

    it('scan_buttons_trigger_close_and_confirm_callbacks', 0, async () => {
      await assertTextById(SCAN_CLOSE_STATUS_ID, 'false');
      await assertTextById(SCAN_CONFIRM_STATUS_ID, 'false');

      await clickById(SCAN_CANCEL_BUTTON_ID);
      await assertTextById(SCAN_CLOSE_STATUS_ID, 'true');
      await assertTextById(SCAN_CONFIRM_STATUS_ID, 'false');

      await clickById(SCAN_SUBMIT_BUTTON_ID);
      await assertTextById(SCAN_CONFIRM_STATUS_ID, 'true');
    });

    it('photo_buttons_trigger_close_and_confirm_callbacks', 0, async () => {
      await assertTextById(PHOTO_CLOSE_STATUS_ID, 'false');
      await assertTextById(PHOTO_CONFIRM_STATUS_ID, 'false');

      await clickById(PHOTO_CANCEL_BUTTON_ID);
      await assertTextById(PHOTO_CLOSE_STATUS_ID, 'true');
      await assertTextById(PHOTO_CONFIRM_STATUS_ID, 'false');

      await clickById(PHOTO_SUBMIT_BUTTON_ID);
      await assertTextById(PHOTO_CONFIRM_STATUS_ID, 'true');
    });
  });
}
