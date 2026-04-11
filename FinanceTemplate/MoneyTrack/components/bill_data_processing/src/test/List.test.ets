import BaseDBTest from './BaseDB.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  BaseDBTest()
}