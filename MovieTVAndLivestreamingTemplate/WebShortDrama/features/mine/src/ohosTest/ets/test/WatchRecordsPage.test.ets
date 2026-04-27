import { describe, beforeAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const SWITCH_WATCH_RECORDS_ID = 'mine_test_switch_watch_records';
const TITLE_ID = 'watch_records_title_text';
const NAV_ID = 'watch_records_nav_destination';
const ROOT_COLUMN_ID = 'watch_records_root_column';
const LIST_ID = 'watch_records_series_list';
const ITEM_PREFIX = 'watch_records_series_item_';
const EXPECTED_DRAMA_ID = 'test_watch_001';

async function waitForById(driver: Driver, id: string, timeoutMs: number = 8000): Promise<Component> {
  const component = await driver.waitForComponent(ON.id(id), timeoutMs);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

export default function watchRecordsPageUiTest() {
  describe('WatchRecordsPageUiTest', () => {
    const driver: Driver = Driver.create();

    beforeAll(async () => {
      const watchRecordsButton = await waitForById(driver, SWITCH_WATCH_RECORDS_ID, 20000);
      await watchRecordsButton.click();
      await driver.delayMs(300);
      await waitForById(driver, NAV_ID, 20000);
      await driver.delayMs(500);
    });

    it('should_render_reused_favorites_region_and_list_item', 0, async () => {
      await waitForById(driver, NAV_ID);
      await waitForById(driver, ROOT_COLUMN_ID);
      await waitForById(driver, LIST_ID);
      await waitForById(driver, TITLE_ID);

      // Verify the repeated MyFavorites-like list region is rendered and item id is discoverable.
      await waitForById(driver, `${ITEM_PREFIX}${EXPECTED_DRAMA_ID}`);
    });
  });
}
