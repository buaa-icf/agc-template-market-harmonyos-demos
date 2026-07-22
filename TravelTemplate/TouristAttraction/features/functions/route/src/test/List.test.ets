import localUnitTest from './LocalUnit.test';
import RouteLineMapperTest from './RouteLineMapper.test';

export default function testsuite() {
  localUnitTest();
  RouteLineMapperTest();
}
