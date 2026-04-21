import { describe, beforeAll, beforeEach, afterAll, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID: string = 'mine_page_collection_instrument_host_anchor';
const COLLECTION_ROOT_ID: string = 'collection_page_root';
const COLLECTION_EMPTY_TEXT_ID: string = 'collection_page_empty_text';
const COLLECTION_DELETE_TOGGLE_ID: string = 'collection_page_delete_toggle';
const COLLECTION_DELETE_BUTTON_ID: string = 'collection_page_delete_button';
const COLLECTION_SELECT_ALL_ID: string = 'collection_page_select_all_toggle';
const COLLECTION_ITEM_CONTENT_0_ID: string = 'collection_page_item_content_0';
const COLLECTION_ITEM_PRICE_0_ID: string = 'collection_page_item_price_0';
const COLLECTION_ITEM_BUYERS_0_ID: string = 'collection_page_item_buyers_0';
const COLLECTION_ITEM_DETAIL_BUTTON_0_ID: string = 'collection_page_item_detail_button_0';
const ABOUT_TO_DISAPPEAR_MARKER_ID: string = 'collection_about_to_disappear_marker';
const ABOUT_TO_DISAPPEAR_TRIGGER_ID: string = 'collection_about_to_disappear_trigger';
const SWITCH_TO_EMPTY_TRIGGER_ID: string = 'collection_switch_to_empty_trigger';
const SWITCH_TO_FILLED_TRIGGER_ID: string = 'collection_switch_to_filled_trigger';
const SHOW_COLLECTION_PAGE_TRIGGER_ID: string = 'collection_show_page_trigger';
const RESET_COLLECTION_PAGE_TRIGGER_ID: string = 'collection_reset_to_filled_trigger';
const COLLECTION_HOST_READY_FILLED_MARKER_ID: string = 'collection_host_ready_filled_marker';

async function waitForIdle(): Promise<void> {
  await DRIVER.waitForIdle(800, 8000);
}

async function findById(id: string, timeout: number = 8000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function ensureTextNotVisible(text: string): Promise<void> {
  const component = await DRIVER.findComponent(ON.text(text));
  if (component !== null) {
    throw new Error(`Unexpected text found: ${text}`);
  }
}

async function resetToVisibleFilledState(): Promise<void> {
  const reset = await findById(RESET_COLLECTION_PAGE_TRIGGER_ID, 12000);
  await reset.click();
  await waitForIdle();

  const hide = await findById(ABOUT_TO_DISAPPEAR_TRIGGER_ID, 12000);
  await hide.click();
  await waitForIdle();

  const show = await findById(SHOW_COLLECTION_PAGE_TRIGGER_ID, 12000);
  await show.click();
  await waitForIdle();

  const filled = await findById(SWITCH_TO_FILLED_TRIGGER_ID, 12000);
  await filled.click();
  await waitForIdle();

  await findById(HOST_ANCHOR_ID, 12000);
  await findById(COLLECTION_HOST_READY_FILLED_MARKER_ID, 12000);
  await findById(COLLECTION_ROOT_ID, 12000);
  await findById(COLLECTION_ITEM_CONTENT_0_ID, 20000);
  const emptyText = await DRIVER.findComponent(ON.id(COLLECTION_EMPTY_TEXT_ID));
  if (emptyText !== null) {
    throw new Error('Reset failed: collection page stayed in empty state');
  }
}

export default function collectionPageInstrumentTest() {
  describe('CollectionPageInstrumentTest', () => {
    beforeAll(async () => {
      await waitForIdle();
      await findById(HOST_ANCHOR_ID, 12000);
    });

    beforeEach(async () => {
      await resetToVisibleFilledState();
    });

    afterAll(async () => {
      await waitForIdle();
    });

    it('collection_page_build_should_render_root_and_switch_content_by_data_state', 0, async () => {
      await findById(COLLECTION_ROOT_ID);
      await findById(COLLECTION_ITEM_CONTENT_0_ID);

      const switchToEmpty = await findById(SWITCH_TO_EMPTY_TRIGGER_ID);
      await switchToEmpty.click();
      await waitForIdle();
      await findById(COLLECTION_EMPTY_TEXT_ID);
    });

    it('collection_page_deleteButtonBuilder_should_delete_selected_items', 0, async () => {
      await findById(COLLECTION_ITEM_CONTENT_0_ID);

      const deleteToggle = await findById(COLLECTION_DELETE_TOGGLE_ID);
      await deleteToggle.click();
      await waitForIdle();

      const selectAll = await findById(COLLECTION_SELECT_ALL_ID);
      await selectAll.click();
      await waitForIdle();

      const deleteButton = await findById(COLLECTION_DELETE_BUTTON_ID);
      await deleteButton.click();
      await waitForIdle();

      await findById(COLLECTION_EMPTY_TEXT_ID);
    });

    it('collection_page_isSelectAllClick_should_select_and_unselect_items', 0, async () => {
      await findById(COLLECTION_ITEM_CONTENT_0_ID);

      const deleteToggle = await findById(COLLECTION_DELETE_TOGGLE_ID);
      await deleteToggle.click();
      await waitForIdle();

      const selectAll = await findById(COLLECTION_SELECT_ALL_ID);
      await selectAll.click();
      await waitForIdle();
      await selectAll.click();
      await waitForIdle();

      const deleteButtonWhenUnselected = await findById(COLLECTION_DELETE_BUTTON_ID);
      await deleteButtonWhenUnselected.click();
      await waitForIdle();
      await findById(COLLECTION_ITEM_CONTENT_0_ID);

      const selectAllForDelete = await findById(COLLECTION_SELECT_ALL_ID);
      await selectAllForDelete.click();
      await waitForIdle();

      const deleteButtonAfterSelectAll = await findById(COLLECTION_DELETE_BUTTON_ID);
      await deleteButtonAfterSelectAll.click();
      await waitForIdle();
      await findById(COLLECTION_EMPTY_TEXT_ID);
    });

    it('collection_page_collectListBuilder_should_render_key_list_nodes', 0, async () => {
      await findById(COLLECTION_ITEM_CONTENT_0_ID);
      await findById(COLLECTION_ITEM_PRICE_0_ID);
      await findById(COLLECTION_ITEM_BUYERS_0_ID);
      await findById(COLLECTION_ITEM_DETAIL_BUTTON_0_ID);
    });

    it('collection_page_aboutToDisappear_should_invoke_event_callback', 0, async () => {
      const trigger = await findById(ABOUT_TO_DISAPPEAR_TRIGGER_ID);
      await trigger.click();
      await waitForIdle();
      await findById(ABOUT_TO_DISAPPEAR_MARKER_ID);
    });

    it('instrument_host_should_not_fall_back_to_hello_world_page', 0, async () => {
      await ensureTextNotVisible('Hello World');
      await ensureTextNotVisible('Hello world');
    });
  });
}
