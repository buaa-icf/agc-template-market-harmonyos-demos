import { afterAll, beforeAll, describe, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const driver: Driver = Driver.create();
const HOST_ID: string = 'about_page_test_open';
const ROOT_ID: string = 'about_page_root';
const CONTACT_ID: string = 'about_page_contact_service_row';
const SHEET_ID: string = 'about_page_phone_sheet';
const CALL_ID: string = 'about_page_make_call_button';
const CANCEL_ID: string = 'about_page_cancel_call_button';

async function findById(id: string, timeout: number = 10000): Promise<Component> {
  const component: Component = await driver.waitForComponent(ON.id(id), timeout);
  if (component === null) throw new Error(`Unable to find id: ${id}`);
  return component;
}

async function click(id: string): Promise<void> {
  await (await findById(id)).click();
  await driver.waitForIdle(500, 5000);
}

async function returnToHost(): Promise<void> {
  for (let attempt: number = 0; attempt < 4; attempt++) {
    const host: Component = await driver.waitForComponent(ON.id(HOST_ID), 1200);
    if (host !== null) return;
    await driver.pressBack();
    await driver.waitForIdle(300, 1500);
  }
  await findById(HOST_ID);
}

export default function AboutPageTest(): void {
  describe('AboutPageTest', () => {
    beforeAll(async () => { await returnToHost(); });
    afterAll(async () => { await driver.waitForIdle(500, 3000); });

    it('renders_the_complete_about_card_and_phone_sheet', 0, async () => {
      await click(HOST_ID);
      await findById(ROOT_ID);
      await findById(CONTACT_ID);
      await click(CONTACT_ID);
      await findById(SHEET_ID);
      await findById(CALL_ID);
      await click(CANCEL_ID);
      await findById(ROOT_ID);
    }, 60000);
  });
}
