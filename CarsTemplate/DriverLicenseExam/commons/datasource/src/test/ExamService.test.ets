import { describe, beforeEach, it, expect } from '@ohos/hypium';
import { ClassificationTypeEnum, ExamDetail, QuestionTypeEnum } from 'exam';
import { ExamService } from '../main/ets/ExamService';
import { EXAM_MANAGER_TYPE, WRONG_COLLECT } from '../main/ets/Model';

function getQuestionSignature(examList: ExamDetail[]): string {
  let questions: string[] = [];
  examList.forEach((item: ExamDetail) => questions.push(item.question));
  return questions.join('||');
}

function getSortedQuestionSignature(examList: ExamDetail[]): string {
  let questions: string[] = [];
  examList.forEach((item: ExamDetail) => questions.push(item.question));
  return questions.sort().join('||');
}

function assertSameQuestions(actual: ExamDetail[], expected: ExamDetail[]): void {
  expect(actual.length).assertEqual(expected.length);
  expect(getQuestionSignature(actual)).assertEqual(getQuestionSignature(expected));
}

function assertClassificationFilter(examService: ExamService, allQuestions: ExamDetail[],
  examType: EXAM_MANAGER_TYPE, classificationType: ClassificationTypeEnum): void {
  const expected = allQuestions.filter((item: ExamDetail) => item.classificationType === classificationType);
  const actual = examService.getExamQuestionList(examType);
  assertSameQuestions(actual, expected);
}

function assertQuestionTypeFilter(examService: ExamService, allQuestions: ExamDetail[],
  examType: EXAM_MANAGER_TYPE, questionType: QuestionTypeEnum): void {
  const expected = allQuestions.filter((item: ExamDetail) => item.questionType === questionType);
  const actual = examService.getExamQuestionList(examType);
  assertSameQuestions(actual, expected);
}

export default function ExamServiceTest() {
  describe('ExamServiceTest', () => {
    let examService: ExamService;
    let allQuestions: ExamDetail[];

    beforeEach(() => {
      examService = new ExamService();
      allQuestions = examService.getExamQuestionList(EXAM_MANAGER_TYPE.sequence);
    });

    it('returns all questions for sequence type', 0, () => {
      expect(allQuestions.length).assertEqual(examService.getTotalCount());
    });

    it('keeps the same question set for random type', 0, () => {
      const randomQuestions = examService.getExamQuestionList(EXAM_MANAGER_TYPE.random);
      expect(randomQuestions.length).assertEqual(allQuestions.length);
      expect(getSortedQuestionSignature(randomQuestions)).assertEqual(getSortedQuestionSignature(allQuestions));
    });

    it('filters questions by chapter name', 0, () => {
      const chapterName = allQuestions[0].chapterName;
      const expected = allQuestions.filter((item: ExamDetail) => item.chapterName.includes(chapterName));
      const actual = examService.getExamQuestionList(EXAM_MANAGER_TYPE.chapter_name, chapterName);
      assertSameQuestions(actual, expected);
    });

    it('filters wrong questions inside the target chapter', 0, () => {
      const chapterName = allQuestions[0].chapterName;
      const chapterQuestions = allQuestions.filter((item: ExamDetail) => item.chapterName === chapterName);
      chapterQuestions.forEach((item: ExamDetail) => item.isCorrect = true);
      chapterQuestions[0].isCorrect = false;

      const expected = chapterQuestions.filter((item: ExamDetail) => item.isCorrect === false);
      const actual = examService.getExamQuestionList(EXAM_MANAGER_TYPE.chapter_name, chapterName, '',
        WRONG_COLLECT.WRONG);
      assertSameQuestions(actual, expected);
    });

    it('filters collected questions inside the target chapter', 0, () => {
      const chapterName = allQuestions[0].chapterName;
      const chapterQuestions = allQuestions.filter((item: ExamDetail) => item.chapterName === chapterName);
      chapterQuestions.forEach((item: ExamDetail) => item.isCollect = false);
      chapterQuestions[0].isCollect = true;

      const expected = chapterQuestions.filter((item: ExamDetail) => item.isCollect === true);
      const actual = examService.getExamQuestionList(EXAM_MANAGER_TYPE.chapter_name, chapterName, '',
        WRONG_COLLECT.COLLECT);
      assertSameQuestions(actual, expected);
    });

    it('filters questions by classification type', 0, () => {
      assertClassificationFilter(examService, allQuestions, EXAM_MANAGER_TYPE.easy, ClassificationTypeEnum.EASY);
      assertClassificationFilter(examService, allQuestions, EXAM_MANAGER_TYPE.simple, ClassificationTypeEnum.SIMPLE);
      assertClassificationFilter(examService, allQuestions, EXAM_MANAGER_TYPE.normal, ClassificationTypeEnum.MIDDLE);
      assertClassificationFilter(examService, allQuestions, EXAM_MANAGER_TYPE.difficult, ClassificationTypeEnum.HARD);
    });

    it('filters questions by question type', 0, () => {
      assertQuestionTypeFilter(examService, allQuestions, EXAM_MANAGER_TYPE.single, QuestionTypeEnum.RADIO);
      assertQuestionTypeFilter(examService, allQuestions, EXAM_MANAGER_TYPE.multi, QuestionTypeEnum.CHECK_BOX);
      assertQuestionTypeFilter(examService, allQuestions, EXAM_MANAGER_TYPE.judging, QuestionTypeEnum.JUDGE);
    });

    it('filters global wrong and collected questions', 0, () => {
      allQuestions[0].isCorrect = false;
      allQuestions[1].isCorrect = false;
      allQuestions[0].isCollect = true;
      allQuestions[2].isCollect = true;

      const errorQuestions = examService.getExamQuestionList(EXAM_MANAGER_TYPE.error);
      const collectQuestions = examService.getExamQuestionList(EXAM_MANAGER_TYPE.collect);

      assertSameQuestions(errorQuestions, allQuestions.filter((item: ExamDetail) => item.isCorrect === false));
      assertSameQuestions(collectQuestions, allQuestions.filter((item: ExamDetail) => item.isCollect === true));
    });

    it('filters questions by search keyword', 0, () => {
      const keyword = allQuestions[0].question.substring(0, 4);
      const expected = allQuestions.filter((item: ExamDetail) => item.question.includes(keyword));
      const actual = examService.getExamQuestionList(EXAM_MANAGER_TYPE.search, '', keyword);
      assertSameQuestions(actual, expected);
    });

    it('returns all questions for mock exam type', 0, () => {
      const actual = examService.getExamQuestionList(EXAM_MANAGER_TYPE.mock_exam);
      assertSameQuestions(actual, allQuestions);
    });
  });
}
