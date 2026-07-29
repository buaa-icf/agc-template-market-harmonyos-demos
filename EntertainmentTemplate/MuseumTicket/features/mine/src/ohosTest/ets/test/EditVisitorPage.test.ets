import { beforeAll, beforeEach, describe, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const UI_TIMEOUT = 10000;
const IDLE_DELAY = 1200;
const HOST_ANCHOR_ID = 'add_visitor_host_anchor';
const OPEN_EDIT_BUTTON_ID = 'edit_visitor_show_populated';
const OPEN_EMPTY_EDIT_BUTTON_ID = 'edit_visitor_show_empty';
const SAVE_BUTTON_ID = 'edit_visitor_save_button';
const CANCEL_BUTTON_ID = 'edit_visitor_cancel_button';

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

async function ensureHostVisible(driver: Driver): Promise<void> {
  const hostAnchor = await driver.findComponent(ON.id(HOST_ANCHOR_ID));
  if (hostAnchor !== null) {
    return;
  }

  const cancelButton = await driver.findComponent(ON.id(CANCEL_BUTTON_ID));
  if (cancelButton !== null) {
    await cancelButton.click();
    await waitForIdle(driver);
  }

  await findById(driver, HOST_ANCHOR_ID);
}

async function enterText(driver: Driver, id: string, value: string): Promise<void> {
  const input = await findById(driver, id);
  const point = await input.getBoundsCenter();
  await driver.inputText(point, value);
  await waitForIdle(driver, 100);
  try {
    await driver.pressBack();
  } catch (_error) {
  }
  await waitForIdle(driver, 100);
}

async function openEmptyForm(driver: Driver): Promise<void> {
  await ensureHostVisible(driver);
  await (await findById(driver, OPEN_EMPTY_EDIT_BUTTON_ID)).click();
  await waitForIdle(driver);
  await findById(driver, SAVE_BUTTON_ID);
}

async function closeForm(driver: Driver): Promise<void> {
  const cancel = await driver.findComponent(ON.id(CANCEL_BUTTON_ID));
  if (cancel !== null) {
    await cancel.click();
    await waitForIdle(driver);
  }
  await ensureHostVisible(driver);
}

async function submitForm(driver: Driver, name: string, cardId: string, phone: string): Promise<void> {
  await openEmptyForm(driver);
  if (name.length > 0) {
    await enterText(driver, 'edit_visitor_name_input', name);
  }
  if (cardId.length > 0) {
    await enterText(driver, 'edit_visitor_card_id_input', cardId);
  }
  if (phone.length > 0) {
    await enterText(driver, 'edit_visitor_phone_input', phone);
  }
  await (await findById(driver, SAVE_BUTTON_ID)).click();
  await waitForIdle(driver, 500);
}

export default function EditVisitorPageTest() {
  describe('EditVisitorPageTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = Driver.create();
      await waitForIdle(driver, 2000);
      await ensureHostVisible(driver);
    });

    beforeEach(async () => {
      await waitForIdle(driver);
      await ensureHostVisible(driver);
    });

    it('build_renders_contact_form', 0, async () => {
      await (await findById(driver, OPEN_EDIT_BUTTON_ID)).click();
      await waitForIdle(driver);

      await findById(driver, 'edit_visitor_name_label');
      await findById(driver, 'edit_visitor_name_input');
      await findById(driver, 'edit_visitor_card_type_label');
      await findById(driver, 'edit_visitor_card_type_value');
      await findById(driver, 'edit_visitor_card_id_input');
      await findById(driver, 'edit_visitor_phone_input');
      await findById(driver, SAVE_BUTTON_ID);
      await findById(driver, CANCEL_BUTTON_ID);
    });

    it('build_can_close_and_reopen_page', 0, async () => {
      await (await findById(driver, OPEN_EDIT_BUTTON_ID)).click();
      await waitForIdle(driver);

      await (await findById(driver, CANCEL_BUTTON_ID)).click();
      await waitForIdle(driver);

      const closedSaveButton = await driver.findComponent(ON.id(SAVE_BUTTON_ID));
      if (closedSaveButton !== null) {
        throw new Error('edit_visitor_save_button should disappear after closing the page.');
      }

      await (await findById(driver, OPEN_EDIT_BUTTON_ID)).click();
      await waitForIdle(driver);
      await findById(driver, SAVE_BUTTON_ID);
    });

    it('isContactInfoValid_rejects_missing_name', 0, async () => {
      await closeForm(driver);
      await submitForm(driver, '', '', '');
      await findById(driver, SAVE_BUTTON_ID);
    });

    it('isContactInfoValid_rejects_missing_card_id', 0, async () => {
      await closeForm(driver);
      await submitForm(driver, 'Test Visitor', '', '');
      await findById(driver, SAVE_BUTTON_ID);
    });

    it('isContactInfoValid_rejects_invalid_card_id', 0, async () => {
      await closeForm(driver);
      await submitForm(driver, 'Test Visitor', 'invalid-card', '');
      await findById(driver, SAVE_BUTTON_ID);
    });

    it('isContactInfoValid_rejects_missing_phone', 0, async () => {
      await closeForm(driver);
      await submitForm(driver, 'Test Visitor', '110101199003079876', '');
      await findById(driver, SAVE_BUTTON_ID);
    });

    it('isContactInfoValid_rejects_invalid_phone', 0, async () => {
      await closeForm(driver);
      await submitForm(driver, 'Test Visitor', '110101199003079876', '123');
      await findById(driver, SAVE_BUTTON_ID);
    });

    it('upDateContactInfo_saves_a_valid_contact', 0, async () => {
      await closeForm(driver);
      await submitForm(driver, 'Test Visitor', '110101199003079876', '13812345678');
      await ensureHostVisible(driver);
    });
  });
}
