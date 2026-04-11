import MockResponseTest from './MockResponse.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  MockResponseTest()
}