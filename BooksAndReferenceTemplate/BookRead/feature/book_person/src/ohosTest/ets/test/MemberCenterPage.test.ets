import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const HOST_OPEN_BUTTON_ID = 'member_center_page_test_open';
const MEMBER_CENTER_PAGE_ROOT_ID = 'member_center_page_root';
const MEMBER_CENTER_PACKAGE_CARD_1_ID = 'member_center_package_card_1';
const MEMBER_CENTER_PACKAGE_CARD_2_ID = 'member_center_package_card_2';
const MEMBER_CENTER_AGREEMENT_CHECKBOX_ID = 'member_center_agreement_checkbox';
const MEMBER_CENTER_AGREEMENT_LINK_ID = 'member_center_agreement_link';
const MEMBER_CENTER_OPEN_NOW_BUTTON_ID = 'member_center_open_now';
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

async function waitForMemberCenterPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(MEMBER_CENTER_PAGE_ROOT_ID, 10000);
  await findById(MEMBER_CENTER_OPEN_NOW_BUTTON_ID, 10000);
}

async function ensureHostPageLoaded(): Promise<void> {
  const deadline = new Date().getTime() + 15000;
  while (new Date().getTime() <= deadline) {
    const hostButton = await findByIdOrNull(HOST_OPEN_BUTTON_ID, 2000);
    if (hostButton !== null) {
      return;
    }

    const memberCenterPage = await findByIdOrNull(MEMBER_CENTER_PAGE_ROOT_ID, 1000);
    if (memberCenterPage !== null) {
      await DRIVER.pressBack();
      await DRIVER.waitForIdle(1000, 5000);
    } else {
      await DRIVER.waitForIdle(1000, 2000);
    }
  }

  throw new Error('Unable to reach member center test host page');
}

export default function MemberCenterPageTest() {
  describe('MemberCenterPageTest', () => {
    beforeAll(async () => {
      await ensureHostPageLoaded();
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_renders_member_packages_privileges_and_open_controls', 0, async () => {
      await ensureHostPageLoaded();
      await waitForHostPageLoaded();
      await clickById(HOST_OPEN_BUTTON_ID);
      await waitForMemberCenterPageLoaded();

      await assertTextVisible('会员中心');
      await assertTextVisible('会员套餐');
      await assertTextVisible('连续包月');
      await assertTextVisible('会员月卡');
      await assertTextVisible('会员权益');
      await assertTextVisible('免广告');
      await assertTextVisible('优先咨询');
      await assertTextVisible('专属客服');
      await assertTextVisible('开通前请阅读并同意');
      await assertTextVisible('《会员服务协议》');
      await assertTextVisible('立即开通');

      await findById(MEMBER_CENTER_PACKAGE_CARD_1_ID);
      await findById(MEMBER_CENTER_PACKAGE_CARD_2_ID);
      await findById(MEMBER_CENTER_AGREEMENT_CHECKBOX_ID);
      await findById(MEMBER_CENTER_AGREEMENT_LINK_ID);
      await findById(MEMBER_CENTER_OPEN_NOW_BUTTON_ID);

      await DRIVER.pressBack();
      await waitForHostPageLoaded();
    }, 60000);
  });
}
