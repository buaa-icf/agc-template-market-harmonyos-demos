import AxiosBaseTest from './AxiosBase.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  AxiosBaseTest()
}