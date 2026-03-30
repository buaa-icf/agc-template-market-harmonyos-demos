import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const HOST_OPEN_BUTTON_ID = 'recharge_page_test_open';
const RECHARGE_PAGE_ROOT_ID = 'recharge_page_root';
const RECHARGE_RECORD_LINK_ID = 'recharge_page_record_link';
const RECHARGE_PACKAGE_CARD_1_ID = 'recharge_page_package_card_1';
const RECHARGE_PACKAGE_CARD_3_ID = 'recharge_page_package_card_3';
const RECHARGE_PACKAGE_CARD_6_ID = 'recharge_page_package_card_6';
const RECHARGE_AGREEMENT_CHECKBOX_ID = 'recharge_page_agreement_checkbox';
const RECHARGE_AGREEMENT_LINK_ID = 'recharge_page_agreement_link';
const RECHARGE_SUBMIT_BUTTON_ID = 'recharge_page_submit';
const DRIVER = Driver.create();

async function findByText(text: string, timeout: number = 5000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.text(text), timeout);
  if (component === null) {
    throw new Error(`Unable to find text: ${text}`);
  }
  return component;
}

async function findById(id: string, timeout: number = 5000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function findByIdOrNull(id: string, timeout: number = 1000): Promise<Component | null> {
  return await DRIVER.waitForComponent(ON.id(id), timeout);
}

async function clickById(id: string, timeout: number = 5000): Promise<void> {
  await (await findById(id, timeout)).click();
  await DRIVER.waitForIdle(500, 5000);
}

async function assertTextVisible(text: string, timeout: number = 5000): Promise<void> {
  await findByText(text, timeout);
}

async function waitForHostPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(HOST_OPEN_BUTTON_ID, 10000);
}

async function waitForRechargePageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(RECHARGE_PAGE_ROOT_ID, 10000);
  await findById(RECHARGE_SUBMIT_BUTTON_ID, 10000);
}

async function ensureHostPageLoaded(): Promise<void> {
  const deadline = new Date().getTime() + 15000;
  while (new Date().getTime() <= deadline) {
    const hostButton = await findByIdOrNull(HOST_OPEN_BUTTON_ID, 2000);
    if (hostButton !== null) {
      return;
    }

    const rechargePage = await findByIdOrNull(RECHARGE_PAGE_ROOT_ID, 1000);
    if (rechargePage !== null) {
      await DRIVER.pressBack();
      await DRIVER.waitForIdle(1000, 5000);
    } else {
      await DRIVER.waitForIdle(1000, 2000);
    }
  }

  throw new Error('Unable to reach recharge page test host');
}

export default function RechargePageTest() {
  describe('RechargePageTest', () => {
    beforeAll(async () => {
      await ensureHostPageLoaded();
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_renders_recharge_packages_and_controls', 0, async () => {
      await ensureHostPageLoaded();
      await waitForHostPageLoaded();
      await clickById(HOST_OPEN_BUTTON_ID);
      await waitForRechargePageLoaded();

      await assertTextVisible('充值');
      await assertTextVisible('选择充值套餐');
      await assertTextVisible('充值记录');
      await assertTextVisible('充值说明');
      await assertTextVisible('我已阅读并同意');
      await assertTextVisible('充值协议');
      await assertTextVisible('立即充值');
      await assertTextVisible('60');
      await assertTextVisible('300');
      await assertTextVisible('680');
      await assertTextVisible('6480');
      await assertTextVisible('送60');
      await assertTextVisible('送220');
      await assertTextVisible('• 书币可用于购买付费图书和章节');
      await assertTextVisible('• 充值成功后书币将立即到账');

      await findById(RECHARGE_RECORD_LINK_ID);
      await findById(RECHARGE_PACKAGE_CARD_1_ID);
      await findById(RECHARGE_PACKAGE_CARD_3_ID);
      await findById(RECHARGE_PACKAGE_CARD_6_ID);
      await findById(RECHARGE_AGREEMENT_CHECKBOX_ID);
      await findById(RECHARGE_AGREEMENT_LINK_ID);
      await findById(RECHARGE_SUBMIT_BUTTON_ID);

      await DRIVER.pressBack();
      await waitForHostPageLoaded();
    }, 60000);
  });
}
