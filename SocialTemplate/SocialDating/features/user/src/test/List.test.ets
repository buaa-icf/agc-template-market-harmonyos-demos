import localUnitTest from './LocalUnit.test';
import UserDetailTest from './UserDetail.test';

export default function testsuite() {
  localUnitTest();
  UserDetailTest();
}
