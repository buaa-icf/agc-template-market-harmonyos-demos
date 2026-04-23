import { beforeAll, describe, expect, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const UI_TIMEOUT = 10000;
const IDLE_DELAY = 1200;
const HOST_ANCHOR_ID = 'recommend_bar_host_anchor';
const POPULATED_BUTTON_ID = 'recommend_bar_show_populated';
const EMPTY_BUTTON_ID = 'recommend_bar_show_empty';
const TITLE_ID = 'recommend_bar_title';
const DETAIL_PARAM_ID = 'recommend_bar_detail_param';

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

export default function RecommendBarTest() {
  describe('RecommendBarTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = Driver.create();
      await waitForIdle(driver, 2000);
      await findById(driver, HOST_ANCHOR_ID);
    });

    it('build_renders_recommend_cards', 0, async () => {
      await (await findById(driver, POPULATED_BUTTON_ID)).click();
      await waitForIdle(driver);

      expect(await getTextById(driver, TITLE_ID)).assertEqual('推荐展览');
      expect(await getTextById(driver, 'recommend_bar_name_rec-1')).assertEqual('Echoes of Civilisation');
      expect(await getTextById(driver, 'recommend_bar_name_rec-2')).assertEqual('Silk Road Journey');
      expect(await getTextById(driver, 'recommend_bar_price_rec-1')).assertEqual('68');
      expect(await getTextById(driver, 'recommend_bar_price_rec-2')).assertEqual('88');
    });

    it('build_hides_recommend_cards_in_empty_state', 0, async () => {
      await (await findById(driver, EMPTY_BUTTON_ID)).click();
      await waitForIdle(driver);

      await findById(driver, TITLE_ID);

      const firstName = await driver.findComponent(ON.id('recommend_bar_name_rec-1'));
      if (firstName !== null) {
        throw new Error('recommend_bar_name_rec-1 should be hidden in empty scenario.');
      }

      const firstCard = await driver.findComponent(ON.id('recommend_bar_item_rec-1'));
      if (firstCard !== null) {
        throw new Error('recommend_bar_item_rec-1 should be hidden in empty scenario.');
      }
    });

    it('build_navigates_to_detail_page_when_card_clicked', 0, async () => {
      await (await findById(driver, POPULATED_BUTTON_ID)).click();
      await waitForIdle(driver);

      await (await findById(driver, 'recommend_bar_item_rec-1')).click();
      await waitForIdle(driver);

      expect(await getTextById(driver, DETAIL_PARAM_ID)).assertEqual('Detail:rec-1');
    });
  });
}
