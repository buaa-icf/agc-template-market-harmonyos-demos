import ScheduleFormTest from './ScheduleForm.test'
import abilityTest from './Ability.test';
import dataManagerTest from './DataManager.test';

export default function testsuite() {
  abilityTest();
  dataManagerTest();
  ScheduleFormTest()
}
