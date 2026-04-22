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
  });
}
