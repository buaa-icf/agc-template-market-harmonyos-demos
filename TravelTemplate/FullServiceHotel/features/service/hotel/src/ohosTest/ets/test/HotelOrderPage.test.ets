import { beforeAll, describe, expect, it } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const UI_TIMEOUT = 10000;

async function findById(driver: Driver, id: string): Promise<Component> {
  const component = await driver.waitForComponent(ON.id(id), UI_TIMEOUT);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

export default function HotelOrderPageTest() {
  describe('HotelOrderPageTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = Driver.create();
      await findById(driver, 'hotel_order_test_host_anchor');
      await findById(driver, 'hotel_order_guest_name_input');
      await findById(driver, 'hotel_order_guest_phone_input');
    });

    it('renders both guest input fields with the shared form style', 0, async () => {
      await findById(driver, 'hotel_order_guest_name_input');
      await findById(driver, 'hotel_order_guest_phone_input');
    });

    it('accepts guest phone information in the styled phone input', 0, async () => {
      const phoneInput = await findById(driver, 'hotel_order_guest_phone_input');
      await driver.inputText(await phoneInput.getBoundsCenter(), '13812345678');
    });
  });
}
