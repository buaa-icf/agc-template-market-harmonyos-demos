import ExamServiceTest from './ExamService.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  ExamServiceTest()
}