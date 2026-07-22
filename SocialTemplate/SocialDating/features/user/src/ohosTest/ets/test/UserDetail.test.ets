import { beforeAll, describe, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const HOST_ANCHOR_ID = 'user_detail_test_host_anchor';
const USER_DETAIL_SCROLL_ID = 'user_detail_scroll';
const UI_TIMEOUT = 10000;

async function findById(driver: Driver, id: string): Promise<Component> {
  const component = await driver.waitForComponent(ON.id(id), UI_TIMEOUT);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

export default function UserDetailTest() {
  describe('UserDetailTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = Driver.create();
      await findById(driver, HOST_ANCHOR_ID);
      await findById(driver, USER_DETAIL_SCROLL_ID);
    });

    it('mounts the user detail page instead of the generated default page', 0, async () => {
      await findById(driver, USER_DETAIL_SCROLL_ID);
    });
  });
}
