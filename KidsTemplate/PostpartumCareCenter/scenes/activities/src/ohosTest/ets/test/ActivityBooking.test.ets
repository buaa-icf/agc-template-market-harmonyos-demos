import { describe, it, beforeAll } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

async function waitForById(driver: Driver, id: string, timeoutMs: number = 6000): Promise<Component> {
  const component: Component | null = await driver.waitForComponent(ON.id(id), timeoutMs);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

export default function activityBookingTest() {
  describe('ActivityBookingUiTest', () => {
    let driver: Driver = Driver.create();

    beforeAll(async () => {
      await waitForById(driver, 'activity_booking_test_host', 12000);
      await driver.delayMs(1000);
    });

    it('testActivityBookingDuplicatedInputSections', 0, async () => {
      await waitForById(driver, 'activity_booking_title');
      await waitForById(driver, 'activity_booking_name_label');
      await waitForById(driver, 'activity_booking_phone_label');

      const nameInput = await waitForById(driver, 'activity_booking_name_input');
      const phoneInput = await waitForById(driver, 'activity_booking_phone_input');
      await nameInput.inputText('UI_TEST_NAME');
      await phoneInput.inputText('13800000000');
      await driver.delayMs(500);

      const nameText: string = await nameInput.getText();
      if (nameText === null || nameText.indexOf('UI_TEST_NAME') < 0) {
        throw new Error('Name input text was not updated as expected.');
      }

      const phoneText: string = await phoneInput.getText();
      if (phoneText === null || phoneText.indexOf('13800000000') < 0) {
        throw new Error('Phone input text was not updated as expected.');
      }
    });
  });
}

