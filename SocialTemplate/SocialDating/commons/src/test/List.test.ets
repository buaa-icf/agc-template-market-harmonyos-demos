import localUnitTest from './LocalUnit.test';
import userTest from './User.test';

export default function testsuite() {
  localUnitTest();
  userTest();
}