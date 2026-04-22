import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID = 'picture_beautification_test_host_anchor';
const IMAGE_CONTENT_ID = 'ImageContent';
const CROP_CANVAS_ID = 'CropCanvas';

async function findById(id: string, timeout: number = 5000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

interface Rect {
  left: number;
  top: number;
  right: number;
  bottom: number;
}

async function getBoundsById(id: string): Promise<Rect> {
  const comp = await findById(id);
  const bounds = await comp.getBounds();
  return {
    left: bounds.left as number,
    top: bounds.top as number,
    right: bounds.right as number,
    bottom: bounds.bottom as number
  };
}

async function swipeWithin(rect: Rect, fromRatioX: number, fromRatioY: number,
  toOffsetX: number, toOffsetY: number): Promise<void> {
  const sx = Math.max(0, Math.round(rect.left + (rect.right - rect.left) * fromRatioX));
  const sy = Math.max(0, Math.round(rect.top + (rect.bottom - rect.top) * fromRatioY));
  const ex = Math.max(0, Math.round(sx + toOffsetX));
  const ey = Math.max(0, Math.round(sy + toOffsetY));
  await DRIVER.swipe(sx, sy, ex, ey, 600);
  await DRIVER.waitForIdle(500, 5000);
}

function boundsChanged(a: Rect, b: Rect): boolean {
  return a.left !== b.left || a.top !== b.top || a.right !== b.right || a.bottom !== b.bottom;
}

export default function PictureBeautificationTest() {
  describe('PictureBeautificationTest', () => {
    beforeAll(async () => {
      AppStorage.setOrCreate('pictureBeautification.runTest', true);
      await DRIVER.waitForIdle(500, 5000);
      await findById(HOST_ANCHOR_ID, 8000);
      await findById(CROP_CANVAS_ID, 8000);
    });

    afterAll(async () => {
      AppStorage.setOrCreate('pictureBeautification.runTest', false);
      await DRIVER.waitForIdle(500, 5000);
    });

    it('moveClipCanvasFreeType_move_branch_updates_clip_rect', 0, async () => {
      const before = await getBoundsById(CROP_CANVAS_ID);
      await swipeWithin(before, 0.5, 0.5, -40, -40);
      const after = await getBoundsById(CROP_CANVAS_ID);
      expect(boundsChanged(before, after)).assertTrue();
    });

    it('moveClipCanvasFreeType_topLeft_branch_resizes_clip_rect', 0, async () => {
      const before = await getBoundsById(CROP_CANVAS_ID);
      await swipeWithin(before, 0.02, 0.02, 30, 30);
      const after = await getBoundsById(CROP_CANVAS_ID);
      expect(boundsChanged(before, after)).assertTrue();
    });

    it('moveClipCanvasFreeType_topRight_branch_resizes_clip_rect', 0, async () => {
      const before = await getBoundsById(CROP_CANVAS_ID);
      await swipeWithin(before, 0.98, 0.02, -30, 30);
      const after = await getBoundsById(CROP_CANVAS_ID);
      expect(boundsChanged(before, after)).assertTrue();
    });

    it('moveClipCanvasFreeType_bottomLeft_branch_resizes_clip_rect', 0, async () => {
      const before = await getBoundsById(CROP_CANVAS_ID);
      await swipeWithin(before, 0.02, 0.98, 30, -30);
      const after = await getBoundsById(CROP_CANVAS_ID);
      expect(boundsChanged(before, after)).assertTrue();
    });

    it('moveClipCanvasFreeType_bottomRight_branch_resizes_clip_rect', 0, async () => {
      const before = await getBoundsById(CROP_CANVAS_ID);
      await swipeWithin(before, 0.98, 0.98, -30, -30);
      const after = await getBoundsById(CROP_CANVAS_ID);
      expect(boundsChanged(before, after)).assertTrue();
    });

    it('moveClipCanvasFreeType_top_edge_branch_resizes_clip_rect', 0, async () => {
      const before = await getBoundsById(CROP_CANVAS_ID);
      await swipeWithin(before, 0.5, 0.02, 0, 30);
      const after = await getBoundsById(CROP_CANVAS_ID);
      expect(boundsChanged(before, after)).assertTrue();
    });

    it('moveClipCanvasFreeType_bottom_edge_branch_resizes_clip_rect', 0, async () => {
      const before = await getBoundsById(CROP_CANVAS_ID);
      await swipeWithin(before, 0.5, 0.98, 0, -30);
      const after = await getBoundsById(CROP_CANVAS_ID);
      expect(boundsChanged(before, after)).assertTrue();
    });

    it('moveClipCanvasFreeType_left_edge_branch_resizes_clip_rect', 0, async () => {
      const before = await getBoundsById(CROP_CANVAS_ID);
      await swipeWithin(before, 0.02, 0.5, 30, 0);
      const after = await getBoundsById(CROP_CANVAS_ID);
      expect(boundsChanged(before, after)).assertTrue();
    });

    it('moveClipCanvasFreeType_right_edge_branch_resizes_clip_rect', 0, async () => {
      const before = await getBoundsById(CROP_CANVAS_ID);
      await swipeWithin(before, 0.98, 0.5, -30, 0);
      const after = await getBoundsById(CROP_CANVAS_ID);
      expect(boundsChanged(before, after)).assertTrue();
    });

    it('moveClipCanvasFreeType_move_clamps_to_image_area', 0, async () => {
      const image = await getBoundsById(IMAGE_CONTENT_ID);
      const tolerance = Math.max(20, Math.round((image.right - image.left) * 0.1));

      const before = await getBoundsById(CROP_CANVAS_ID);
      await swipeWithin(before, 0.5, 0.5, -800, -800);
      const afterMin = await getBoundsById(CROP_CANVAS_ID);
      expect(afterMin.left >= image.left - tolerance).assertTrue();
      expect(afterMin.top >= image.top - tolerance).assertTrue();

      await swipeWithin(afterMin, 0.5, 0.5, 800, 800);
      const afterMax = await getBoundsById(CROP_CANVAS_ID);
      expect(afterMax.right <= image.right + tolerance).assertTrue();
      expect(afterMax.bottom <= image.bottom + tolerance).assertTrue();
    });
  });
}
