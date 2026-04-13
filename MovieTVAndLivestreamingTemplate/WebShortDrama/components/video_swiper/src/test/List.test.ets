import VideoPlayViewTest from './VideoPlayView.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  VideoPlayViewTest()
}