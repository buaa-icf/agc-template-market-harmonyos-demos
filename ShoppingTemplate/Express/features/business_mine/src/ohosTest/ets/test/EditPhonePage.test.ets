import { describe, beforeAll, it, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry, Driver, ON } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';

const BUNDLE: string = 'EditPhonePageUiTest_';

async function waitForId(driver: Driver, id: string, message: string): Promise<void> {
  const comp = await driver.waitForComponent(ON.id(id), 5000);
  if (!comp) {
    throw new Error(`${message}: unable to find id ${id}`);
  }
}

async function waitForText(driver: Driver, text: string, message: string): Promise<void> {
  const comp = await driver.waitForComponent(ON.text(text), 5000);
  if (!comp) {
    throw new Error(`${message}: unable to find text ${text}`);
  }
}

async function clickById(driver: Driver, id: string): Promise<void> {
  const comp = await driver.waitForComponent(ON.id(id), 5000);
  if (!comp) {
    throw new Error(`Unable to find id: ${id}`);
  }
  await comp.click();
  await driver.delayMs(500);
}

async function clickByText(driver: Driver, text: string): Promise<void> {
  const comp = await driver.waitForComponent(ON.text(text), 5000);
  if (!comp) {
    throw new Error(`Unable to find text: ${text}`);
  }
  await comp.click();
  await driver.delayMs(500);
}

async function typeIntoInput(driver: Driver, value: string): Promise<void> {
  const input = await driver.waitForComponent(ON.type('TextInput'), 5000);
  if (!input) {
    throw new Error('Unable to find TextInput');
  }
  const point = await input.getBoundsCenter();
  await driver.inputText(point, value);
  await driver.delayMs(500);
  try {
    await driver.pressBack();
  } catch (_e) {
  }
  await driver.delayMs(400);
}

async function expectStillOnEditPage(driver: Driver, message: string): Promise<void> {
  await driver.delayMs(500);
  const input = await driver.findComponent(ON.type('TextInput'));
  if (!input) {
    throw new Error(`${message}: expected edit page to remain open (TextInput missing)`);
  }
}

async function expectPoppedToHost(driver: Driver, message: string): Promise<void> {
  await driver.delayMs(800);
  const input = await driver.findComponent(ON.type('TextInput'));
  if (input) {
    throw new Error(`${message}: expected edit page to have popped (TextInput still visible)`);
  }
}

export default function editPhonePageTest() {
  describe('EditPhonePageTest', () => {

    beforeAll(async () => {
      const delegator = abilityDelegatorRegistry.getAbilityDelegator();
      const want: Want = {
        bundleName: abilityDelegatorRegistry.getArguments().bundleName,
        abilityName: 'TestAbility'
      };
      const driver: Driver = Driver.create();
      // Dismiss any soft keyboard the previous suite may have left up, then
      // re-foreground the test ability. Without this the first inputText in
      // this suite inherits stale focus and throws NoCandidates.
      try {
        await driver.pressBack();
      } catch (_e) {
      }
      await driver.delayMs(400);
      await delegator.startAbility(want);
      await driver.delayMs(1500);
      await waitForId(driver, 'scenario_bar', `${BUNDLE}host not launched`);
    });

    it('rejectsEmptyPhone', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_seed_phone_empty');
      await clickById(driver, 'btn_show_phone');
      await waitForText(driver, '手机号', `${BUNDLE}phone label`);
      await clickByText(driver, '保存');
      await expectStillOnEditPage(driver, `${BUNDLE}empty-phone should stay on page`);
      await clickById(driver, 'btn_pop');
    });

    it('rejectsWrongLengthPhone', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_seed_phone_short');
      await clickById(driver, 'btn_show_phone');
      await waitForText(driver, '手机号', `${BUNDLE}phone label`);
      await clickByText(driver, '保存');
      await expectStillOnEditPage(driver, `${BUNDLE}short-phone should stay on page`);
      await clickById(driver, 'btn_pop');
    });

    it('rendersAndSavesPhone', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_seed_phone_empty');
      await clickById(driver, 'btn_show_phone');
      await waitForText(driver, '手机号', `${BUNDLE}phone label`);
      await waitForText(driver, '保存', `${BUNDLE}save button`);
      await typeIntoInput(driver, '13900001111');
      await clickByText(driver, '保存');
      await expectPoppedToHost(driver, `${BUNDLE}valid save should pop`);
      expect(true).assertTrue();
    });
  });
}
