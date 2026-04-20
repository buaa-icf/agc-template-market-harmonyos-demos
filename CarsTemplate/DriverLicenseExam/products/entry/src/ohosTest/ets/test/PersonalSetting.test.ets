import { describe, it, beforeAll, expect } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const HOST_ANCHOR_ID: string = 'personal_setting_test_host_anchor';
const OPEN_PAGE_BUTTON_ID: string = 'personal_setting_test_open_page';
const PRIVACY_POLICY_ITEM_ID: string = 'personal_setting_item_privacy_policy';
const USER_AGREEMENT_ITEM_ID: string = 'personal_setting_item_user_agreement';
const LOGOUT_BUTTON_ID: string = 'personal_setting_logout_button';
const LOGOUT_DIALOG_CONTENT_ID: string = 'personal_setting_logout_dialog_content';

const driver: Driver = Driver.create();

async function waitForById(id: string, timeoutMs: number = 10000): Promise<Component> {
  return await driver.waitForComponent(ON.id(id), timeoutMs);
}

async function ensurePersonalSettingPageOpened(): Promise<void> {
  await waitForById(HOST_ANCHOR_ID);
  const openButton: Component = await waitForById(OPEN_PAGE_BUTTON_ID);
  await openButton.click();
  await waitForById(LOGOUT_BUTTON_ID, 12000);
}

export default function personalSettingTest() {
  describe('PersonalSettingTest', () => {
    beforeAll(async () => {
      await ensurePersonalSettingPageOpened();
    });

    it('build_should_render_action_targets_with_stable_ids', 0, async () => {
      const privacyPolicyItem: Component = await waitForById(PRIVACY_POLICY_ITEM_ID, 12000);
      const userAgreementItem: Component = await waitForById(USER_AGREEMENT_ITEM_ID, 12000);
      const logoutButton: Component = await waitForById(LOGOUT_BUTTON_ID, 12000);
      expect(privacyPolicyItem !== null).assertTrue();
      expect(userAgreementItem !== null).assertTrue();
      expect(logoutButton !== null).assertTrue();
    });

    it('build_should_show_logout_dialog_when_click_logout_button', 0, async () => {
      const logoutButton: Component = await waitForById(LOGOUT_BUTTON_ID, 12000);
      await logoutButton.click();
      const dialogContent: Component = await waitForById(LOGOUT_DIALOG_CONTENT_ID, 12000);
      expect(dialogContent !== null).assertTrue();
    });
  });
}
