import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const FONT_SIZE_ADD_ID: string = 'reader_tool_bar_font_size_add';
const FONT_SIZE_VALUE_ID: string = 'reader_tool_bar_font_size_value';
const DRIVER = Driver.create();

async function waitForReaderToolBarLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await DRIVER.waitForComponent(ON.text('设置'), 10000);
}

async function findById(id: string, timeout: number = 5000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  expect(component !== null).assertTrue();
  return component as Component;
}

async function findByText(text: string, timeout: number = 5000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.text(text), timeout);
  expect(component !== null).assertTrue();
  return component as Component;
}

async function assertTextVisible(text: string): Promise<void> {
  await findByText(text);
}

export default function ReaderToolBarTest() {
  describe('ReaderToolBarTest', () => {
    beforeAll(async () => {
      await waitForReaderToolBarLoaded();
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('buildSettingSheet_shows_sections_and_updates_font_size', 0, async () => {
      const settingsTrigger = await findByText('设置');
      await settingsTrigger.click();
      await DRIVER.waitForIdle(500, 5000);
      await findByText('字号');

      await assertTextVisible('字号');
      await assertTextVisible('字体');
      await assertTextVisible('行间');
      await assertTextVisible('背景');
      await assertTextVisible('翻页');
      await assertTextVisible('系统');
      await assertTextVisible('鸿蒙黑体');
      await assertTextVisible('仿真');
      await assertTextVisible('横滑');

      const fontSizeValueBefore = await (await findById(FONT_SIZE_VALUE_ID)).getText();
      await (await findById(FONT_SIZE_ADD_ID)).click();
      await DRIVER.waitForIdle(500, 5000);
      const fontSizeValueAfter = await (await findById(FONT_SIZE_VALUE_ID)).getText();

      expect(Number.parseInt(fontSizeValueAfter)).assertEqual(Number.parseInt(fontSizeValueBefore) + 1);
    });
  });
}
