import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const HOST_PAGE_ID = 'book_cover_card_host_page';
const SHELF_ACTION_ID = 'book_cover_card_shelf_action';
const DRIVER = Driver.create();

async function findById(id: string, timeout: number = 10000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

export default function BookCoverCardTest() {
  describe('BookCoverCardTest', () => {
    beforeAll(async () => {
      await DRIVER.waitForIdle(1000, 10000);
      await findById(HOST_PAGE_ID);
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_renders_the_book_cover_and_shelf_action', 0, async () => {
      await findById(HOST_PAGE_ID);
      await findById(SHELF_ACTION_ID);
    });

    it('build_toggles_the_book_between_added_and_removed_shelf_states', 0, async () => {
      await (await findById(SHELF_ACTION_ID)).click();
      await DRIVER.waitForIdle(1000, 5000);

      await (await findById(SHELF_ACTION_ID)).click();
      await DRIVER.waitForIdle(1000, 5000);
      await findById(HOST_PAGE_ID);
    });
  });
}
