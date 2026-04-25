import { describe, beforeAll, beforeEach, afterAll, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID: string = 'mine_page_collection_instrument_host_anchor';
const SHOW_AUTHENTICATION_PAGE_TRIGGER_ID: string = 'authentication_show_page_trigger';
const AUTHENTICATION_HOST_READY_MARKER_ID: string = 'authentication_host_ready_marker';
const AUTHENTICATION_PAGE_ROOT_ID: string = 'authentication_page_root';
const AUTHENTICATION_PAGE_TITLE_ID: string = 'authentication_page_title';
const AUTHENTICATION_PAGE_CONTENT_ID: string = 'authentication_page_content';

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

async function showAuthenticationPage(): Promise<void> {
  await waitForIdle();
  await findById(HOST_ANCHOR_ID, 12000);

  const showAuthentication = await findById(SHOW_AUTHENTICATION_PAGE_TRIGGER_ID, 12000);
  await showAuthentication.click();
  await waitForIdle();

  await findById(AUTHENTICATION_HOST_READY_MARKER_ID, 12000);
  await findById(AUTHENTICATION_PAGE_ROOT_ID, 12000);
}

export default function authenticationPageInstrumentTest() {
  describe('AuthenticationPageInstrumentTest', () => {
    beforeAll(async () => {
      await waitForIdle();
      await findById(HOST_ANCHOR_ID, 12000);
    });

    beforeEach(async () => {
      await showAuthenticationPage();
    });

    afterAll(async () => {
      await waitForIdle();
    });

    it('authentication_page_build_should_render_protocol_content', 0, async () => {
      await findById(AUTHENTICATION_PAGE_ROOT_ID);
      await findById(AUTHENTICATION_PAGE_TITLE_ID);
      await findById(AUTHENTICATION_PAGE_CONTENT_ID);
    });

    it('instrument_host_should_not_fall_back_to_hello_world_page', 0, async () => {
      await ensureTextNotVisible('Hello World');
      await ensureTextNotVisible('Hello world');
    });
  });
}
