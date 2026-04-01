import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const HOST_PAGE_ID = 'book_cover_card_host_page';
const SHELF_ACTION_ID = 'book_cover_card_shelf_action';
const DRIVER = Driver.create();

async function waitForBookCoverCardLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await DRIVER.waitForComponent(ON.id(HOST_PAGE_ID), 10000);
}

async function findByText(text: string, timeout: number = 5000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.text(text), timeout);
  if (component === null) {
    throw new Error(`Unable to find text: ${text}`);
  }
  return component;
}

async function findById(id: string, timeout: number = 5000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

export default function BookCoverCardTest() {
  describe('BookCoverCardTest', () => {
    beforeAll(async () => {
      await waitForBookCoverCardLoaded();
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_renders_book_details_and_reading_hint', 0, async () => {
      await findByText('阅读');
      await findByText('三体');
      await findByText('刘慈欣');
      await findByText('9.6');
      await findByText('分');
      await findByText('52.1');
      await findByText('万字');
      await findByText('88.8');
      await findByText('万');
      await findByText('人气');
      await findByText('华为出版社');
      await findByText('<< 向左滑开始阅读');
      await findById(SHELF_ACTION_ID);
    });
  });
}
