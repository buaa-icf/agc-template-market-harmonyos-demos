import { afterEach, beforeAll, describe, it } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import { clickById, enterText, expectInputValue, findById, resetEditor, waitForEditorToClose } from './ProfileEditorUi';

const INPUT = 'edit_name_input';
const SAVE = 'edit_name_save_button';
const OPEN = 'btn_show_name';

export default function editNamePageTest() {
  describe('EditNamePageTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = Driver.create();
      await findById(driver, 'scenario_bar');
    });

    afterEach(async () => {
      await resetEditor(driver, INPUT);
    });

    it('rejectsEmptyNickname', 0, async () => {
      await clickById(driver, 'btn_seed_name_empty');
      await clickById(driver, OPEN);
      await expectInputValue(driver, INPUT, '');
      await clickById(driver, SAVE);
      await expectInputValue(driver, INPUT, '');
    });

    it('rejectsTooLongNickname', 0, async () => {
      await clickById(driver, 'btn_seed_name_long');
      await clickById(driver, OPEN);
      await expectInputValue(driver, INPUT, 'abcdefghij');
      await clickById(driver, SAVE);
      await expectInputValue(driver, INPUT, 'abcdefghij');
    });

    it('updatesNicknameWhenUserInfoExists', 0, async () => {
      await clickById(driver, 'btn_seed_name_empty');
      await clickById(driver, OPEN);
      await enterText(driver, INPUT, 'alice');
      await expectInputValue(driver, INPUT, 'alice');
      await clickById(driver, SAVE);
      await waitForEditorToClose(driver, INPUT);
      await clickById(driver, OPEN);
      await expectInputValue(driver, INPUT, 'alice');
    });

    it('rendersAndSavesNickname', 0, async () => {
      await clickById(driver, 'btn_seed_name_valid');
      await clickById(driver, OPEN);
      await expectInputValue(driver, INPUT, 'alice');
      await clickById(driver, SAVE);
      await waitForEditorToClose(driver, INPUT);
    });

    it('ignoresNicknameChangesWhenUserInfoIsMissing', 0, async () => {
      await clickById(driver, 'btn_seed_name_valid');
      await clickById(driver, 'btn_seed_missing_user');
      await clickById(driver, OPEN);
      await expectInputValue(driver, INPUT, '');
      await enterText(driver, INPUT, 'orphan');
      await clickById(driver, SAVE);
      await findById(driver, INPUT);
      await resetEditor(driver, INPUT);
      await clickById(driver, OPEN);
      await expectInputValue(driver, INPUT, 'alice');
    });
  });
}
