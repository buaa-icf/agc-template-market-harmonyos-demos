import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const RUN_FLAG: string = 'stickerToolBar.runTest';
const HOST_ID: string = 'sticker_toolbar_test_host';
const TAB_GRID_ID: string = 'sticker_tab_grid_0';
const TAB_ITEM_ID: string = 'sticker_tab_item_0_0';
const SEARCH_GRID_ID: string = 'sticker_search_grid';
const SEARCH_ITEM_ID: string = 'sticker_search_item_0';
const CLOSE_BUTTON_ID: string = 'sticker_toolbar_close_btn';
const SAVE_BUTTON_ID: string = 'sticker_toolbar_save_btn';

const DRIVER: Driver = Driver.create();
const FIND_TIMEOUT_MS: number = 12000;

async function findById(id: string, timeout: number = FIND_TIMEOUT_MS): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (!component) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

export default function stickerToolBarTest() {
  describe('StickerToolBarInstrumentTest', () => {
    beforeAll(async () => {
      AppStorage.setOrCreate(RUN_FLAG, true);
      await DRIVER.waitForIdle(500, 5000);
      await findById(HOST_ID);
    });

    afterAll(async () => {
      AppStorage.setOrCreate(RUN_FLAG, false);
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_should_render_both_repeated_grids', 0, async () => {
      const tabGrid = await findById(TAB_GRID_ID);
      const tabItem = await findById(TAB_ITEM_ID);
      const searchGrid = await findById(SEARCH_GRID_ID);
      const searchItem = await findById(SEARCH_ITEM_ID);
      expect(tabGrid !== null).assertTrue();
      expect(tabItem !== null).assertTrue();
      expect(searchGrid !== null).assertTrue();
      expect(searchItem !== null).assertTrue();
    });

    it('build_should_render_toolbar_action_buttons', 0, async () => {
      const closeButton = await findById(CLOSE_BUTTON_ID);
      const saveButton = await findById(SAVE_BUTTON_ID);
      expect(closeButton !== null).assertTrue();
      expect(saveButton !== null).assertTrue();
    });
  });
}
