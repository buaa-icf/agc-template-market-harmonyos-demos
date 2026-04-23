import PatientViewModelTest from './PatientViewModel.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  PatientViewModelTest()
}
