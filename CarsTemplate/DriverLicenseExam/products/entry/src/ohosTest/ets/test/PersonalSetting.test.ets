import { beforeAll, describe, expect, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const PRIVACY_POLICY_ITEM_ID: string = 'personal_setting_item_privacy_policy';
const USER_AGREEMENT_ITEM_ID: string = 'personal_setting_item_user_agreement';
const LOGOUT_BUTTON_ID: string = 'personal_setting_logout_button';
const LOGOUT_DIALOG_CONTENT_ID: string = 'personal_setting_logout_dialog_content';
const driver: Driver = Driver.create();

async function waitForById(id: string, timeoutMs: number = 12000): Promise<Component> {
  const component: Component = await driver.waitForComponent(ON.id(id), timeoutMs);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

export default function personalSettingTest() {
  describe('PersonalSettingTest', () => {
    beforeAll(async () => {
      await driver.waitForIdle(1000, 10000);
      await waitForById(LOGOUT_BUTTON_ID);
    });

    it('should_render_all_action_targets', 0, async () => {
      const privacyPolicyItem: Component = await waitForById(PRIVACY_POLICY_ITEM_ID);
      const userAgreementItem: Component = await waitForById(USER_AGREEMENT_ITEM_ID);
      const logoutButton: Component = await waitForById(LOGOUT_BUTTON_ID);

      expect(privacyPolicyItem !== null).assertTrue();
      expect(userAgreementItem !== null).assertTrue();
      expect(logoutButton !== null).assertTrue();
    });

    it('should_show_logout_dialog_after_click', 0, async () => {
      const logoutButton: Component = await waitForById(LOGOUT_BUTTON_ID);
      await logoutButton.click();
      await driver.waitForIdle(1000, 10000);

      const dialogContent: Component = await waitForById(LOGOUT_DIALOG_CONTENT_ID);
      expect(dialogContent !== null).assertTrue();
      await driver.pressBack();
      await driver.waitForIdle(800, 10000);
      await waitForById(LOGOUT_BUTTON_ID);
    });
  });
}
