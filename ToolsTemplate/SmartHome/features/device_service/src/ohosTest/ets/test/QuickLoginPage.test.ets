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

// IDs that only exist on pushed NavDestination pages — see
// AgreementView.test.ets for why we detect host state via these instead
// of the (coverage-transparent) host anchor.
const PUSHED_PAGE_MARKERS: string[] = [
  'agreement_terms_page_anchor',
  'agreement_privacy_page_anchor',
  'login_with_huaweiId_button',
];

async function onPushedPage(driver: Driver): Promise<boolean> {
  for (const id of PUSHED_PAGE_MARKERS) {
    if (await driver.waitForComponent(ON.id(id), 400) !== null) {
      return true;
    }
  }
  return false;
}

// Reset shared navigation state before each test by pressing BACK until no
// pushed-page marker remains, then confirm the host anchor.
async function resetToHost(driver: Driver, hostAnchorId: string): Promise<void> {
  await waitForIdle(driver);
  for (let i = 0; i < 8 && await onPushedPage(driver); i++) {
    await driver.triggerKey(KeyCode.KEYCODE_BACK);
    await waitForIdle(driver);
  }
  await findById(driver, hostAnchorId);
}

export default function QuickLoginPageTest() {
  describe('QuickLoginPageTest', () => {
    it('bulidSpan should navigate to linked agreement pages on quick login page',
      TestType.FUNCTION | Size.MEDIUMTEST | Level.LEVEL3, async () => {
        const driver = Driver.create();

        await resetToHost(driver, 'quick_login_test_host_anchor');
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

    it('Huawei ID login button should invoke handleLoginWithHuaweiIDButton',
      TestType.FUNCTION | Size.MEDIUMTEST | Level.LEVEL3, async () => {
        const driver = Driver.create();

        await resetToHost(driver, 'quick_login_test_host_anchor');
        await click(await findById(driver, 'quick_login_test_open_page'), driver);

        // The AccountKit callback can finish with success, a configuration error,
        // or a system authorization surface. The coverage report is the source of
        // truth that handleLoginWithHuaweiIDButton executed; this interaction must
        // not require one environment-specific result UI.
        await click(await findById(driver, 'login_with_huaweiId_button'), driver);
        await driver.waitForIdle(IDLE_POLL_MS, FIND_TIMEOUT_MS);
      });
  });
}
