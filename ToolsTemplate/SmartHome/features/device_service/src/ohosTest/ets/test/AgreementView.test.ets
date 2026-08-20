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

// IDs that only exist on pushed NavDestination pages. The host screen
// shows none of them. We rely on these (not the host anchor) to decide
// whether we are still on a pushed page, because waitForComponent finds
// the host anchor even when it is visually covered by a pushed page.
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

// Tests share one app instance and one NavPathStack. A prior suite can
// leave the app several NavDestinations deep, so before each test we press
// BACK until no pushed-page marker is visible (i.e. we are back at the
// host). This makes every test start from the host screen regardless of
// suite execution order or where a previous test stopped.
async function resetToHost(driver: Driver, hostAnchorId: string): Promise<void> {
  await waitForIdle(driver);
  for (let i = 0; i < 8 && await onPushedPage(driver); i++) {
    await driver.triggerKey(KeyCode.KEYCODE_BACK);
    await waitForIdle(driver);
  }
  const cancelButton = await driver.waitForComponent(ON.id('loginPanel_agreement_cancel_btn'), 800);
  if (cancelButton !== null) {
    await click(cancelButton, driver);
  }
  await findById(driver, hostAnchorId);
}

export default function AgreementViewTest() {
  describe('AgreementViewTest', () => {
    it('bulidSpan should navigate to linked agreement pages',
      TestType.FUNCTION | Size.MEDIUMTEST | Level.LEVEL3, async () => {
        const driver = Driver.create();

        await resetToHost(driver, 'agreement_test_host_anchor');
        await click(await findById(driver, 'agreement_test_open_dialog'), driver);
        await click(await findById(driver, 'loginPanel_agreement_terms_link'), driver);
        await findById(driver, 'agreement_terms_page_anchor');
        await click(await findById(driver, 'agreement_terms_page_back'), driver);

        await findById(driver, 'agreement_test_host_anchor');
        await click(await findById(driver, 'loginPanel_agreement_privacy_link'), driver);
        await findById(driver, 'agreement_privacy_page_anchor');
      });

    it('build should render and cancel an agreement without privacy spans',
      TestType.FUNCTION | Size.MEDIUMTEST | Level.LEVEL3, async () => {
        const driver = Driver.create();

        await resetToHost(driver, 'agreement_test_host_anchor');
        await click(await findById(driver, 'agreement_test_open_empty_dialog'), driver);
        await findById(driver, 'loginPanel_agreement_dialog_privacy_title');
        await click(await findById(driver, 'loginPanel_agreement_cancel_btn'), driver);
        await findById(driver, 'agreement_test_host_anchor');
      });
  });
}
