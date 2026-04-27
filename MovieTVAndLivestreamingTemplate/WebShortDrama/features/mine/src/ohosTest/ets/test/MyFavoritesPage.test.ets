import { describe, beforeAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const TITLE_ID = 'my_favorites_title_text';
const NAV_ID = 'my_favorites_nav_destination';
const ROOT_COLUMN_ID = 'my_favorites_root_column';
const LIST_ID = 'my_favorites_series_list';
const ITEM_PREFIX = 'my_favorites_series_item_';
const EXPECTED_DRAMA_ID = 'test_fav_001';
const SWITCH_FAVORITES_ID = 'mine_test_switch_favorites';

async function waitForById(driver: Driver, id: string, timeoutMs: number = 8000): Promise<Component> {
  const component = await driver.waitForComponent(ON.id(id), timeoutMs);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

export default function myFavoritesPageUiTest() {
  describe('MyFavoritesPageUiTest', () => {
    const driver: Driver = Driver.create();

    beforeAll(async () => {
      const favoritesButton = await waitForById(driver, SWITCH_FAVORITES_ID, 20000);
      await favoritesButton.click();
      await driver.delayMs(300);
      await waitForById(driver, NAV_ID, 20000);
      await driver.delayMs(500);
    });

    it('should_render_reused_watch_records_region_and_list_item', 0, async () => {
      await waitForById(driver, NAV_ID);
      await waitForById(driver, ROOT_COLUMN_ID);
      await waitForById(driver, LIST_ID);
      await waitForById(driver, TITLE_ID);

      // Verify the repeated WatchRecords-like list region is rendered and item id is discoverable.
      await waitForById(driver, `${ITEM_PREFIX}${EXPECTED_DRAMA_ID}`);
    });
  });
}
