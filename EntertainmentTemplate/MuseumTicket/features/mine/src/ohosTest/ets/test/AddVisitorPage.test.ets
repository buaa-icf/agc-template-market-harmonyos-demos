import { beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { abilityDelegatorRegistry, Component, Driver, ON } from '@kit.TestKit';
import { window } from '@kit.ArkUI';

const UI_TIMEOUT = 10000;
const HOST_ANCHOR_ID = 'add_visitor_host_anchor';
const POPULATED_BUTTON_ID = 'add_visitor_show_populated';
const EMPTY_BUTTON_ID = 'add_visitor_show_empty';
const SAVE_BUTTON_ID = 'add_visitor_save_button';
const CANCEL_BUTTON_ID = 'add_visitor_cancel_button';

async function waitForIdle(driver: Driver): Promise<void> {
  await driver.waitForIdle(250, 1500);
}

async function findById(driver: Driver, id: string, timeout: number = UI_TIMEOUT): Promise<Component> {
  const component = await driver.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function waitForFormToClose(driver: Driver): Promise<void> {
  const deadline = Date.now() + UI_TIMEOUT;
  while (await driver.findComponent(ON.id(SAVE_BUTTON_ID)) !== null) {
    if (Date.now() >= deadline) {
      throw new Error('The add visitor form is still open.');
    }
    await driver.delayMs(100);
  }
  await findById(driver, HOST_ANCHOR_ID);
}

async function dismissKeyboardIfShown(driver: Driver): Promise<void> {
  const ability = await abilityDelegatorRegistry.getAbilityDelegator().getCurrentTopAbility();
  const formWindow = await window.getLastWindow(ability.context);
  if (formWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_KEYBOARD).bottomRect.height > 0) {
    await driver.pressBack();
    await waitForIdle(driver);
  }
}

async function enterText(driver: Driver, id: string, value: string): Promise<void> {
  const input = await findById(driver, id);
  await input.inputText(value);
  const filled = await driver.waitForComponent(ON.id(id).text(value), 3000);
  await dismissKeyboardIfShown(driver);
  if (filled === null) {
    throw new Error(`Input ${id} did not update to the expected value.`);
  }
}

async function submitForm(driver: Driver, name: string, cardId: string, phone: string): Promise<void> {
  await (await findById(driver, EMPTY_BUTTON_ID)).click();
  await waitForIdle(driver);
  if (name.length > 0) {
    await enterText(driver, 'add_visitor_name_input', name);
  }
  if (cardId.length > 0) {
    await enterText(driver, 'add_visitor_card_id_input', cardId);
  }
  if (phone.length > 0) {
    await enterText(driver, 'add_visitor_phone_input', phone);
  }
  await (await findById(driver, SAVE_BUTTON_ID)).click();
}

export default function AddVisitorPageTest() {
  describe('AddVisitorPageTest', () => {
    let driver: Driver;

    beforeAll(() => {
      driver = Driver.create();
    });

    beforeEach(async () => {
      const cancel = await driver.findComponent(ON.id(CANCEL_BUTTON_ID));
      if (cancel !== null) {
        await dismissKeyboardIfShown(driver);
        await cancel.click();
      }
      await waitForFormToClose(driver);
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
      expect(await (await findById(driver, 'add_visitor_name_input')).getText()).assertEqual('Test Visitor');
      expect(await (await findById(driver, 'add_visitor_card_id_input')).getText()).assertEqual('110101199003079876');
      expect(await (await findById(driver, 'add_visitor_phone_input')).getText()).assertEqual('13812345678');
    });

    it('build_can_close_and_reopen_page', 0, async () => {
      await (await findById(driver, EMPTY_BUTTON_ID)).click();
      await waitForIdle(driver);

      await (await findById(driver, CANCEL_BUTTON_ID)).click();
      await waitForFormToClose(driver);

      await (await findById(driver, EMPTY_BUTTON_ID)).click();
      await waitForIdle(driver);
      await findById(driver, SAVE_BUTTON_ID);
      expect(await (await findById(driver, 'add_visitor_name_input')).getText()).assertEqual('');
      expect(await (await findById(driver, 'add_visitor_card_id_input')).getText()).assertEqual('');
      expect(await (await findById(driver, 'add_visitor_phone_input')).getText()).assertEqual('');
    });

    it('isContactInfoValid_rejects_missing_name', 0, async () => {
      await submitForm(driver, '', '', '');
      await findById(driver, SAVE_BUTTON_ID);
    });

    it('isContactInfoValid_rejects_missing_card_id', 0, async () => {
      await submitForm(driver, 'A', '', '');
      await findById(driver, SAVE_BUTTON_ID);
    });

    it('isContactInfoValid_rejects_invalid_card_id', 0, async () => {
      await submitForm(driver, 'A', '1', '');
      await findById(driver, SAVE_BUTTON_ID);
    });

    it('isContactInfoValid_rejects_missing_phone', 0, async () => {
      await submitForm(driver, 'A', '110101199003079876', '');
      await findById(driver, SAVE_BUTTON_ID);
    });

    it('isContactInfoValid_rejects_invalid_phone', 0, async () => {
      await submitForm(driver, 'A', '110101199003079876', '123');
      await findById(driver, SAVE_BUTTON_ID);
    });

    it('upDateContactInfo_saves_a_valid_contact', 0, async () => {
      await submitForm(driver, 'A', '110101199003079876', '13812345678');
      await waitForFormToClose(driver);
    });
  });
}
