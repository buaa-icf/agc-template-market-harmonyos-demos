import AxiosHttpTest from './AxiosHttp.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  AxiosHttpTest()
}