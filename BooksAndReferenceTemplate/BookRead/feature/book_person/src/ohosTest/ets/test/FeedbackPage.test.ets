import { afterAll, beforeAll, describe, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const driver: Driver = Driver.create();
const HOST_ID: string = 'feedback_page_test_open';
const ROOT_ID: string = 'feedback_page_root';
const ISSUE_ID: string = 'feedback_page_issue_input';
const PHONE_ID: string = 'feedback_page_phone_input';
const REMOVE_ID: string = 'feedback_page_screenshot_remove_0';
const SUBMIT_ID: string = 'feedback_page_submit';

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
  for (let attempt: number = 0; attempt < 5; attempt++) {
    const host: Component = await driver.waitForComponent(ON.id(HOST_ID), 1200);
    if (host !== null) return;
    await driver.pressBack();
    await driver.waitForIdle(300, 1500);
  }
  await findById(HOST_ID);
}

export default function FeedbackPageTest(): void {
  describe('FeedbackPageTest', () => {
    beforeAll(async () => { await returnToHost(); });
    afterAll(async () => { await driver.waitForIdle(500, 3000); });

    it('renders_and_submits_the_complete_feedback_form', 0, async () => {
      await click(HOST_ID);
      await findById(ROOT_ID);
      await findById(ISSUE_ID);
      await findById(PHONE_ID);
      await click(REMOVE_ID);
      await click(SUBMIT_ID);
      await findById(HOST_ID);

      // The host alternates between three and four seeded screenshots. Opening
      // the page a second time exercises the full-capacity branch where the
      // add-screenshot row is intentionally not rendered.
      await click(HOST_ID);
      await findById(ROOT_ID);
      await findById(ISSUE_ID);
      await findById(PHONE_ID);
      await click(SUBMIT_ID);
      await findById(HOST_ID);
    }, 60000);
  });
}
