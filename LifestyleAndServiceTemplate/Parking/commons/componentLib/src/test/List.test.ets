import CommonKeyboardTest from './CommonKeyboard.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  CommonKeyboardTest()
}