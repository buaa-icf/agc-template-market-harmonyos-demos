import QuickLoginPageTest from './QuickLoginPage.test'
import AgreementViewTest from './AgreementView.test'
import abilityTest from './Ability.test';

export default function testsuite() {
  abilityTest();
  AgreementViewTest()
  QuickLoginPageTest()
}