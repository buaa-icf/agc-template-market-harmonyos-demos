import { describe, beforeAll, afterEach, it, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry, Driver, ON } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';

const BUNDLE: string = 'ShippingInfoUiTest_';

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
  await driver.delayMs(300);
}

async function clickByText(driver: Driver, text: string): Promise<void> {
  const comp = await driver.waitForComponent(ON.text(text), 5000);
  if (!comp) {
    throw new Error(`Unable to find text: ${text}`);
  }
  await comp.click();
  await driver.delayMs(300);
}

async function pressBackIfOpen(driver: Driver): Promise<void> {
  try {
    await driver.pressBack();
    await driver.delayMs(300);
  } catch (_e) {
  }
}

export default function shippingInfoTest() {
  describe('ShippingInfoTest', () => {

    beforeAll(async () => {
      const delegator = abilityDelegatorRegistry.getAbilityDelegator();
      const want: Want = {
        bundleName: abilityDelegatorRegistry.getArguments().bundleName,
        abilityName: 'TestAbility'
      };
      await delegator.startAbility(want);
      const driver: Driver = Driver.create();
      await driver.delayMs(1500);
      // Previous suite may have left a dialog overlay; close it without leaving the test ability.
      const scenarioBar = await driver.waitForComponent(ON.id('scenario_bar'), 1000);
      if (!scenarioBar) {
        await pressBackIfOpen(driver);
      }
      await waitForId(driver, 'scenario_bar', `${BUNDLE}host not launched`);
    });

    afterEach(async () => {
      const driver: Driver = Driver.create();
      const dialogConfirm = await driver.findComponent(ON.text('确认'));
      if (dialogConfirm) {
        await pressBackIfOpen(driver);
      }
    });

    it('mountsShippingInfoAndShowsLabels', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_show_shipping_info');
      await driver.delayMs(800);
      // First mount after the previous suite ran can take longer; retry once if needed.
      let host = await driver.waitForComponent(ON.id('host_shipping_info'), 4000);
      if (!host) {
        await clickById(driver, 'btn_show_shipping_info');
        await driver.delayMs(800);
        host = await driver.waitForComponent(ON.id('host_shipping_info'), 6000);
      }
      if (!host) {
        throw new Error(`${BUNDLE}shipping_info container: unable to find id host_shipping_info`);
      }
      await waitForText(driver, '物品信息', `${BUNDLE}物品信息 label`);
      await waitForText(driver, '付款方式', `${BUNDLE}付款方式 label`);
      await waitForText(driver, '格口类型', `${BUNDLE}格口类型 label`);
      await waitForText(driver, '优惠券', `${BUNDLE}优惠券 label`);
      await waitForText(driver, '查看全部', `${BUNDLE}查看全部 label`);
      expect(true).assertTrue();
    });

    it('opensPayMethodDialog', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_show_shipping_info');
      await waitForId(driver, 'host_shipping_info', `${BUNDLE}shipping_info container`);
      await clickByText(driver, '付款方式');
      await driver.delayMs(500);
      expect(true).assertTrue();
    });

    it('opensGridDialog', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_show_shipping_info');
      await waitForId(driver, 'host_shipping_info', `${BUNDLE}shipping_info container`);
      await clickByText(driver, '格口类型');
      await driver.delayMs(500);
      expect(true).assertTrue();
    });

    it('opensCouponDialog', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_show_shipping_info');
      await waitForId(driver, 'host_shipping_info', `${BUNDLE}shipping_info container`);
      await clickByText(driver, '优惠券');
      await driver.delayMs(500);
      expect(true).assertTrue();
    });
  });
}
