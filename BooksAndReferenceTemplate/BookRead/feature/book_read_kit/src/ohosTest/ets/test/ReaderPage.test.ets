import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const OPEN_READER_ID = 'open_reader_page_test';
const READER_HOST_ID = 'reader_page_test_host';
const READER_RESULT_ID = 'reader_page_preprocess_result';
const DRIVER = Driver.create();

async function findById(id: string, timeout: number = 10000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

export default function ReaderPageTest() {
  describe('ReaderPageTest', () => {
    beforeAll(async () => {
      await DRIVER.waitForIdle(500, 10000);
      const openButton = await findById(OPEN_READER_ID);
      await openButton.click();
      await DRIVER.waitForIdle(1000, 10000);
      await findById(READER_HOST_ID);
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('preprocess_initializes_paid_book_and_handles_page_show', 0, async () => {
      const result = await findById(READER_RESULT_ID);
      expect(await result.getText()).assertEqual('5:3:false:90');
    });
  });
}
