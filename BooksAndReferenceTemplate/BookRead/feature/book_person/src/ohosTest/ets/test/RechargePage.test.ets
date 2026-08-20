import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';
import { emitter } from '@kit.BasicServicesKit';

const RECHARGE_TEST_EVENT_ID = 91247;
const RECHARGE_PAGE_ROOT_ID = 'recharge_page_root';
const RECHARGE_RECORD_LINK_ID = 'recharge_page_record_link';
const RECHARGE_PACKAGE_CARD_1_ID = 'recharge_page_package_card_1';
const RECHARGE_PACKAGE_CARD_3_ID = 'recharge_page_package_card_3';
const RECHARGE_PACKAGE_CARD_6_ID = 'recharge_page_package_card_6';
const RECHARGE_AGREEMENT_CHECKBOX_ID = 'recharge_page_agreement_checkbox';
const RECHARGE_AGREEMENT_LINK_ID = 'recharge_page_agreement_link';
const RECHARGE_SUBMIT_BUTTON_ID = 'recharge_page_submit';
const HOST_CLOSE_BUTTON_ID = 'recharge_page_test_close';
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

async function waitForRechargePageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(RECHARGE_PAGE_ROOT_ID, 10000);
  await findById(RECHARGE_SUBMIT_BUTTON_ID, 10000);
}

async function openRechargePageDirectly(): Promise<void> {
  for (let attempt = 0; attempt < 5; attempt++) {
    emitter.emit({ eventId: RECHARGE_TEST_EVENT_ID });
    await DRIVER.waitForIdle(300, 1500);
    if (await findByIdOrNull(RECHARGE_PAGE_ROOT_ID, 1500) !== null) {
      return;
    }
  }
  throw new Error('Unable to render recharge page through test event');
}

export default function RechargePageTest() {
  describe('RechargePageTest', () => {
    beforeAll(async () => {
      await openRechargePageDirectly();
      await waitForRechargePageLoaded();
    });

    afterAll(async () => {
      // Keep afterAll short. Next class.s beforeAll has its own host-page recovery.
      await DRIVER.waitForIdle(500, 3000);
    });

    it('build_renders_recharge_packages_and_controls', 0, async () => {
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

      await clickById(RECHARGE_PACKAGE_CARD_3_ID);
      await clickById(RECHARGE_PACKAGE_CARD_6_ID);
      await clickById(RECHARGE_PACKAGE_CARD_1_ID);

      await clickById(RECHARGE_AGREEMENT_LINK_ID);
      await clickById(RECHARGE_SUBMIT_BUTTON_ID);
      await clickById(RECHARGE_AGREEMENT_CHECKBOX_ID);
      await clickById(RECHARGE_SUBMIT_BUTTON_ID);
      await DRIVER.pressBack();
      await DRIVER.waitForIdle(500, 5000);

      await clickById(RECHARGE_RECORD_LINK_ID);
      await DRIVER.waitForIdle(500, 5000);
      await waitForRechargePageLoaded();

      await clickById(HOST_CLOSE_BUTTON_ID);
    }, 60000);
  });
}
