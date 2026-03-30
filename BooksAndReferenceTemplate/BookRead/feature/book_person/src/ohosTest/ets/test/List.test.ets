import RechargePageTest from './RechargePage.test'
import MemberCenterPageTest from './MemberCenterPage.test'
import MemberAgreementPageTest from './MemberAgreementPage.test'
import LoginPageTest from './LoginPage.test'
import FeedbackPageTest from './FeedbackPage.test'
import AboutPageTest from './AboutPage.test'
import MyInfoCardTest from './MyInfoCard.test'
import abilityTest from './Ability.test';

export default function testsuite() {
  abilityTest();
  MyInfoCardTest()
  AboutPageTest()
  FeedbackPageTest()
  LoginPageTest()
  MemberAgreementPageTest()
  MemberCenterPageTest()
  RechargePageTest()
}