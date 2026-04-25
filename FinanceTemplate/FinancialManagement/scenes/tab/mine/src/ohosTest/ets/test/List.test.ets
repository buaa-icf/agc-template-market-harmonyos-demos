import EditPhonePageVMTest from './EditPhonePageVM.test'
import EditNamePageVMTest from './EditNamePageVM.test'
import EditPhonePageTest from './EditPhonePage.test'
import EditNamePageTest from './EditNamePage.test'
import abilityTest from './Ability.test';

export default function testsuite() {
  abilityTest();
  EditNamePageTest()
  EditPhonePageTest()
  EditNamePageVMTest()
  EditPhonePageVMTest()
}