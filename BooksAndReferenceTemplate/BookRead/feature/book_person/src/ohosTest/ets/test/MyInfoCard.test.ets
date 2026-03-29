import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const HOST_GUEST_BUTTON_ID = 'my_info_card_test_open_guest';
const HOST_NON_MEMBER_BUTTON_ID = 'my_info_card_test_open_non_member';
const HOST_MEMBER_BUTTON_ID = 'my_info_card_test_open_member';
const CARD_RETURN_BUTTON_ID = 'my_info_card_test_card_return_host';
const LOGIN_RETURN_BUTTON_ID = 'my_info_card_test_login_return_host';
const MEMBER_CENTER_RETURN_BUTTON_ID = 'my_info_card_test_member_return_host';
const LOGIN_MARKER_ID = 'my_info_card_test_login_page';
const MEMBER_CENTER_MARKER_ID = 'my_info_card_test_member_center_page';
const MY_INFO_CARD_ROOT_ID = 'my_info_card_root';
const CARD_SCENARIO_MARKER_ID = 'my_info_card_test_card_scenario';
const GUEST_LOGIN_ID = 'my_info_card_guest_login';
const MEMBERSHIP_ACTION_ID = 'my_info_card_membership_action';
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

async function clickById(id: string, timeout: number = 5000): Promise<void> {
  await (await findById(id, timeout)).click();
  await DRIVER.waitForIdle(500, 5000);
}

async function assertTextVisible(text: string, timeout: number = 5000): Promise<void> {
  await findByText(text, timeout);
}

async function waitForHostPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(HOST_GUEST_BUTTON_ID, 10000);
}

async function waitForCardLoaded(scenario: string): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(MY_INFO_CARD_ROOT_ID, 10000);
  const scenarioMarker = await findById(CARD_SCENARIO_MARKER_ID, 10000);
  const scenarioText = await scenarioMarker.getText();
  if (scenarioText !== scenario) {
    throw new Error(`Unexpected card scenario: ${scenarioText}`);
  }
}

async function waitForLoginPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(500, 5000);
  await findById(LOGIN_MARKER_ID, 10000);
}

async function waitForMemberCenterPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(500, 5000);
  await findById(MEMBER_CENTER_MARKER_ID, 10000);
}

async function returnToHostFromMemberCenter(): Promise<void> {
  await clickById(MEMBER_CENTER_RETURN_BUTTON_ID);
  await waitForHostPageLoaded();
}

async function returnToHostFromCard(): Promise<void> {
  await clickById(CARD_RETURN_BUTTON_ID);
  await waitForHostPageLoaded();
}

async function returnToHostFromLogin(): Promise<void> {
  await clickById(LOGIN_RETURN_BUTTON_ID);
  await waitForHostPageLoaded();
}

export default function MyInfoCardTest() {
  describe('MyInfoCardTest', () => {
    beforeAll(async () => {
      await waitForHostPageLoaded();
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_renders_guest_non_member_and_member_states', 0, async () => {
      await clickById(HOST_GUEST_BUTTON_ID);
      await waitForCardLoaded('guest');
      await assertTextVisible('去登录');
      await assertTextVisible('开通会员');
      await clickById(GUEST_LOGIN_ID);
      await waitForLoginPageLoaded();
      await returnToHostFromLogin();

      await clickById(HOST_NON_MEMBER_BUTTON_ID);
      await waitForCardLoaded('non_member');
      await assertTextVisible('测试用户');
      await assertTextVisible('未开通');
      await assertTextVisible('开通会员');
      await returnToHostFromCard();

      await clickById(HOST_MEMBER_BUTTON_ID);
      await waitForCardLoaded('member');
      await assertTextVisible('会员用户');
      await assertTextVisible('VIP会员');
      await assertTextVisible('会员中心');
      await clickById(MEMBERSHIP_ACTION_ID);
      await waitForMemberCenterPageLoaded();
      await returnToHostFromMemberCenter();
    });
  });
}
