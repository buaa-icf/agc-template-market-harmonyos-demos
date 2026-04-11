import OrderUtilTest from './OrderUtil.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  OrderUtilTest()
}