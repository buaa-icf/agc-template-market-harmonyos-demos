import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID: string = 'mine_page_collection_instrument_host_anchor';
const COLLECTION_ROOT_ID: string = 'collection_page_root';
const COLLECTION_EMPTY_TEXT_ID: string = 'collection_page_empty_text';
const COLLECTION_LIST_ID: string = 'collection_page_list';
const ABOUT_TO_DISAPPEAR_MARKER_ID: string = 'collection_about_to_disappear_marker';
const ABOUT_TO_DISAPPEAR_TRIGGER_ID: string = 'collection_about_to_disappear_trigger';
const SWITCH_TO_EMPTY_TRIGGER_ID: string = 'collection_switch_to_empty_trigger';
const SWITCH_TO_FILLED_TRIGGER_ID: string = 'collection_switch_to_filled_trigger';

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

export default function collectionPageInstrumentTest() {
  describe('CollectionPageInstrumentTest', () => {
    beforeAll(async () => {
      await waitForIdle();
      await findById(HOST_ANCHOR_ID, 12000);
    });

    afterAll(async () => {
      await waitForIdle();
    });

    it('collection_page_build_should_render_root_and_switch_content_by_data_state', 0, async () => {
      const switchToFilled = await findById(SWITCH_TO_FILLED_TRIGGER_ID);
      await switchToFilled.click();
      await waitForIdle();
      await findById(COLLECTION_ROOT_ID);
      await findById(COLLECTION_LIST_ID);

      const switchToEmpty = await findById(SWITCH_TO_EMPTY_TRIGGER_ID);
      await switchToEmpty.click();
      await waitForIdle();
      await findById(COLLECTION_EMPTY_TEXT_ID);
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
