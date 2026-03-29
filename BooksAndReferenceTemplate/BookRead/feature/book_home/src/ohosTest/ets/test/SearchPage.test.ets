import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const BACK_BUTTON_ID = 'search_page_back';
const HISTORY_ITEM_ID = 'search_page_history_0';
const RESULT_SUGGESTION_ID = 'search_page_suggestion_11';
const RESULT_HOST_BUTTON_ID = 'search_test_host_open_result';
const EMPTY_HOST_BUTTON_ID = 'search_test_host_open_empty';
const DRIVER = Driver.create();

async function waitForSearchPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await DRIVER.waitForComponent(ON.text('历史搜索'), 10000);
}

async function waitForHostPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(500, 5000);
  await DRIVER.waitForComponent(ON.id(RESULT_HOST_BUTTON_ID), 10000);
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

async function clickById(id: string, timeout: number = 5000): Promise<void> {
  await (await findById(id, timeout)).click();
  await DRIVER.waitForIdle(500, 5000);
}

export default function SearchPageTest() {
  describe('SearchPageTest', () => {
    beforeAll(async () => {
      await waitForSearchPageLoaded();
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_switches_between_initial_result_and_empty_states', 0, async () => {
      await findByText('历史搜索');
      await findByText('热门搜索');
      await findByText('热搜榜');

      await clickById(BACK_BUTTON_ID);
      await waitForHostPageLoaded();

      await clickById(RESULT_HOST_BUTTON_ID);
      await waitForSearchPageLoaded();
      await clickById(HISTORY_ITEM_ID);
      await clickById(RESULT_SUGGESTION_ID, 10000);
      await findByText('搜索结果');
      await findByText('诛仙');

      await clickById(BACK_BUTTON_ID);
      await waitForHostPageLoaded();

      await clickById(EMPTY_HOST_BUTTON_ID);
      await waitForSearchPageLoaded();
      await clickById(HISTORY_ITEM_ID);
      await findByText('暂无搜索结果', 10000);
    });
  });
}
