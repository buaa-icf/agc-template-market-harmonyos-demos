import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const HOST_ABOUT_PAGE_BUTTON_ID = 'about_page_test_open';
const ABOUT_PAGE_ROOT_ID = 'about_page_root';
const ABOUT_PAGE_CONTACT_SERVICE_ROW_ID = 'about_page_contact_service_row';
const ABOUT_PAGE_PHONE_SHEET_ID = 'about_page_phone_sheet';
const ABOUT_PAGE_CALL_BUTTON_ID = 'about_page_make_call_button';
const ABOUT_PAGE_CANCEL_BUTTON_ID = 'about_page_cancel_call_button';
const DRIVER = Driver.create();

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

async function assertTextVisible(text: string, timeout: number = 5000): Promise<void> {
  await findByText(text, timeout);
}

async function assertIdMissing(id: string, timeout: number = 1500): Promise<void> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component !== null) {
    throw new Error(`Expected id to disappear: ${id}`);
  }
}

async function waitForHostPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(HOST_ABOUT_PAGE_BUTTON_ID, 10000);
}

async function waitForAboutPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(ABOUT_PAGE_ROOT_ID, 10000);
}

async function waitForPhoneSheetLoaded(): Promise<void> {
  await DRIVER.waitForIdle(500, 5000);
  await findById(ABOUT_PAGE_PHONE_SHEET_ID, 10000);
}

export default function AboutPageTest() {
  describe('AboutPageTest', () => {
    beforeAll(async () => {
      await waitForHostPageLoaded();
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_renders_about_content_and_contact_sheet', 0, async () => {
      await clickById(HOST_ABOUT_PAGE_BUTTON_ID);
      await waitForAboutPageLoaded();

      await assertTextVisible('关于');
      await assertTextVisible('阅读');
      await assertTextVisible('业务描述');
      await assertTextVisible('版本信息');
      await assertTextVisible('1.0.23.300');
      await assertTextVisible('检查更新');
      await assertTextVisible('客服电话');
      await assertTextVisible('000000');

      await clickById(ABOUT_PAGE_CONTACT_SERVICE_ROW_ID);
      await waitForPhoneSheetLoaded();
      await findById(ABOUT_PAGE_CALL_BUTTON_ID);
      await assertTextVisible('一键拨号');

      await clickById(ABOUT_PAGE_CANCEL_BUTTON_ID);
      await assertIdMissing(ABOUT_PAGE_PHONE_SHEET_ID, 2000);
      await waitForAboutPageLoaded();
    });
  });
}
