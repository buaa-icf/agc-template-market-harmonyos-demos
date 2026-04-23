import SubmitOrderPageTest from './SubmitOrderPage.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  SubmitOrderPageTest()
}
