import { beforeAll, describe, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const UI_TIMEOUT = 10000;

async function findById(driver: Driver, id: string): Promise<Component> {
  const component = await driver.waitForComponent(ON.id(id), UI_TIMEOUT);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function clickById(driver: Driver, id: string): Promise<void> {
  await (await findById(driver, id)).click();
  await driver.delayMs(800);
}

export default function FeedListPageTest() {
  describe('FeedListPageTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = Driver.create();
      await findById(driver, 'feed_test_host_anchor');
      await findById(driver, 'feed_like_active');
    });

    it('marks the current user as liking a feed when the like list contains the user', 0, async () => {
      await clickById(driver, 'feed_show_liked');
      await findById(driver, 'feed_like_active');
    });

    it('marks the feed inactive when the current user is absent from likes', 0, async () => {
      await clickById(driver, 'feed_show_unliked');
      await findById(driver, 'feed_like_inactive');
    });

    it('renders the basic feed branch without interaction or user information', 0, async () => {
      await clickById(driver, 'feed_show_hidden_interaction');
      await findById(driver, 'feed_basic_scenario_anchor');
    });

    it('handles feeds whose like and comment collections are unset', 0, async () => {
      await clickById(driver, 'feed_show_empty_collections');
      await findById(driver, 'feed_empty_collections_anchor');
    });
  });
}
