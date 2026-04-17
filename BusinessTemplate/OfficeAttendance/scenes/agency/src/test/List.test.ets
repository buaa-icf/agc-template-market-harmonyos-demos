import DataManagerTest from './DataManager.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  DataManagerTest()
}