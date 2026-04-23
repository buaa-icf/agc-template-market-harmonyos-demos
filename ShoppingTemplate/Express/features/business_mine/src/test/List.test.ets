import localUnitTest from './LocalUnit.test';
import editNamePageVMTest from './EditNamePageVM.test';
import editPhonePageVMTest from './EditPhonePageVM.test';

export default function testsuite() {
  localUnitTest();
  editNamePageVMTest();
  editPhonePageVMTest();
}