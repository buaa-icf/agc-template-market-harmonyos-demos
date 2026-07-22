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

export default function FeedListPageTest() {
  describe('FeedListPageTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = Driver.create();
      await findById(driver, 'feed_test_host_anchor');
      await findById(driver, 'feed_like_active');
    });

    it('marks the current user as liking a feed when the like list contains the user', 0, async () => {
      await findById(driver, 'feed_like_active');
    });
  });
}
