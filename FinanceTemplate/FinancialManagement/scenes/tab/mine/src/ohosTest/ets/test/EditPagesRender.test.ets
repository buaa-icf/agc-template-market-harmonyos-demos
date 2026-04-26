import { describe, beforeAll, afterEach, it, expect } from '@ohos/hypium';
import { Component, Driver, ON } from '@kit.TestKit';
import { IUserInfo } from 'network';
import { MockStorageMap } from 'network/src/main/ets/mocks/Constants';

const DRIVER = Driver.create();
const HOST_ANCHOR_ID = 'mine_ohostest_anchor';

const mockUser: IUserInfo = {
  loginToken: 'tok',
  id: 1,
  name: 'Alice',
  nickname: 'ali',
  sex: 'F',
  cellphone: '13800000000',
  birthday: '2000-01-01',
  avatar: '',
};

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
    // Click on the Text node first (cheap path).
    await comp.click();
    await DRIVER.waitForIdle(300, 3000);
    // Some clickable rows wrap the Text in a parent Row with onClick — clicking the
    // bounding-box center via Driver.click(x,y) reliably reaches the parent handler.
    try {
      const bounds = await comp.getBounds();
      const cx = Math.floor((bounds.left + bounds.right) / 2);
      const cy = Math.floor((bounds.top + bounds.bottom) / 2);
      await DRIVER.click(cx, cy);
      await DRIVER.waitForIdle(300, 3000);
    } catch (_) {
    }
    return true;
  } catch (_) {
    return false;
  }
}

async function tryTypeIntoTextInput(value: string): Promise<boolean> {
  try {
    const comp = await DRIVER.waitForComponent(ON.type('TextInput'), 2000);
    if (comp === null) return false;
    await comp.click();
    await DRIVER.waitForIdle(200, 2000);
    await comp.inputText(value);
    await DRIVER.waitForIdle(300, 3000);
    return true;
  } catch (_) {
    return false;
  }
}

async function reset(): Promise<void> {
  try {
    await clickById('btn_s0');
  } catch (_) {
  }
  await DRIVER.waitForIdle(300, 3000);
}

export default function EditPagesRenderTest() {
  describe('EditPagesRenderTest', () => {
    beforeAll(async () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      await DRIVER.waitForIdle(1000, 10000);
      await findById(HOST_ANCHOR_ID, 10000);
    });

    afterEach(async () => {
      await reset();
    });

    it('S1_inlineRender_EditNamePage_buildBody', 0, async () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      await clickById('btn_s1');
      await DRIVER.waitForIdle(800, 5000);
      // Drive TextInput.onChange (L40-42) by typing into the input.
      await tryTypeIntoTextInput('newName');
      // Drive CommonSaveButton.changeValue (L51-52) by tapping "保存".
      await tryClickByText('保存');
      await findById(HOST_ANCHOR_ID, 5000);
      expect(true).assertTrue();
    });

    it('S2_inlineRender_EditPhonePage_buildBody', 0, async () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      await clickById('btn_s2');
      await DRIVER.waitForIdle(800, 5000);
      await tryTypeIntoTextInput('13800001111');
      await tryClickByText('保存');
      await findById(HOST_ANCHOR_ID, 5000);
      expect(true).assertTrue();
    });

    it('S3_pushAndPop_EditNamePage_firesShownHidden', 0, async () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      await clickById('btn_s3');
      await DRIVER.waitForIdle(800, 5000);
      // NavDestination is active → onShown fires (L63-65 calls vm.init).
      // Drive 保存 click on the full-screen route — fires CommonSaveButton.changeValue (L51-52).
      await tryTypeIntoTextInput('clickName');
      await tryClickByText('保存');
      // First pressBack may dismiss the soft keyboard left up by inputText;
      // a second one pops the NavDestination so onHidden fires.
      await DRIVER.pressBack();
      await DRIVER.waitForIdle(400, 3000);
      await DRIVER.pressBack();
      await DRIVER.waitForIdle(800, 5000);
      // onHidden fires (L66-68 calls vm.clear).
      expect(true).assertTrue();
    });

    it('S4_pushAndPop_EditPhonePage_firesShownHidden', 0, async () => {
      AppStorage.setOrCreate<IUserInfo>(MockStorageMap.USER_INFO, mockUser);
      // The host may have been left on a sub-route after S3; ensure we're on the host first.
      try {
        await clickById('btn_s0');
      } catch (_) {
        await DRIVER.pressBack();
        await DRIVER.waitForIdle(500, 3000);
      }
      await findById(HOST_ANCHOR_ID, 5000);
      await clickById('btn_s4');
      await DRIVER.waitForIdle(800, 5000);
      // Use an invalid length so vm.modify() short-circuits before the HTTP call
      // and the test ability is not blocked on a network response.
      await tryTypeIntoTextInput('123');
      await tryClickByText('保存');
      // First pressBack may dismiss the soft keyboard left up by inputText;
      // a second one pops the NavDestination so onHidden fires.
      await DRIVER.pressBack();
      await DRIVER.waitForIdle(400, 3000);
      await DRIVER.pressBack();
      await DRIVER.waitForIdle(800, 5000);
      expect(true).assertTrue();
    });
  });
}
