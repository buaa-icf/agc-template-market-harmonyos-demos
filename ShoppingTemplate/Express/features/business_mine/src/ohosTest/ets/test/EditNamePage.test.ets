import { describe, beforeAll, it, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry, Driver, ON } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';

const BUNDLE: string = 'EditNamePageUiTest_';

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
  // Dismiss the soft keyboard before the next tap; otherwise its overlay may
  // intercept the click on 保存 at the bottom of the page.
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

export default function editNamePageTest() {
  describe('EditNamePageTest', () => {

    beforeAll(async () => {
      const delegator = abilityDelegatorRegistry.getAbilityDelegator();
      const want: Want = {
        bundleName: abilityDelegatorRegistry.getArguments().bundleName,
        abilityName: 'TestAbility'
      };
      await delegator.startAbility(want);
      const driver: Driver = Driver.create();
      await driver.delayMs(1500);
      await waitForId(driver, 'scenario_bar', `${BUNDLE}host not launched`);
    });

    // Invalid: empty nickname -> vm.modify hits the !this.nickname toast branch.
    it('rejectsEmptyNickname', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_seed_name_empty');
      await clickById(driver, 'btn_show_name');
      await waitForText(driver, '昵称', `${BUNDLE}nickname label`);
      await clickByText(driver, '保存');
      await expectStillOnEditPage(driver, `${BUNDLE}empty-name should stay on page`);
      await clickById(driver, 'btn_pop');
    });

    // Invalid: 10-char nickname -> vm.modify hits the length > 8 toast branch.
    it('rejectsTooLongNickname', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_seed_name_long');
      await clickById(driver, 'btn_show_name');
      await waitForText(driver, '昵称', `${BUNDLE}nickname label`);
      await clickByText(driver, '保存');
      await expectStillOnEditPage(driver, `${BUNDLE}long-name should stay on page`);
      await clickById(driver, 'btn_pop');
    });

    // Happy path: type a valid nickname, save, page pops. Also covers the
    // TextInput.onChange arrow (vm.nickname assignment) and onShown/onHidden
    // -> vm.init / vm.clear.
    it('rendersAndSavesNickname', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_seed_name_empty');
      await clickById(driver, 'btn_show_name');
      await waitForText(driver, '昵称', `${BUNDLE}nickname label`);
      await waitForText(driver, '保存', `${BUNDLE}save button`);
      await typeIntoInput(driver, 'alice');
      await clickByText(driver, '保存');
      await expectPoppedToHost(driver, `${BUNDLE}valid save should pop`);
      expect(true).assertTrue();
    });
  });
}
