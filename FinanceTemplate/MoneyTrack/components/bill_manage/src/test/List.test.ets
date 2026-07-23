import CustomKeyboardTest from './CustomKeyboard.test'
import localUnitTest from './LocalUnit.test';
import ResourceManageVMTest from './ResourceManageVM.test';

export default function testsuite() {
  localUnitTest();
  CustomKeyboardTest()
  ResourceManageVMTest()
}
