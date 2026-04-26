import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID = 'home_page_instrument_host_anchor';
const AUTH_MOUNT_ID = 'authentication_page_mount';

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

async function findByText(text: string, timeout: number = 8000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.text(text), timeout);
  if (component === null) {
    throw new Error(`Unable to find text: ${text}`);
  }
  return component;
}

async function ensureTextNotVisible(text: string): Promise<void> {
  const component = await DRIVER.findComponent(ON.text(text));
  if (component !== null) {
    throw new Error(`Unexpected text found: ${text}`);
  }
}

export default function authenticationPageInstrumentTest() {
  describe('AuthenticationPageInstrumentTest', () => {
    beforeAll(async () => {
      await waitForIdle();
      await findById(HOST_ANCHOR_ID, 12000);
    });

    afterAll(async () => {
      await waitForIdle();
    });

    it('authentication_page_should_render_with_stable_ids', 0, async () => {
      await findById(AUTH_MOUNT_ID);
      await findByText('华为账号用户认证协议');
    });

    it('instrument_host_should_not_fall_back_to_hello_world_page', 0, async () => {
      await ensureTextNotVisible('Hello World');
      await ensureTextNotVisible('Hello world');
    });
  });
}
