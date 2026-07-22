import localUnitTest from './LocalUnit.test';
import ObserveModelTest from './ObserveModel.test';

export default function testsuite() {
  localUnitTest();
  ObserveModelTest();
}
