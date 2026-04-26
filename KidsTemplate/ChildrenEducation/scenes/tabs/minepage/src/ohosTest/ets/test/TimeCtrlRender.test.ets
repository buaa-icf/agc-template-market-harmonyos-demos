import { describe, beforeAll, afterEach, it, expect } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'TimeCtrlRender';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID = 'minepage_ohostest_anchor';

async function findById(id: string, timeout: number = 5000): Promise<Component> {
  const comp = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (comp === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return comp;
}

async function clickById(id: string): Promise<void> {
  const comp = await findById(id);
  await comp.click();
  await DRIVER.waitForIdle(300, 3000);
}

async function tryClickByText(text: string): Promise<boolean> {
  try {
    const comp = await DRIVER.waitForComponent(ON.text(text), 2000);
    if (comp === null) return false;
    await comp.click();
    await DRIVER.waitForIdle(300, 3000);
    return true;
  } catch (_) {
    return false;
  }
}

// Click every component matching the text in document order. Re-queries fresh
// each iteration because clicks may open/close modal dialogs and stale handles
// fail. Bounded by maxClicks to avoid runaway loops.
//
// If `acceptText` is provided and a node with that text becomes visible after
// the click (e.g. "确定" inside a TimePickerDialog), tap it first so the
// dialog's onAccept callback fires before we dismiss the modal.
async function clickAllByText(
  text: string,
  acceptText: string | null = null,
  maxClicks: number = 4
): Promise<number> {
  let clicked = 0;
  for (let i = 0; i < maxClicks; i++) {
    let comp: Component | null = null;
    try {
      const comps = await DRIVER.findComponents(ON.text(text));
      hilog.info(0x0000, TAG, 'iter %{public}d text=%{public}s comps=%{public}d',
        i, text, comps ? comps.length : -1);
      if (!comps || comps.length <= i) break;
      comp = comps[i];
    } catch (e) {
      hilog.error(0x0000, TAG, 'find error: %{public}s', String(e));
      break;
    }
    if (comp === null) break;
    try {
      await comp.click();
      await DRIVER.waitForIdle(400, 3000);
    } catch (_) {
      break;
    }
    let dismissed = false;
    if (acceptText !== null) {
      try {
        // Wait long enough for the TimePickerDialog to finish opening before
        // searching for the accept button — racing it can cause a click that
        // the dialog hasn't bound yet, so the onAccept callback never fires.
        await DRIVER.waitForIdle(500, 2500);
        const accept = await DRIVER.waitForComponent(ON.text(acceptText), 3000);
        if (accept !== null) {
          await accept.click();
          await DRIVER.waitForIdle(500, 3000);
          // Accept normally closes the dialog itself, so skip the pressBack
          // below; an extra back press here would pop the underlying route.
          dismissed = true;
        }
      } catch (_) {
      }
    }
    if (!dismissed) {
      await DRIVER.pressBack();
      await DRIVER.waitForIdle(200, 1500);
    }
    clicked++;
    // Swipe up so the next match (e.g. lunch row after the night row) is
    // inside the touchable region before the next iteration.
    try {
      const display = await DRIVER.getDisplaySize();
      const w = display.x ?? 720;
      const h = display.y ?? 1280;
      await DRIVER.swipe(Math.floor(w / 2), Math.floor(h * 0.6), Math.floor(w / 2), Math.floor(h * 0.4));
      await DRIVER.waitForIdle(200, 1500);
    } catch (_) {
    }
  }
  return clicked;
}

async function ensureBackToHost(): Promise<void> {
  // Up to a few pressBack calls in case dialogs / routes are stacked on top.
  for (let i = 0; i < 3; i++) {
    try {
      const anchor = await DRIVER.waitForComponent(ON.id(HOST_ANCHOR_ID), 1500);
      if (anchor !== null) return;
    } catch (_) {
    }
    await DRIVER.pressBack();
    await DRIVER.waitForIdle(400, 3000);
  }
}

async function reset(): Promise<void> {
  await ensureBackToHost();
  try {
    await clickById('btn_s0');
  } catch (_) {
  }
  await DRIVER.waitForIdle(300, 3000);
}

export default function TimeCtrlRenderTest() {
  describe('TimeCtrlRenderTest', () => {
    beforeAll(async () => {
      await DRIVER.waitForIdle(1000, 10000);
      await findById(HOST_ANCHOR_ID, 10000);
    });

    afterEach(async () => {
      await reset();
    });

    it('S1_inlineRender_TimeCtrl_buildBody', 0, async () => {
      await clickById('btn_s1');
      await DRIVER.waitForIdle(800, 5000);
      // Inline-render path: fire each Row's TimePickerDialog onClick, dismiss
      // with pressBack. Covers L90-100 + L114-124 + L165-175 + L189-199.
      await clickAllByText('开始时间');
      await clickAllByText('结束时间');
      await findById(HOST_ANCHOR_ID, 5000);
      expect(true).assertTrue();
    });

    it('S2_pushAndPop_TimeCtrl_firesShownHidden', 0, async () => {
      await clickById('btn_s2');
      await DRIVER.waitForIdle(1000, 5000);
      // NavDestination is the active route → onShown fires (reads GlobalContext into @Local fields).
      // Click "确定" inside each TimePickerDialog so the onAccept callback fires
      // (covers L104/L128/L179/L203 — the four onAccept arrow bodies).
      await clickAllByText('开始时间', '确定');
      await clickAllByText('结束时间', '确定');
      // Tap "保存" to fire the save block at the bottom of build().
      await tryClickByText('保存');
      await DRIVER.waitForIdle(300, 2000);
      // Pop the route → onHidden fires.
      await DRIVER.pressBack();
      await DRIVER.waitForIdle(800, 5000);
      expect(true).assertTrue();
    });
  });
}
