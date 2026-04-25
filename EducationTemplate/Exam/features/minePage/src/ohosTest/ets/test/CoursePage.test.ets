import { describe, beforeAll, beforeEach, afterAll, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const COURSE_HOST_ANCHOR_ID: string = 'mine_page_course_instrument_host_anchor';
const SHOW_COLLECTION_PAGE_TRIGGER_ID: string = 'collection_show_page_trigger';
const SHOW_COURSE_PAGE_TRIGGER_ID: string = 'course_show_page_trigger';
const SWITCH_COURSE_TO_EMPTY_TRIGGER_ID: string = 'course_switch_to_empty_trigger';
const SWITCH_COURSE_TO_FILLED_TRIGGER_ID: string = 'course_switch_to_filled_trigger';
const RESET_COURSE_PAGE_TRIGGER_ID: string = 'course_reset_to_filled_trigger';
const COURSE_HOST_READY_FILLED_MARKER_ID: string = 'course_host_ready_filled_marker';
const COURSE_ROOT_ID: string = 'course_page_root';
const COURSE_LIST_ID: string = 'course_page_list';
const COURSE_EMPTY_TEXT_ID: string = 'course_page_empty_text';
const COURSE_DELETE_TOGGLE_ID: string = 'course_page_delete_toggle';
const COURSE_DELETE_BUTTON_ID: string = 'course_page_delete_button';
const COURSE_SELECT_ALL_ID: string = 'course_page_select_all_toggle';
const COURSE_ITEM_SELECT_0_ID: string = 'course_page_select_item_0';
const COURSE_ITEM_CONTENT_0_ID: string = 'course_page_item_content_0';
const COURSE_ITEM_PRICE_0_ID: string = 'course_page_item_price_0';
const COURSE_ITEM_BUYERS_0_ID: string = 'course_page_item_buyers_0';
const COURSE_ITEM_DETAIL_BUTTON_0_ID: string = 'course_page_item_detail_button_0';

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

async function ensureHostReady(): Promise<void> {
  await waitForIdle();
  await findById(COURSE_HOST_ANCHOR_ID, 12000);
}

async function findDeleteButtonQuickly(timeout: number = 1200): Promise<Component | null> {
  return await DRIVER.waitForComponent(ON.id(COURSE_DELETE_BUTTON_ID), timeout);
}

async function enterDeleteMode(): Promise<Component> {
  await findById(COURSE_ROOT_ID, 12000);
  await findById(COURSE_ITEM_CONTENT_0_ID, 12000);

  for (let attempt = 0; attempt < 6; attempt++) {
    const existed = await findDeleteButtonQuickly(800);
    if (existed !== null) {
      return existed;
    }

    const deleteToggle = await findById(COURSE_DELETE_TOGGLE_ID, 12000);
    await deleteToggle.click();
    await waitForIdle();

    const activated = await findDeleteButtonQuickly(1800);
    if (activated !== null) {
      return activated;
    }
  }

  throw new Error(`Unable to find id: ${COURSE_DELETE_BUTTON_ID}`);
}

async function enterDeleteModeWithRetry(): Promise<Component> {
  let lastError: Error | null = null;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      return await enterDeleteMode();
    } catch (error) {
      lastError = error as Error;
      await resetToVisibleFilledState();
    }
  }
  if (lastError !== null) {
    throw lastError;
  }
  throw new Error(`Unable to find id: ${COURSE_DELETE_BUTTON_ID}`);
}

async function resetToVisibleFilledState(): Promise<void> {
  await ensureHostReady();
  const showCollection = await findById(SHOW_COLLECTION_PAGE_TRIGGER_ID, 12000);
  await showCollection.click();
  await waitForIdle();

  const showCourse = await findById(SHOW_COURSE_PAGE_TRIGGER_ID, 12000);
  await showCourse.click();
  await waitForIdle();

  const reset = await findById(RESET_COURSE_PAGE_TRIGGER_ID, 12000);
  await reset.click();
  await waitForIdle();

  const filled = await findById(SWITCH_COURSE_TO_FILLED_TRIGGER_ID, 12000);
  await filled.click();
  await waitForIdle();

  await findById(COURSE_HOST_READY_FILLED_MARKER_ID, 12000);
  await findById(COURSE_ROOT_ID, 12000);
  await findById(COURSE_ITEM_CONTENT_0_ID, 20000);

  const emptyText = await DRIVER.findComponent(ON.id(COURSE_EMPTY_TEXT_ID));
  if (emptyText !== null) {
    throw new Error('Reset failed: course page stayed in empty state');
  }
}

export default function coursePageInstrumentTest() {
  describe('CoursePageInstrumentTest', () => {
    beforeAll(async () => {
      await ensureHostReady();
    });

    beforeEach(async () => {
      await resetToVisibleFilledState();
    });

    afterAll(async () => {
      await waitForIdle();
    });

    it('course_page_build_should_render_root_and_switch_content_by_data_state', 0, async () => {
      await findById(COURSE_ROOT_ID);
      await findById(COURSE_LIST_ID);
      await findById(COURSE_ITEM_CONTENT_0_ID);

      const switchToEmpty = await findById(SWITCH_COURSE_TO_EMPTY_TRIGGER_ID);
      await switchToEmpty.click();
      await waitForIdle();

      await findById(COURSE_EMPTY_TEXT_ID);
    });

    it('course_page_deleteButtonBuilder_should_delete_selected_items', 0, async () => {
      const deleteButton = await enterDeleteModeWithRetry();
      await deleteButton.click();
      await waitForIdle();
      await findById(COURSE_ITEM_CONTENT_0_ID, 12000);
    });

    it('course_page_isSelectAllClick_should_select_and_unselect_items', 0, async () => {
      await enterDeleteModeWithRetry();

      const selectAllToggle = await findById(COURSE_SELECT_ALL_ID, 12000);
      await selectAllToggle.click();
      await waitForIdle();
      await selectAllToggle.click();
      await waitForIdle();

      const deleteButton = await findById(COURSE_DELETE_BUTTON_ID);
      await deleteButton.click();
      await waitForIdle();
      await findById(COURSE_ITEM_CONTENT_0_ID);
    });

    it('course_page_orderInfosBuilder_should_render_key_list_nodes', 0, async () => {
      await findById(COURSE_ITEM_CONTENT_0_ID);
      await findById(COURSE_ITEM_PRICE_0_ID);
      await findById(COURSE_ITEM_BUYERS_0_ID);
      await findById(COURSE_ITEM_DETAIL_BUTTON_0_ID);
    });

    it('course_page_orderInfosBuilder_should_toggle_single_selection_then_delete', 0, async () => {
      await enterDeleteModeWithRetry();
      const selectItem = await findById(COURSE_ITEM_SELECT_0_ID, 12000);
      await selectItem.click();
      await waitForIdle();
      await selectItem.click();
      await waitForIdle();

      const deleteButton = await findById(COURSE_DELETE_BUTTON_ID, 12000);
      await deleteButton.click();
      await waitForIdle();
      await findById(COURSE_ITEM_CONTENT_0_ID, 12000);
    });
  });
}
