import { describe, it, TestType, Size, Level } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';
import { KeyCode } from '@ohos.multimodalInput.keyCode';

const FIND_TIMEOUT_MS: number = 5_000;
const IDLE_POLL_MS: number = 1_000;
const IDLE_TIMEOUT_MS: number = 3_000;

async function waitForIdle(driver: Driver): Promise<void> {
  await driver.waitForIdle(IDLE_POLL_MS, IDLE_TIMEOUT_MS);
}

async function findById(driver: Driver, id: string): Promise<Component> {
  const component = await driver.waitForComponent(ON.id(id), FIND_TIMEOUT_MS);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function click(component: Component, driver: Driver): Promise<void> {
  await component.click();
  await waitForIdle(driver);
}

export default function QuickLoginPageTest() {
  describe('QuickLoginPageTest', () => {
    it('bulidSpan should navigate to linked agreement pages on quick login page',
      TestType.FUNCTION | Size.MEDIUMTEST | Level.LEVEL3, async () => {
        const driver = Driver.create();

        await waitForIdle(driver);
        await findById(driver, 'quick_login_test_host_anchor');

        await click(await findById(driver, 'quick_login_test_open_page'), driver);
        await findById(driver, 'login_with_huaweiId_button');

        await click(await findById(driver, 'quick_login_terms_link'), driver);
        await findById(driver, 'agreement_terms_page_anchor');

        await driver.triggerKey(KeyCode.KEYCODE_BACK);
        await waitForIdle(driver);
        await findById(driver, 'login_with_huaweiId_button');

        await click(await findById(driver, 'quick_login_privacy_link'), driver);
        await findById(driver, 'agreement_privacy_page_anchor');
      });
  });
}
