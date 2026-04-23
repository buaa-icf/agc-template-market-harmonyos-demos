import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';
import { display } from '@kit.ArkUI';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID = 'carouse_cut_tool_bar_test_host_anchor';
const RATIO_OUTPUT_ID = 'cut_ratio_output';
const CUT_COL_ID_PREFIX = 'cut_col_';

async function findById(id: string, timeout: number = 8000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function clickById(id: string, timeout: number = 8000): Promise<void> {
  const c = await findById(id, timeout);
  await c.click();
  await DRIVER.waitForIdle(500, 5000);
}

async function getTextById(id: string, timeout: number = 5000): Promise<string> {
  return await (await findById(id, timeout)).getText();
}

async function waitForRatioText(expectedPrefix: string, timeout: number = 5000): Promise<string> {
  const deadline = new Date().getTime() + timeout;
  let last: string = '';
  while (new Date().getTime() <= deadline) {
    last = await getTextById(RATIO_OUTPUT_ID, Math.min(timeout, 1000));
    if (last.indexOf(expectedPrefix) === 0) {
      return last;
    }
    await DRIVER.waitForIdle(200, 1000);
  }
  throw new Error(`Unexpected ratio text: expected prefix "${expectedPrefix}", got "${last}"`);
}

async function clickCutAndReadRatio(index: number): Promise<number> {
  await clickById(CUT_COL_ID_PREFIX + index);
  const text = await waitForRatioText('ratio:');
  return Number(text.substring('ratio:'.length));
}

export default function carouseCutToolBarTest() {
  describe('CarouseCutToolBarTest', () => {
    beforeAll(async () => {
      await DRIVER.waitForIdle(800, 10000);
      await findById(HOST_ANCHOR_ID, 12000);
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('get_crop_ratio_free_returns_0', 0, async () => {
      const ratio = await clickCutAndReadRatio(0);
      expect(ratio).assertEqual(0);
    });

    it('get_crop_ratio_wallpaper_returns_device_height_over_width', 0, async () => {
      const info = display.getDefaultDisplaySync();
      const expected = info.height / info.width;
      const ratio = await clickCutAndReadRatio(1);
      expect(Math.abs(ratio - expected) < 1e-6).assertTrue();
    });

    it('get_crop_ratio_9_16_returns_9_over_16', 0, async () => {
      const ratio = await clickCutAndReadRatio(2);
      expect(Math.abs(ratio - (16 / 9)) < 1e-6).assertTrue();
    });

    it('get_crop_ratio_16_9_returns_16_over_9', 0, async () => {
      const ratio = await clickCutAndReadRatio(3);
      expect(Math.abs(ratio - (9 / 16)) < 1e-6).assertTrue();
    });

    it('get_crop_ratio_1_1_returns_1', 0, async () => {
      const ratio = await clickCutAndReadRatio(4);
      expect(ratio).assertEqual(1);
    });

    it('get_crop_ratio_3_2_returns_2_over_3', 0, async () => {
      const ratio = await clickCutAndReadRatio(5);
      expect(Math.abs(ratio - (2 / 3)) < 1e-6).assertTrue();
    });

    it('get_crop_ratio_4_3_returns_3_over_4', 0, async () => {
      const ratio = await clickCutAndReadRatio(6);
      expect(Math.abs(ratio - (3 / 4)) < 1e-6).assertTrue();
    });
  });
}
