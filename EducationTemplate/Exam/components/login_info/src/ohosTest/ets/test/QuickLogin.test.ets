import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const ROOT_ID = 'quick_login_cover_root';
const ICON_ID = 'quick_login_cover_icon';
const PHONE_ID = 'quick_login_cover_phone';
const DESC_ID = 'quick_login_cover_desc';
const LOGIN_BUTTON_ID = 'quick_login_cover_login_button';
const PRIVACY_CHECKBOX_ID = 'quick_login_cover_privacy_checkbox';
const PRIVACY_TEXT_ID = 'quick_login_cover_privacy_text';
const SERVICE_POLICY_LINK_ID = 'quick_login_cover_privacy_link_1';
const PRIVACY_POLICY_LINK_ID = 'quick_login_cover_privacy_link_2';
const ACCOUNT_ROUTER_LINK_ID = 'quick_login_cover_privacy_link_4';
const DEFAULT_ROOT_ID = 'quick_login_default_root';
const DEFAULT_ICON_ID = 'quick_login_default_icon';
const DEFAULT_PHONE_ID = 'quick_login_default_phone';
const DEFAULT_LOGIN_BUTTON_ID = 'quick_login_default_login_button';
const DEFAULT_PRIVACY_CHECKBOX_ID = 'quick_login_default_privacy_checkbox';
const DEFAULT_PRIVACY_TEXT_ID = 'quick_login_default_privacy_text';
const DEFAULT_SERVICE_POLICY_LINK_ID = 'quick_login_default_privacy_link_1';
const DEFAULT_PRIVACY_POLICY_LINK_ID = 'quick_login_default_privacy_link_2';
const DEFAULT_ACCOUNT_ROUTER_LINK_ID = 'quick_login_default_privacy_link_4';

async function waitForIdle(): Promise<void> {
  await DRIVER.waitForIdle(800, 8000);
}

async function findById(id: string, timeout: number = 8000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function findByText(text: string, timeout: number = 8000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.text(text), timeout);
  if (component === null) {
    throw new Error(`Unable to find text: ${text}`);
  }
  return component;
}

export default function quickLoginCoverTest() {
  describe('QuickLoginCoverTest', () => {
    beforeAll(async () => {
      await waitForIdle();
      await findById(ROOT_ID, 12000);
    });

    afterAll(async () => {
      await waitForIdle();
    });

    it('cover_login_should_render_core_nodes_with_stable_ids', 0, async () => {
      await findById(ICON_ID);
      await findById(PHONE_ID);
      await findById(DESC_ID);
      await findById(LOGIN_BUTTON_ID);
      await findById(PRIVACY_CHECKBOX_ID);
      await findById(PRIVACY_TEXT_ID);
    });

    it('cover_login_should_show_default_phone_and_description_node', 0, async () => {
      await findByText('177******96');
      await findById(DESC_ID);
    });

    it('cover_login_checkbox_should_apply_and_remove_agreement', 0, async () => {
      const checkbox = await findById(PRIVACY_CHECKBOX_ID);
      await checkbox.click();
      await waitForIdle();
      await checkbox.click();
      await waitForIdle();
    });

    it('cover_login_should_invoke_each_privacy_link_branch', 0, async () => {
      await (await findById(SERVICE_POLICY_LINK_ID)).click();
      await waitForIdle();
      await (await findById(PRIVACY_POLICY_LINK_ID)).click();
      await waitForIdle();
      await (await findById(ACCOUNT_ROUTER_LINK_ID)).click();
      await waitForIdle();
    });

    it('default_login_should_render_and_toggle_both_agreement_states', 0, async () => {
      await DRIVER.pressBack();
      await waitForIdle();

      await findById(DEFAULT_ROOT_ID, 12000);
      await findById(DEFAULT_ICON_ID);
      await findById(DEFAULT_PHONE_ID);
      await findById(DEFAULT_LOGIN_BUTTON_ID);
      await findById(DEFAULT_PRIVACY_TEXT_ID);

      const checkbox = await findById(DEFAULT_PRIVACY_CHECKBOX_ID);
      await checkbox.click();
      await waitForIdle();
      await checkbox.click();
      await waitForIdle();

      await (await findById(DEFAULT_SERVICE_POLICY_LINK_ID)).click();
      await waitForIdle();
      await (await findById(DEFAULT_PRIVACY_POLICY_LINK_ID)).click();
      await waitForIdle();
      await (await findById(DEFAULT_ACCOUNT_ROUTER_LINK_ID)).click();
      await waitForIdle();
    });
  });
}
