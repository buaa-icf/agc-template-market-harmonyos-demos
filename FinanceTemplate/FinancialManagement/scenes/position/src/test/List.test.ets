import localUnitTest from './LocalUnit.test';
import TransactionInfoVMTest from './TransactionInfoVM.test';

export default function testsuite() {
  localUnitTest();
  TransactionInfoVMTest();
}
