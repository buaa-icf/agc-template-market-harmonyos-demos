import { describe, it, beforeAll, expect } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const HOST_ANCHOR_ID: string = 'order_detail_test_host_anchor';
const OPEN_PAGE_BUTTON_ID: string = 'order_detail_test_open_page';

const FIXTURE_STORE_NAME: string = 'AGC奶茶(雨花客厅店)';
const FIXTURE_STORE_ADDRESS: string = '南京市雨花台区华为路华为云楼';

const driver: Driver = Driver.create();

async function waitForById(id: string, timeoutMs: number = 10000): Promise<Component> {
  return await driver.waitForComponent(ON.id(id), timeoutMs);
}

async function waitForText(text: string, timeoutMs: number = 15000): Promise<Component> {
  return await driver.waitForComponent(ON.text(text), timeoutMs);
}

async function ensureOrderDetailPageOpened(): Promise<void> {
  await waitForById(HOST_ANCHOR_ID);
  const openButton: Component = await waitForById(OPEN_PAGE_BUTTON_ID);
  await openButton.click();
  await waitForText(FIXTURE_STORE_NAME);
}

export default function orderDetailPageTest() {
  describe('OrderDetailPageTest', () => {
    beforeAll(async () => {
      await ensureOrderDetailPageOpened();
    });

    it('initStoreInfo_copies_store_name_from_order_detail_into_store_card', 0, async () => {
      const storeNameComp: Component = await waitForText(FIXTURE_STORE_NAME);
      expect(storeNameComp !== null).assertTrue();
      const renderedName: string = await storeNameComp.getText();
      expect(renderedName).assertEqual(FIXTURE_STORE_NAME);
    });

    it('initStoreInfo_copies_store_address_from_order_detail_into_store_card', 0, async () => {
      const storeAddressComp: Component = await waitForText(FIXTURE_STORE_ADDRESS);
      expect(storeAddressComp !== null).assertTrue();
      const renderedAddress: string = await storeAddressComp.getText();
      expect(renderedAddress).assertEqual(FIXTURE_STORE_ADDRESS);
    });
  });
}
