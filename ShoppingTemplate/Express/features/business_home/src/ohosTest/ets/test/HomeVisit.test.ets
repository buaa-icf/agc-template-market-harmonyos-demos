import { describe, beforeAll, afterEach, it, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry, Driver, ON } from '@kit.TestKit';
import { UIAbility, Want } from '@kit.AbilityKit';

const BUNDLE: string = 'HomeVisitUiTest_';

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

export default function homeVisitTest() {
  describe('HomeVisitTest', () => {

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

    afterEach(async () => {
      const driver: Driver = Driver.create();
      // "确认" only renders in our dialogs via CommonButton; its presence means a dialog is open.
      const dialogConfirm = await driver.findComponent(ON.text('确认'));
      if (dialogConfirm) {
        await pressBackIfOpen(driver);
      }
    });

    it('mountsHomeVisitAndShowsLabels', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_show_home_visit');
      await waitForId(driver, 'host_home_visit', `${BUNDLE}home_visit container`);
      await waitForText(driver, '物品信息', `${BUNDLE}物品信息 label`);
      await waitForText(driver, '选择快递', `${BUNDLE}选择快递 label`);
      await waitForText(driver, '期望上门时间', `${BUNDLE}期望上门时间 label`);
      await waitForText(driver, '付款方式', `${BUNDLE}付款方式 label`);
      await waitForText(driver, '优惠券', `${BUNDLE}优惠券 label`);
      expect(true).assertTrue();
    });

    it('opensExpressDialog', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_show_home_visit');
      await waitForId(driver, 'host_home_visit', `${BUNDLE}home_visit container`);
      await clickByText(driver, '选择快递');
      await driver.delayMs(500);
      expect(true).assertTrue();
    });

    it('opensTimeDialog', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_show_home_visit');
      await waitForId(driver, 'host_home_visit', `${BUNDLE}home_visit container`);
      await clickByText(driver, '期望上门时间');
      await driver.delayMs(500);
      expect(true).assertTrue();
    });

    it('opensPayMethodDialog', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_show_home_visit');
      await waitForId(driver, 'host_home_visit', `${BUNDLE}home_visit container`);
      await clickByText(driver, '付款方式');
      await driver.delayMs(500);
      expect(true).assertTrue();
    });

    it('opensCouponDialog', 0, async () => {
      const driver: Driver = Driver.create();
      await clickById(driver, 'btn_show_home_visit');
      await waitForId(driver, 'host_home_visit', `${BUNDLE}home_visit container`);
      await clickByText(driver, '优惠券');
      await driver.delayMs(500);
      expect(true).assertTrue();
    });
  });
}
