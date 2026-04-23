import abilityTest from './Ability.test';
import AddVisitorPageTest from './AddVisitorPage.test';
import EditVisitorPageTest from './EditVisitorPage.test';
import RecommendBarTest from './RecommendBar.test';

export default function testsuite() {
  abilityTest();
  AddVisitorPageTest();
  EditVisitorPageTest();
  RecommendBarTest();
}
