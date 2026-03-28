import AccountCardTest from './AccountCard.test'
import RechargePageTest from './RechargePage.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  RechargePageTest()
  AccountCardTest()
}