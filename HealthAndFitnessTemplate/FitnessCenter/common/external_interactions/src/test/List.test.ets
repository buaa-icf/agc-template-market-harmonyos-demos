import MockServiceTest from './MockService.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  MockServiceTest()
}