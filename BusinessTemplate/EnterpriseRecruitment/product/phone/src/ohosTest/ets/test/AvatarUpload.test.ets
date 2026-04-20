import { describe, beforeAll, afterEach, it, expect } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID = 'crop_test_host_anchor';
const CROP_AREA_ID = 'crop_test_crop_area';
const SCALE_ID = 'crop_model_scale';
const OFFSET_X_ID = 'crop_model_offsetX';
const OFFSET_Y_ID = 'crop_model_offsetY';

async function findById(id: string, timeout: number = 5000): Promise<Component> {
  const comp = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (comp === null) {
    throw new Error(`Component not found: ${id}`);
  }
  return comp;
}

async function clickById(id: string): Promise<void> {
  const comp = await findById(id);
  await comp.click();
  await DRIVER.waitForIdle(300, 3000);
}

async function textOf(id: string): Promise<string> {
  const comp = await findById(id);
  return await comp.getText();
}

async function waitForText(id: string, expected: string, timeout: number = 5000): Promise<void> {
  const deadline = new Date().getTime() + timeout;
  while (new Date().getTime() <= deadline) {
    try {
      const actual = await textOf(id);
      if (actual === expected) {
        return;
      }
    } catch (_) {
    }
    await DRIVER.waitForIdle(100, 1000);
  }
  const actual = await textOf(id);
  throw new Error(`Text mismatch on ${id}: expected ${expected}, got ${actual}`);
}

/**
 * 在 CropView 区域进行一次短距离水平 swipe。
 * Scenario 预置时已设置 panEnabled=false / zoomEnabled=false，
 * 因此 PanGesture.onActionUpdate 不会修改 model.offsetX/offsetY，
 * 只会由 onActionEnd 触发 CropView.checkImageAdapt。
 */
async function triggerCheckImageAdapt(): Promise<void> {
  const area = await findById(CROP_AREA_ID);
  const center = await area.getBoundsCenter();
  const y = center.y - 120;
  await DRIVER.swipe(center.x - 40, y, center.x + 40, y, 600);
  await DRIVER.waitForIdle(500, 5000);
}

export default function CropCheckImageAdaptTest() {
  describe('CropCheckImageAdaptTest', () => {
    beforeAll(async () => {
      await DRIVER.waitForIdle(1000, 10000);
      await findById(HOST_ANCHOR_ID, 10000);
    });

    afterEach(async () => {
      await DRIVER.waitForIdle(200, 2000);
    });

    it('S1_image_exactly_fills_frame_keeps_identity_state', 0, async () => {
      await clickById('btn_s1');
      await waitForText(SCALE_ID, '1');
      await waitForText(OFFSET_X_ID, '0');
      await waitForText(OFFSET_Y_ID, '0');

      await triggerCheckImageAdapt();

      expect(await textOf(SCALE_ID)).assertEqual('1');
      expect(await textOf(OFFSET_X_ID)).assertEqual('0');
      expect(await textOf(OFFSET_Y_ID)).assertEqual('0');
    });

    it('S2_pan_right_out_of_bounds_clamps_offsetX_to_right_edge', 0, async () => {
      await clickById('btn_s2');
      await waitForText(OFFSET_X_ID, '500');

      await triggerCheckImageAdapt();

      expect(await textOf(SCALE_ID)).assertEqual('1');
      expect(await textOf(OFFSET_X_ID)).assertEqual('250');
      expect(await textOf(OFFSET_Y_ID)).assertEqual('0');
    });

    it('S3_pan_left_out_of_bounds_clamps_offsetX_to_left_edge', 0, async () => {
      await clickById('btn_s3');
      await waitForText(OFFSET_X_ID, '-500');

      await triggerCheckImageAdapt();

      expect(await textOf(SCALE_ID)).assertEqual('1');
      expect(await textOf(OFFSET_X_ID)).assertEqual('-250');
      expect(await textOf(OFFSET_Y_ID)).assertEqual('0');
    });

    it('S4_pan_down_out_of_bounds_clamps_offsetY_to_bottom_edge', 0, async () => {
      await clickById('btn_s4');
      await waitForText(OFFSET_Y_ID, '500');

      await triggerCheckImageAdapt();

      expect(await textOf(SCALE_ID)).assertEqual('1');
      expect(await textOf(OFFSET_X_ID)).assertEqual('0');
      expect(await textOf(OFFSET_Y_ID)).assertEqual('250');
    });

    it('S5_pan_up_out_of_bounds_clamps_offsetY_to_top_edge', 0, async () => {
      await clickById('btn_s5');
      await waitForText(OFFSET_Y_ID, '-500');

      await triggerCheckImageAdapt();

      expect(await textOf(SCALE_ID)).assertEqual('1');
      expect(await textOf(OFFSET_X_ID)).assertEqual('0');
      expect(await textOf(OFFSET_Y_ID)).assertEqual('-250');
    });

    it('S6_image_smaller_than_frame_auto_scales_up_and_repositions', 0, async () => {
      await clickById('btn_s6');
      await waitForText(SCALE_ID, '0.25');

      await triggerCheckImageAdapt();

      expect(await textOf(SCALE_ID)).assertEqual('0.5');
      expect(await textOf(OFFSET_X_ID)).assertEqual('-500');
      expect(await textOf(OFFSET_Y_ID)).assertEqual('-500');
    });

    it('S7_non_square_frame_with_exact_fill_keeps_identity_state', 0, async () => {
      await clickById('btn_s7');
      await waitForText(SCALE_ID, '1');
      await waitForText(OFFSET_X_ID, '0');
      await waitForText(OFFSET_Y_ID, '0');

      await triggerCheckImageAdapt();

      expect(await textOf(SCALE_ID)).assertEqual('1');
      expect(await textOf(OFFSET_X_ID)).assertEqual('0');
      expect(await textOf(OFFSET_Y_ID)).assertEqual('0');
    });

    it('S8_wide_image_with_down_offset_reclamps_offsetY_only', 0, async () => {
      await clickById('btn_s8');
      await waitForText(OFFSET_Y_ID, '100');

      await triggerCheckImageAdapt();

      expect(await textOf(SCALE_ID)).assertEqual('1');
      expect(await textOf(OFFSET_X_ID)).assertEqual('0');
      expect(await textOf(OFFSET_Y_ID)).assertEqual('0');
    });
  });
}
