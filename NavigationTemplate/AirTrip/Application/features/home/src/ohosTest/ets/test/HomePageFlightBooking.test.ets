import { describe, beforeAll, beforeEach, it, expect } from '@ohos/hypium';
import { Driver, ON, MatchPattern, Component } from '@kit.TestKit';

const FIND_TIMEOUT_MS: number = 10_000;
const IDLE_MS: number = 500;

async function waitForIdle(driver: Driver, durationMs: number = IDLE_MS): Promise<void> {
  await driver.delayMs(durationMs);
}

async function waitById(driver: Driver, id: string): Promise<Component> {
  const component = await driver.waitForComponent(ON.id(id), FIND_TIMEOUT_MS);
  if (!component) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function clickById(driver: Driver, id: string): Promise<void> {
  const component = await waitById(driver, id);
  await component.click();
  await waitForIdle(driver);
}

async function findByText(driver: Driver, text: string): Promise<Component> {
  const component = await driver.waitForComponent(ON.text(text, MatchPattern.EQUALS), FIND_TIMEOUT_MS);
  if (!component) {
    throw new Error(`Unable to find text: ${text}`);
  }
  return component;
}

async function assertTextVisible(driver: Driver, text: string): Promise<void> {
  const component = await findByText(driver, text);
  expect(component !== null).assertTrue();
}

export default function homePageFlightBookingTest() {
  describe('HomePageFlightBookingTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = Driver.create();
      await waitForIdle(driver, 2500);
      await waitById(driver, 'home_test_host_anchor');
      await waitById(driver, 'home_page_title');
    });

    beforeEach(async () => {
      await waitForIdle(driver);
    });

    it('should render duplicated city blocks and book button', 0, async () => {
      await waitById(driver, 'home_flight_booking_card');
      await waitById(driver, 'home_flight_departure_selector');
      await waitById(driver, 'home_flight_departure_value');
      await waitById(driver, 'home_flight_destination_selector');
      await waitById(driver, 'home_flight_destination_value');
      await waitById(driver, 'home_flight_transfer_button');
      await waitById(driver, 'home_flight_date_selector');
      await waitById(driver, 'home_flight_book_button');
    });

    it('should swap departure and destination after tapping transfer', 0, async () => {
      const departureBefore = await (await waitById(driver, 'home_flight_departure_value')).getText();
      const destinationBefore = await (await waitById(driver, 'home_flight_destination_value')).getText();

      await clickById(driver, 'home_flight_transfer_button');

      const departureAfter = await (await waitById(driver, 'home_flight_departure_value')).getText();
      const destinationAfter = await (await waitById(driver, 'home_flight_destination_value')).getText();

      expect(departureAfter).assertEqual(destinationBefore);
      expect(destinationAfter).assertEqual(departureBefore);
    });

    it('should open and close account-binding dialog when booking', 0, async () => {
      await clickById(driver, 'home_flight_book_button');

      await assertTextVisible(driver, '纭畾');
      await assertTextVisible(driver, '鍙栨秷');

      const cancelButton = await findByText(driver, '鍙栨秷');
      await cancelButton.click();
      await waitForIdle(driver, 800);
    });
  });
}
