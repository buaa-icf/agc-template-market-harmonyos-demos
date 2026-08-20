import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const HOST_OPEN_BUTTON_ID = 'feedback_page_test_open';
const HOST_RECORD_COUNT_ID = 'feedback_page_test_record_count';
const FEEDBACK_PAGE_ROOT_ID = 'feedback_page_root';
const ISSUE_COUNT_ID = 'feedback_page_issue_count';
const ISSUE_INPUT_ID = 'feedback_page_issue_input';
const SCREENSHOT_COUNT_ID = 'feedback_page_screenshot_count';
const FIRST_SCREENSHOT_REMOVE_ID = 'feedback_page_screenshot_remove_0';
const PHONE_COUNT_ID = 'feedback_page_phone_count';
const PHONE_INPUT_ID = 'feedback_page_phone_input';
const SUBMIT_BUTTON_ID = 'feedback_page_submit';
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

async function findByIdOrNull(id: string, timeout: number = 1000): Promise<Component | null> {
  return await DRIVER.waitForComponent(ON.id(id), timeout);
}

async function findByTextOrNull(text: string, timeout: number = 1000): Promise<Component | null> {
  return await DRIVER.waitForComponent(ON.text(text), timeout);
}

async function clickById(id: string, timeout: number = 5000): Promise<void> {
  await (await findById(id, timeout)).click();
  await DRIVER.waitForIdle(500, 5000);
}

async function inputTextById(id: string, text: string, timeout: number = 5000): Promise<void> {
  const component = await findById(id, timeout);
  await component.click();
  await component.inputText(text);
  await DRIVER.waitForIdle(500, 5000);
}

async function getTextById(id: string, timeout: number = 5000): Promise<string> {
  return await (await findById(id, timeout)).getText();
}

async function assertTextVisible(text: string, timeout: number = 5000): Promise<void> {
  await findByText(text, timeout);
}

async function waitForTextValueById(id: string, expected: string, timeout: number = 5000): Promise<void> {
  const deadline = new Date().getTime() + timeout;
  while (new Date().getTime() <= deadline) {
    const component = await findByIdOrNull(id, Math.min(1000, timeout));
    if (component !== null && await component.getText() === expected) {
      return;
    }
    if (await findByTextOrNull(expected, Math.min(1000, timeout)) !== null) {
      return;
    }
    await DRIVER.waitForIdle(200, 1000);
  }
  throw new Error(`Unable to find ${id} with text ${expected}`);
}

async function waitForHostPageLoaded(): Promise<void> {
  // Compact recovery loop. Total worst case ~6s, well under hypium's 15s
  // beforeAll timeout. The first iteration usually wins because the previous
  // class's afterAll has already settled the screen.
  for (let attempt = 0; attempt < 4; attempt++) {
    await DRIVER.waitForIdle(300, 1500);
    const hostBtn = await DRIVER.waitForComponent(ON.id('feedback_page_test_open'), 1200);
    if (hostBtn !== null) {
      return;
    }
    await DRIVER.pressBack();
  }
  await findById('feedback_page_test_open', 3000);
}

async function waitForFeedbackPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(FEEDBACK_PAGE_ROOT_ID, 10000);
  await findById(ISSUE_INPUT_ID, 10000);
}

async function dismissKnownSystemDialog(): Promise<void> {
  const cancelButton = await findByTextOrNull('取消', 1000);
  if (cancelButton === null) {
    return;
  }

  const nextButton = await findByTextOrNull('下一步', 500);
  const dialogTitle = await findByTextOrNull('小艺对话', 500);
  if (nextButton === null && dialogTitle === null) {
    return;
  }

  await cancelButton.click();
  await DRIVER.waitForIdle(1000, 5000);
}

async function ensureHostPageLoaded(): Promise<void> {
  const deadline = new Date().getTime() + 15000;
  while (new Date().getTime() <= deadline) {
    await dismissKnownSystemDialog();

    const hostPage = await findByIdOrNull(HOST_OPEN_BUTTON_ID, 2000);
    if (hostPage !== null) {
      return;
    }

    const feedbackPage = await findByIdOrNull(FEEDBACK_PAGE_ROOT_ID, 1000);
    if (feedbackPage !== null) {
      await DRIVER.pressBack();
      await DRIVER.waitForIdle(1000, 5000);
    } else {
      await DRIVER.waitForIdle(1000, 2000);
    }
  }

  throw new Error('Unable to reach feedback test host page');
}
export default function FeedbackPageTest() {
  describe('FeedbackPageTest', () => {
    beforeAll(async () => {
      await waitForHostPageLoaded();
    });

    afterAll(async () => {
      // Keep afterAll short. Next class.s beforeAll has its own host-page recovery.
      await DRIVER.waitForIdle(500, 3000);
    });

    it('build_renders_feedback_form_and_updates_description_counter', 0, async () => {
      await ensureHostPageLoaded();
      await waitForTextValueById(HOST_RECORD_COUNT_ID, '0', 5000);
      await clickById(HOST_OPEN_BUTTON_ID);
      await waitForFeedbackPageLoaded();

      await assertTextVisible('意见反馈');
      await assertTextVisible('问题描述');
      await assertTextVisible('问题截图（选填）');
      await assertTextVisible('联系方式（选填）');
      await findById(SUBMIT_BUTTON_ID, 5000);
      await clickById(FIRST_SCREENSHOT_REMOVE_ID);
      await waitForTextValueById(ISSUE_COUNT_ID, '0/100', 5000);
      await waitForTextValueById(SCREENSHOT_COUNT_ID, '0/4', 5000);
      await waitForTextValueById(PHONE_COUNT_ID, '0/11', 5000);

      await clickById(SUBMIT_BUTTON_ID);
      await findById(HOST_OPEN_BUTTON_ID, 10000);

      await clickById(HOST_OPEN_BUTTON_ID);
      await waitForFeedbackPageLoaded();
      await clickById(SUBMIT_BUTTON_ID);
      await findById(HOST_OPEN_BUTTON_ID, 10000);
    }, 60000);
  });
}
