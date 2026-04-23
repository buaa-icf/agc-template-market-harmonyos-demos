import BaseApiTest from './BaseApi.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  BaseApiTest()
}
