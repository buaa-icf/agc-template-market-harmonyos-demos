import localUnitTest from './LocalUnit.test';
import OrderInfoPageVMTest from './OrderInfoPageVM.test';

export default function testsuite() {
  localUnitTest();
  OrderInfoPageVMTest();
}
