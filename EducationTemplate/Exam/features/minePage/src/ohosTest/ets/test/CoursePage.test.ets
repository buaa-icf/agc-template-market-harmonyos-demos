import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const COURSE_HOST_ANCHOR_ID: string = 'mine_page_course_instrument_host_anchor';
const SHOW_COURSE_PAGE_TRIGGER_ID: string = 'course_show_page_trigger';
const RESET_COURSE_PAGE_TRIGGER_ID: string = 'course_reset_to_filled_trigger';
const SWITCH_COURSE_TO_EMPTY_TRIGGER_ID: string = 'course_switch_to_empty_trigger';
const COURSE_ROOT_ID: string = 'course_page_root';
const COURSE_LIST_ID: string = 'course_page_list';
const COURSE_EMPTY_TEXT_ID: string = 'course_page_empty_text';
const COURSE_DELETE_TOGGLE_ID: string = 'course_page_delete_toggle';
const COURSE_DELETE_BUTTON_ID: string = 'course_page_delete_button';
const COURSE_SELECT_ALL_ID: string = 'course_page_select_all_toggle';
const COURSE_ITEM_CONTENT_0_ID: string = 'course_page_item_content_0';
const COURSE_ITEM_PRICE_0_ID: string = 'course_page_item_price_0';
const COURSE_ITEM_BUYERS_0_ID: string = 'course_page_item_buyers_0';
const COURSE_ITEM_DETAIL_BUTTON_0_ID: string = 'course_page_item_detail_button_0';

async function findById(id: string, timeout: number = 8000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function settle(delay: number = 300): Promise<void> {
  await DRIVER.delayMs(delay);
}

async function refreshUi(): Promise<void> {
  await settle();
  await DRIVER.waitForIdle(500, 3000);
}

async function enterDeleteMode(): Promise<Component> {
  for (let attempt = 0; attempt < 4; attempt++) {
    const existing = await DRIVER.waitForComponent(ON.id(COURSE_DELETE_BUTTON_ID), 500);
    if (existing !== null) {
      return existing;
    }
    const deleteToggle = await findById(COURSE_DELETE_TOGGLE_ID);
    await deleteToggle.click();
    await settle(500);
    const activated = await DRIVER.waitForComponent(ON.id(COURSE_DELETE_BUTTON_ID), 1200);
    if (activated !== null) {
      return activated;
    }
  }
  throw new Error(`Unable to find id: ${COURSE_DELETE_BUTTON_ID}`);
}

export default function coursePageInstrumentTest() {
  describe('CoursePageInstrumentTest', () => {
    beforeAll(async () => {
      await settle(500);
      await findById(COURSE_HOST_ANCHOR_ID, 12000);
      const showCourse = await findById(SHOW_COURSE_PAGE_TRIGGER_ID);
      await showCourse.click();
      await settle(500);
      await findById(COURSE_ROOT_ID);
      await findById(COURSE_ITEM_CONTENT_0_ID);
    });

    afterAll(async () => {
      await settle();
    });

    it('covers_course_render_selection_deletion_and_empty_state', 0, async () => {
      await findById(COURSE_LIST_ID);
      await findById(COURSE_ITEM_PRICE_0_ID);
      await findById(COURSE_ITEM_BUYERS_0_ID);
      await findById(COURSE_ITEM_DETAIL_BUTTON_0_ID);

      await enterDeleteMode();
      const selectAllToggle = await findById(COURSE_SELECT_ALL_ID);
      await selectAllToggle.click();
      await refreshUi();
      const activeDeleteToggle = await findById(COURSE_DELETE_TOGGLE_ID);
      await activeDeleteToggle.click();
      await settle(500);

      const resetCourse = await findById(RESET_COURSE_PAGE_TRIGGER_ID);
      await resetCourse.click();
      await settle(500);
      await findById(COURSE_ITEM_CONTENT_0_ID);

      await enterDeleteMode();
      const activeSelectAllToggle = await findById(COURSE_SELECT_ALL_ID);
      await activeSelectAllToggle.click();
      await refreshUi();
      const activeEmptyDeleteToggle = await findById(COURSE_DELETE_TOGGLE_ID);
      await activeEmptyDeleteToggle.click();
      await settle();
      await findById(COURSE_ITEM_CONTENT_0_ID);

      const switchToEmpty = await findById(SWITCH_COURSE_TO_EMPTY_TRIGGER_ID);
      await switchToEmpty.click();
      await settle(500);
      await findById(COURSE_EMPTY_TEXT_ID);
    });
  });
}
