import CustomKeyboardTest from './CustomKeyboard.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  CustomKeyboardTest()
}