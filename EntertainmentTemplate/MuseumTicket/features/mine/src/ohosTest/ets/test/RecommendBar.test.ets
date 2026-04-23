import { beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const UI_TIMEOUT = 10000;
const IDLE_DELAY = 1200;
const HOST_ANCHOR_ID = 'add_visitor_host_anchor';
const RECOMMEND_POPULATED_BUTTON_ID = 'mine_recommend_show_populated';
const RECOMMEND_EMPTY_BUTTON_ID = 'mine_recommend_show_empty';
const RECOMMEND_TITLE_ID = 'mine_recommend_bar_title';
const RECOMMEND_DETAIL_PARAM_ID = 'mine_recommend_detail_param';
const RECOMMEND_DETAIL_BACK_ID = 'mine_recommend_detail_back';

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

  const detailBackButton = await driver.findComponent(ON.id(RECOMMEND_DETAIL_BACK_ID));
  if (detailBackButton !== null) {
    await detailBackButton.click();
    await waitForIdle(driver);
  }

  await findById(driver, HOST_ANCHOR_ID);
}

export default function RecommendBarTest() {
  describe('MineRecommendBarTest', () => {
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

    it('build_renders_recommend_cards', 0, async () => {
      await (await findById(driver, RECOMMEND_POPULATED_BUTTON_ID)).click();
      await waitForIdle(driver);

      await findById(driver, RECOMMEND_TITLE_ID);
      expect(await getTextById(driver, 'mine_recommend_bar_name_mine-rec-1')).assertEqual('Mine Collection Tour');
      expect(await getTextById(driver, 'mine_recommend_bar_detail_mine-rec-1'))
        .assertEqual('Personalised museum route from mine page');
      expect(await getTextById(driver, 'mine_recommend_bar_price_mine-rec-1')).assertEqual('58');
    });

    it('build_hides_recommend_cards_in_empty_state', 0, async () => {
      await (await findById(driver, RECOMMEND_EMPTY_BUTTON_ID)).click();
      await waitForIdle(driver);

      await findById(driver, RECOMMEND_TITLE_ID);

      const firstCard = await driver.findComponent(ON.id('mine_recommend_bar_item_mine-rec-1'));
      if (firstCard !== null) {
        throw new Error('mine_recommend_bar_item_mine-rec-1 should be hidden in empty scenario.');
      }

      const firstName = await driver.findComponent(ON.id('mine_recommend_bar_name_mine-rec-1'));
      if (firstName !== null) {
        throw new Error('mine_recommend_bar_name_mine-rec-1 should be hidden in empty scenario.');
      }
    });

    it('build_navigates_to_detail_page_when_card_clicked', 0, async () => {
      await (await findById(driver, RECOMMEND_POPULATED_BUTTON_ID)).click();
      await waitForIdle(driver);

      await (await findById(driver, 'mine_recommend_bar_item_mine-rec-1')).click();
      await waitForIdle(driver);

      expect(await getTextById(driver, RECOMMEND_DETAIL_PARAM_ID)).assertEqual('Detail:mine-rec-1');
    });
  });
}
