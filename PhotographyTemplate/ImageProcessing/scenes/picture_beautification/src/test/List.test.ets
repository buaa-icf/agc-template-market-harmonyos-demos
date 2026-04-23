import PictureBeautificationTest from './PictureBeautification.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  PictureBeautificationTest()
}
