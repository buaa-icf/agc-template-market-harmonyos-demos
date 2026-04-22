import localUnitTest from './LocalUnit.test';
import mockResponseTest from './MockResponse.test';

export default function testsuite() {
  localUnitTest();
  mockResponseTest();
}