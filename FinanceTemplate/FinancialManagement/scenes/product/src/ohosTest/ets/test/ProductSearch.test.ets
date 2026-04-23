import { beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const UI_TIMEOUT = 10000;
const IDLE_DELAY = 1200;
const HOST_ANCHOR_ID = 'product_search_host_anchor';
const OPEN_POPULATED_BUTTON_ID = 'product_search_show_populated';
const OPEN_EMPTY_BUTTON_ID = 'product_search_show_empty';
const ROOT_ID = 'product_search_root';
const INPUT_ID = 'product_search_input';
const COUNT_ID = 'product_search_count';
const DETAIL_PARAM_ID = 'product_search_detail_param';
const DETAIL_BACK_ID = 'product_search_detail_back';

async function waitForIdle(driver: Driver, delayMs: number = IDLE_DELAY): Promise<void> {
  await driver.delayMs(delayMs);
}

async function findById(driver: Driver, id: string, timeout: number = UI_TIMEOUT): Promise<Component> {
  const component = await driver.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function getTextById(driver: Driver, id: string, timeout: number = UI_TIMEOUT): Promise<string> {
  return await (await findById(driver, id, timeout)).getText();
}

async function ensureHostVisible(driver: Driver): Promise<void> {
  const hostAnchor = await driver.findComponent(ON.id(HOST_ANCHOR_ID));
  if (hostAnchor !== null) {
    return;
  }

  const detailBackButton = await driver.findComponent(ON.id(DETAIL_BACK_ID));
  if (detailBackButton !== null) {
    await detailBackButton.click();
    await waitForIdle(driver);
  }

  const searchRoot = await driver.findComponent(ON.id(ROOT_ID));
  if (searchRoot !== null) {
    await driver.pressBack();
    await waitForIdle(driver);
  }

  await findById(driver, HOST_ANCHOR_ID);
}

export default function ProductSearchTest() {
  describe('ProductSearchTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = Driver.create();
      await waitForIdle(driver, 2000);
      await ensureHostVisible(driver);
    });

    beforeEach(async () => {
      await waitForIdle(driver);
      await ensureHostVisible(driver);
    });

    it('build_renders_search_results', 0, async () => {
      await (await findById(driver, OPEN_POPULATED_BUTTON_ID)).click();
      await waitForIdle(driver);

      await findById(driver, ROOT_ID);
      await findById(driver, INPUT_ID);
      await findById(driver, COUNT_ID);
      expect(await getTextById(driver, 'product_search_name_1001')).assertEqual('Stable Income One');
      expect(await getTextById(driver, 'product_search_number_1001')).assertEqual('PRD-1001');
      expect(await getTextById(driver, 'product_search_rate_1001')).assertEqual('3.45%');
      expect(await getTextById(driver, 'product_search_cycle_1001')).assertEqual('7-day annualized');
    });

    it('build_renders_empty_results', 0, async () => {
      await (await findById(driver, OPEN_EMPTY_BUTTON_ID)).click();
      await waitForIdle(driver);

      await findById(driver, ROOT_ID);
      await findById(driver, COUNT_ID);

      const firstItem = await driver.findComponent(ON.id('product_search_item_1001'));
      if (firstItem !== null) {
        throw new Error('product_search_item_1001 should be hidden in empty scenario.');
      }
    });

    it('build_navigates_to_product_info_when_item_clicked', 0, async () => {
      await (await findById(driver, OPEN_POPULATED_BUTTON_ID)).click();
      await waitForIdle(driver);

      await (await findById(driver, 'product_search_item_1001')).click();
      await waitForIdle(driver);

      expect(await getTextById(driver, DETAIL_PARAM_ID)).assertEqual('Detail:1001');
    });
  });
}
