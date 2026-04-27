import { describe, it, beforeAll, expect } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const DRIVER: Driver = Driver.create();

async function waitForById(id: string, timeoutMs: number = 8000): Promise<Component> {
  const component: Component | null = await DRIVER.waitForComponent(ON.id(id), timeoutMs);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

export default function activityBookingTest() {
  describe('ActivityBookingUiTest', () => {
    beforeAll(async () => {
      await DRIVER.waitForIdle(1000, 10000);
      await waitForById('activity_booking_test_host', 12000);
      await DRIVER.delayMs(800);
    });

    it('testActivityBookingDuplicatedInputSections', 0, async () => {
      await waitForById('activity_booking_title');
      await waitForById('activity_booking_name_label');
      await waitForById('activity_booking_phone_label');

      const nameInput = await waitForById('activity_booking_name_input');
      const phoneInput = await waitForById('activity_booking_phone_input');
      await nameInput.inputText('UI_TEST_NAME');
      await phoneInput.inputText('13800000000');
      await DRIVER.delayMs(500);

      const nameText: string = await nameInput.getText();
      expect(nameText.indexOf('UI_TEST_NAME') >= 0).assertTrue();

      const phoneText: string = await phoneInput.getText();
      expect(phoneText.indexOf('13800000000') >= 0).assertTrue();
    });

  });
}
