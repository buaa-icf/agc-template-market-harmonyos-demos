import { describe, it, beforeAll, expect } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const HOST_ANCHOR_ID: string = 'order_detail_test_host_anchor';
const OPEN_GOOD_DETAIL_BUTTON_ID: string = 'good_detail_test_open_page';
const HOST_ANCHOR_TEXT: string = 'Order Detail UITest Host';
const OPEN_GOOD_DETAIL_BUTTON_TEXT: string = 'Open Good Detail (package)';
const GOOD_DETAIL_ROOT_ID: string = 'good_detail_page_root';
const FIRST_PACKAGE_SPEC_ID: string = 'good_detail_package_spec_0';

const driver: Driver = Driver.create();

async function waitForById(id: string, timeoutMs: number = 4000): Promise<Component> {
  const component: Component = await driver.waitForComponent(ON.id(id), timeoutMs);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function waitForText(text: string, timeoutMs: number = 6000): Promise<Component> {
  const component: Component = await driver.waitForComponent(ON.text(text), timeoutMs);
  if (component === null) {
    throw new Error(`Unable to find text: ${text}`);
  }
  return component;
}

async function ensureGoodDetailPageOpened(): Promise<void> {
  const hostById: Component = await driver.waitForComponent(ON.id(HOST_ANCHOR_ID), 1000);
  if (hostById === null) {
    await waitForText(HOST_ANCHOR_TEXT, 3000);
  }

  let openButton: Component = await driver.waitForComponent(ON.id(OPEN_GOOD_DETAIL_BUTTON_ID), 1000);
  if (openButton === null) {
    openButton = await waitForText(OPEN_GOOD_DETAIL_BUTTON_TEXT, 3000);
  }
  await openButton.click();
  await driver.waitForIdle(500, 2000);
  await waitForById(GOOD_DETAIL_ROOT_ID, 6000);
  await waitForById(FIRST_PACKAGE_SPEC_ID, 6000);
}

export default function goodDetailPageTest() {
  describe('GoodDetailPageTest', () => {
    beforeAll(async () => {
      await ensureGoodDetailPageOpened();
    });

    it('renders_package_good_detail_page', 0, async () => {
      const detailRoot: Component = await waitForById(GOOD_DETAIL_ROOT_ID);
      const firstPackageSpec: Component = await waitForById(FIRST_PACKAGE_SPEC_ID);
      expect(detailRoot !== null).assertTrue();
      expect(firstPackageSpec !== null).assertTrue();
    });
  });
}
