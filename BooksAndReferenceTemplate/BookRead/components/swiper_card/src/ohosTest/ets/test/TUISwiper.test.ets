import { describe, beforeAll, afterEach, it, expect } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID = 'tui_swiper_test_host_anchor';
const MODE_LABEL_ID = 'tui_swiper_mode';
const AREA_HEIGHT_ID = 'tui_swiper_area_height';
const MOUNT_FLAT_ID = 'tui_swiper_mount_flat';
const MOUNT_COVERED_ID = 'tui_swiper_mount_covered';
const MOUNT_OVERSIZE_ID = 'tui_swiper_mount_oversize';
const UNMOUNT_ID = 'tui_swiper_unmount';

async function findById(id: string, timeout: number = 8000): Promise<Component> {
  const c = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (c === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return c;
}

async function textOf(id: string): Promise<string> {
  return await (await findById(id)).getText();
}

async function clickId(id: string): Promise<void> {
  await (await findById(id)).click();
  await DRIVER.waitForIdle(200, 2000);
}

async function waitForMode(name: string, timeout: number = 6000): Promise<void> {
  const deadline: number = new Date().getTime() + timeout;
  let last: string = '';
  while (new Date().getTime() <= deadline) {
    last = await textOf(MODE_LABEL_ID);
    if (last === `mode:${name}`) {
      return;
    }
    await DRIVER.waitForIdle(150, 800);
  }
  throw new Error(`mode not switched to ${name}, current=${last}`);
}

async function waitForPositiveHeight(timeout: number = 10000): Promise<number> {
  const deadline: number = new Date().getTime() + timeout;
  let last: number = 0;
  while (new Date().getTime() <= deadline) {
    const t: string = await textOf(AREA_HEIGHT_ID);
    const n: number = Number(t.substring('h:'.length));
    if (!Number.isNaN(n) && n > 0) {
      return n;
    }
    last = n;
    await DRIVER.waitForIdle(200, 1000);
  }
  throw new Error(`height never became positive, last=${last}`);
}

export default function tuiSwiperTest() {
  describe('TUISwiperTest', () => {
    beforeAll(async () => {
      await findById(HOST_ANCHOR_ID, 15000);
      await waitForMode('none');
    });

    afterEach(async () => {
      await clickId(UNMOUNT_ID);
      await waitForMode('none');
    });

    it('initDataByIsCovered_flat_mode_produces_positive_swiper_height', 0, async () => {
      await clickId(MOUNT_FLAT_ID);
      await waitForMode('flat');
      const h: number = await waitForPositiveHeight();
      expect(h > 0).assertTrue();
    });

    it('initDataByIsCovered_covered_mode_produces_positive_swiper_height', 0, async () => {
      await clickId(MOUNT_COVERED_ID);
      await waitForMode('covered');
      const h: number = await waitForPositiveHeight();
      expect(h > 0).assertTrue();
    });

    it('initDataByIsCovered_oversized_dimensions_are_clamped_without_crash', 0, async () => {
      await clickId(MOUNT_OVERSIZE_ID);
      await waitForMode('oversize');
      const h: number = await waitForPositiveHeight();
      expect(h > 0).assertTrue();
    });
  });
}
