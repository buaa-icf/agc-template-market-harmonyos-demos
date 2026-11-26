import { window } from '@kit.ArkUI';
import { abilityDelegatorRegistry, Component, Driver, ON } from '@kit.TestKit';

const TIMEOUT_MS = 4000;

export async function findById(driver: Driver, id: string): Promise<Component> {
  const component = await driver.waitForComponent(ON.id(id), TIMEOUT_MS);
  if (!component) {
    throw new Error(`Could not find ${id}`);
  }
  return component;
}

export async function clickById(driver: Driver, id: string): Promise<void> {
  await (await findById(driver, id)).click();
  await driver.waitForIdle(200, 1000);
}

export async function enterText(driver: Driver, id: string, value: string): Promise<void> {
  const input = await findById(driver, id);
  await input.inputText(value);
  // Release the input so the soft keyboard cannot cover the bottom save button.
  const ability = await abilityDelegatorRegistry.getAbilityDelegator().getCurrentTopAbility();
  const editorWindow = await window.getLastWindow(ability.context);
  editorWindow.getUIContext().getFocusController().clearFocus();
  await driver.waitForIdle(200, 1000);
}

export async function expectInputValue(driver: Driver, id: string, value: string): Promise<void> {
  const deadline = Date.now() + TIMEOUT_MS;
  let actual = await (await findById(driver, id)).getText();
  while (actual !== value && Date.now() < deadline) {
    await driver.delayMs(100);
    actual = await (await findById(driver, id)).getText();
  }
  if (actual !== value) {
    throw new Error(`Expected ${id} to contain "${value}", got "${actual}"`);
  }
}

export async function waitForEditorToClose(driver: Driver, inputId: string): Promise<void> {
  const deadline = Date.now() + TIMEOUT_MS;
  while (await driver.findComponent(ON.id(inputId))) {
    if (Date.now() >= deadline) {
      throw new Error(`The editor ${inputId} is still open`);
    }
    await driver.delayMs(100);
  }
  await findById(driver, 'scenario_bar');
}

export async function resetEditor(driver: Driver, inputId: string): Promise<void> {
  if (await driver.findComponent(ON.id(inputId))) {
    await clickById(driver, 'btn_pop');
    await waitForEditorToClose(driver, inputId);
  }
  await clickById(driver, 'btn_restore_user');
}
