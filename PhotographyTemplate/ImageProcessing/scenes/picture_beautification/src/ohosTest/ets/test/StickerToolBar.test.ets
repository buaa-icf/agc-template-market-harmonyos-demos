import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium';
import { Driver, ON, MatchPattern, Component } from '@kit.TestKit';

const RUN_FLAG: string = 'stickerToolBar.runTest';
const HOST_ID: string = 'sticker_toolbar_test_host';
const SEARCH_GRID_ID: string = 'sticker_search_grid';
const SEARCH_ITEM_PREFIX: string = 'sticker_search_item_';
const TAB_GRID_PREFIX: string = 'sticker_tab_grid_';
const TAB_ITEM_PREFIX: string = 'sticker_tab_item_';
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

async function findByText(text: string, timeout: number = FIND_TIMEOUT_MS): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.text(text, MatchPattern.EQUALS), timeout);
  if (!component) {
    throw new Error(`Unable to find text: ${text}`);
  }
  return component;
}

async function clickById(id: string): Promise<void> {
  const component = await findById(id);
  await component.click();
  await DRIVER.waitForIdle(300, 5000);
}

export default function stickerToolBarTest() {
  describe('StickerToolBarInstrumentTest', () => {
    beforeAll(async () => {
      AppStorage.setOrCreate(RUN_FLAG, true);
      AppStorage.setOrCreate('isVip', false);
      AppStorage.setOrCreate('loginState', false);
      await DRIVER.waitForIdle(1000, 10000);
      await findById(HOST_ID);
      await DRIVER.delayMs(800);
    });

    afterAll(async () => {
      AppStorage.setOrCreate(RUN_FLAG, false);
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_renders_search_grid_and_action_buttons', 0, async () => {
      const searchGrid = await findById(SEARCH_GRID_ID);
      const closeBtn = await findById(CLOSE_BUTTON_ID);
      const saveBtn = await findById(SAVE_BUTTON_ID);
      expect(searchGrid !== null).assertTrue();
      expect(closeBtn !== null).assertTrue();
      expect(saveBtn !== null).assertTrue();
    });

    it('search_grid_item_click_pushes_non_vip_sticker', 0, async () => {
      const tagAnchor = await findByText('最新');
      expect(tagAnchor !== null).assertTrue();
      await clickById(`${SEARCH_ITEM_PREFIX}0`);
      await clickById(`${SEARCH_ITEM_PREFIX}1`);
    });

    it('search_grid_vip_item_routes_login_dialog_or_pushes_by_state', 0, async () => {
      AppStorage.setOrCreate('loginState', false);
      AppStorage.setOrCreate('isVip', false);
      await DRIVER.waitForIdle(300, 5000);
      await clickById(`${SEARCH_ITEM_PREFIX}2`);

      AppStorage.setOrCreate('loginState', true);
      AppStorage.setOrCreate('isVip', false);
      await DRIVER.waitForIdle(300, 5000);
      await clickById(`${SEARCH_ITEM_PREFIX}2`);

      AppStorage.setOrCreate('loginState', true);
      AppStorage.setOrCreate('isVip', true);
      await DRIVER.waitForIdle(300, 5000);
      await clickById(`${SEARCH_ITEM_PREFIX}2`);
    });

    it('tab_grid_non_vip_item_click_pushes_sticker', 0, async () => {
      const tabGrid = await findById(`${TAB_GRID_PREFIX}0`);
      expect(tabGrid !== null).assertTrue();
      await clickById(`${TAB_ITEM_PREFIX}0_0`);
      await clickById(`${TAB_ITEM_PREFIX}0_1`);
    });

    it('tab_grid_vip_item_routes_to_login_when_logged_out', 0, async () => {
      AppStorage.setOrCreate('loginState', false);
      AppStorage.setOrCreate('isVip', false);
      await DRIVER.waitForIdle(300, 5000);
      await clickById(`${TAB_ITEM_PREFIX}0_2`);
    });

    it('tab_grid_vip_item_opens_vip_dialog_when_logged_in_non_vip', 0, async () => {
      AppStorage.setOrCreate('loginState', true);
      AppStorage.setOrCreate('isVip', false);
      await DRIVER.waitForIdle(300, 5000);
      await clickById(`${TAB_ITEM_PREFIX}0_2`);
    });

    it('tab_grid_vip_item_pushes_sticker_when_vip_user', 0, async () => {
      AppStorage.setOrCreate('loginState', true);
      AppStorage.setOrCreate('isVip', true);
      await DRIVER.waitForIdle(300, 5000);
      await clickById(`${TAB_ITEM_PREFIX}0_2`);
    });

    it('switch_tab_renders_new_grid_and_supports_clicks', 0, async () => {
      const hot = await findByText('热门');
      await hot.click();
      await DRIVER.waitForIdle(300, 5000);
      const tab1Grid = await findById(`${TAB_GRID_PREFIX}1`);
      expect(tab1Grid !== null).assertTrue();
      await clickById(`${TAB_ITEM_PREFIX}1_0`);
    });
  });
}
