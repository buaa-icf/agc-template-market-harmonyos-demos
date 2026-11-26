import { afterEach, beforeAll, describe, it } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import { clickById, enterText, expectInputValue, findById, resetEditor, waitForEditorToClose } from './ProfileEditorUi';

const INPUT = 'edit_phone_input';
const SAVE = 'edit_phone_save_button';
const OPEN = 'btn_show_phone';

export default function editPhonePageTest() {
  describe('EditPhonePageTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = Driver.create();
      await findById(driver, 'scenario_bar');
    });

    afterEach(async () => {
      await resetEditor(driver, INPUT);
    });

    it('rejectsEmptyPhone', 0, async () => {
      await clickById(driver, 'btn_seed_phone_empty');
      await clickById(driver, OPEN);
      await expectInputValue(driver, INPUT, '');
      await clickById(driver, SAVE);
      await expectInputValue(driver, INPUT, '');
    });

    it('rejectsWrongLengthPhone', 0, async () => {
      await clickById(driver, 'btn_seed_phone_short');
      await clickById(driver, OPEN);
      await expectInputValue(driver, INPUT, '123');
      await clickById(driver, SAVE);
      await expectInputValue(driver, INPUT, '123');
    });

    it('updatesPhoneWhenUserInfoExists', 0, async () => {
      await clickById(driver, 'btn_seed_phone_empty');
      await clickById(driver, OPEN);
      await enterText(driver, INPUT, '13900001111');
      await expectInputValue(driver, INPUT, '13900001111');
      await clickById(driver, SAVE);
      await waitForEditorToClose(driver, INPUT);
      await clickById(driver, OPEN);
      await expectInputValue(driver, INPUT, '13900001111');
    });

    it('rendersAndSavesPhone', 0, async () => {
      await clickById(driver, 'btn_seed_phone_valid');
      await clickById(driver, OPEN);
      await expectInputValue(driver, INPUT, '13900001111');
      await clickById(driver, SAVE);
      await waitForEditorToClose(driver, INPUT);
    });

    it('ignoresPhoneChangesWhenUserInfoIsMissing', 0, async () => {
      await clickById(driver, 'btn_seed_phone_valid');
      await clickById(driver, 'btn_seed_missing_phone_user');
      await clickById(driver, OPEN);
      await expectInputValue(driver, INPUT, '');
      await enterText(driver, INPUT, '13700002222');
      await clickById(driver, SAVE);
      await findById(driver, INPUT);
      await resetEditor(driver, INPUT);
      await clickById(driver, OPEN);
      await expectInputValue(driver, INPUT, '13900001111');
    });
  });
}
