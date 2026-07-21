import { describe, it, beforeAll, expect } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const HOST_ANCHOR_ID: string = 'order_detail_test_host_anchor';
const OPEN_GOOD_DETAIL_BUTTON_ID: string = 'good_detail_test_open_page';
const FIXTURE_GOOD_NAME: string = 'Package target';

const driver: Driver = Driver.create();

async function waitForById(id: string, timeoutMs: number = 10000): Promise<Component> {
  return await driver.waitForComponent(ON.id(id), timeoutMs);
}

async function waitForText(text: string, timeoutMs: number = 15000): Promise<Component> {
  return await driver.waitForComponent(ON.text(text), timeoutMs);
}

async function ensureGoodDetailPageOpened(): Promise<void> {
  await waitForById(HOST_ANCHOR_ID);
  const openButton: Component = await waitForById(OPEN_GOOD_DETAIL_BUTTON_ID);
  await openButton.click();
  await waitForText(FIXTURE_GOOD_NAME);
}

export default function goodDetailPageTest() {
  describe('GoodDetailPageTest', () => {
    beforeAll(async () => {
      await ensureGoodDetailPageOpened();
    });

    it('renders_package_good_detail_page', 0, async () => {
      const goodNameComp: Component = await waitForText(FIXTURE_GOOD_NAME);
      expect(goodNameComp !== null).assertTrue();
      const renderedName: string = await goodNameComp.getText();
      expect(renderedName).assertEqual(FIXTURE_GOOD_NAME);
    });
  });
}
