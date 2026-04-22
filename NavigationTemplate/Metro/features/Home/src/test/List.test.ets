import localUnitTest from './LocalUnit.test';
import homeFunctionsTest from './HomeFunctions.test';

export default function testsuite() {
  localUnitTest();
  homeFunctionsTest();
}