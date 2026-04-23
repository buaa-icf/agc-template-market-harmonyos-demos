import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const ABOUT_US_ROOT_ID: string = 'about_us_page_root';
const ABOUT_US_HOST_PAGE_ID: string = 'about_us_test_host_page';
const ABOUT_US_OPEN_BUTTON_ID: string = 'about_us_test_open_button';
const ABOUT_US_SUGGESTION_ROW_ID: string = 'about_us_suggestion_row';
const ABOUT_US_FEEDBACK_ROW_ID: string = 'about_us_feedback_row';
const ABOUT_US_SUGGESTION_TEXT_ID: string = 'about_us_suggestion_text';
const ABOUT_US_FEEDBACK_TEXT_ID: string = 'about_us_feedback_text';
const ABOUT_US_SUGGESTION_TARGET_ID: string = 'about_us_test_suggestion_target';
const ABOUT_US_FEEDBACK_TARGET_ID: string = 'about_us_test_feedback_target';

const DRIVER: Driver = Driver.create();

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

async function openAboutUsPage(): Promise<void> {
  await findById(ABOUT_US_HOST_PAGE_ID, 10000);
  await clickById(ABOUT_US_OPEN_BUTTON_ID, 10000);
  await findById(ABOUT_US_ROOT_ID, 10000);
}

export default function aboutUsPageTest() {
  describe('AboutUsPageTest', () => {
    beforeAll(async () => {
      await DRIVER.waitForIdle(1000, 10000);
      await openAboutUsPage();
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_renders_two_repeated_rows', 0, async () => {
      await findById(ABOUT_US_SUGGESTION_ROW_ID);
      await findById(ABOUT_US_SUGGESTION_TEXT_ID);
      await findById(ABOUT_US_FEEDBACK_ROW_ID);
      await findById(ABOUT_US_FEEDBACK_TEXT_ID);
    });

    it('click_suggestion_row_navigates_to_suggestion_page', 0, async () => {
      await clickById(ABOUT_US_SUGGESTION_ROW_ID);
      await findById(ABOUT_US_SUGGESTION_TARGET_ID, 10000);
    });

    it('click_feedback_row_navigates_to_feedback_page', 0, async () => {
      await DRIVER.pressBack();
      await DRIVER.waitForIdle(500, 5000);
      await findById(ABOUT_US_ROOT_ID, 10000);

      await clickById(ABOUT_US_FEEDBACK_ROW_ID);
      await findById(ABOUT_US_FEEDBACK_TARGET_ID, 10000);
    });
  });
}
