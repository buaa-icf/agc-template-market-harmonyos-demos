import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID = 'tui_swiper_test_host_anchor';
const FLAT_WRAPPER_ID = 'tui_swiper_wrapper_flat';
const COVERED_WRAPPER_ID = 'tui_swiper_wrapper_covered';
const OVERSIZE_WRAPPER_ID = 'tui_swiper_wrapper_oversize';

interface Bounds {
  left: number;
  top: number;
  right: number;
  bottom: number;
}

async function findById(id: string, timeout: number = 8000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function getBounds(id: string): Promise<Bounds> {
  const comp = await findById(id);
  return await comp.getBounds() as Bounds;
}

export default function tuiSwiperTest() {
  describe('TUISwiperTest', () => {
    beforeAll(async () => {
      await DRIVER.waitForIdle(1000, 10000);
      await findById(HOST_ANCHOR_ID, 12000);
      await DRIVER.waitForIdle(500, 5000);
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('initDataByIsCovered_flat_mode_renders_swiper_with_positive_height', 0, async () => {
      const bounds: Bounds = await getBounds(FLAT_WRAPPER_ID);
      const height: number = bounds.bottom - bounds.top;
      const width: number = bounds.right - bounds.left;
      expect(width > 0).assertTrue();
      expect(height > 0).assertTrue();
    });

    it('initDataByIsCovered_covered_mode_renders_swiper_with_positive_height', 0, async () => {
      const bounds: Bounds = await getBounds(COVERED_WRAPPER_ID);
      const height: number = bounds.bottom - bounds.top;
      const width: number = bounds.right - bounds.left;
      expect(width > 0).assertTrue();
      expect(height > 0).assertTrue();
    });

    it('initDataByIsCovered_oversized_dimensions_are_clamped_without_crash', 0, async () => {
      const bounds: Bounds = await getBounds(OVERSIZE_WRAPPER_ID);
      const height: number = bounds.bottom - bounds.top;
      const width: number = bounds.right - bounds.left;
      expect(width > 0).assertTrue();
      expect(height > 0).assertTrue();
      const flatBounds: Bounds = await getBounds(FLAT_WRAPPER_ID);
      const flatHeight: number = flatBounds.bottom - flatBounds.top;
      expect(height >= flatHeight).assertTrue();
    });
  });
}
