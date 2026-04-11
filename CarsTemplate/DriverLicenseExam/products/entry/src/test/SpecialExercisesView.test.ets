import { describe, beforeEach, afterEach, it, expect } from '@ohos/hypium';
import {
  CLASSIFY_DATA,
  DATA_BY_QUESTION_TYPE,
  EXAM_MANAGER_TYPE,
} from '@ohos_agcit/driver_license_exam_datasource';
import {
  createSpecialExercisesViewForTest,
  SpecialExercisesViewLike,
} from './specialExercisesViewRouteCapture';

interface ExamServiceLike {
  getEasyQuestionCount: () => number;
  getSimpleQuestionCount: () => number;
  getMiddleQuestionCount: () => number;
  getMistakeQuestionCount: () => number;
  getHardQuestionCount: () => number;
  getRadioQuestionCount: () => number;
  getJudgeQuestionCount: () => number;
  getTotalCount: () => number;
}

interface QuestionQuantityLike {
  type: EXAM_MANAGER_TYPE;
  quantity: number;
}

class QuantitySnapshot {
  type: EXAM_MANAGER_TYPE;
  quantity: number = 0;

  constructor(type: EXAM_MANAGER_TYPE, quantity: number) {
    this.type = type;
    this.quantity = quantity;
  }
}

interface SpecialExercisesViewWithExamService extends SpecialExercisesViewLike {
  examService: ExamServiceLike;
}

const EASY_COUNT = 11;
const SIMPLE_COUNT = 12;
const NORMAL_COUNT = 13;
const MISTAKE_COUNT = 14;
const DIFFICULT_COUNT = 15;
const SINGLE_COUNT = 16;
const JUDGING_COUNT = 17;
const TOTAL_COUNT = 18;

function snapshotQuantities(items: QuestionQuantityLike[]): QuantitySnapshot[] {
  return items.map(
    (item: QuestionQuantityLike) => new QuantitySnapshot(item.type, item.quantity),
  );
}

function restoreQuantities(
  items: QuestionQuantityLike[],
  snapshots: QuantitySnapshot[],
): void {
  items.forEach((item: QuestionQuantityLike) => {
    const snapshot = snapshots.find(
      (entry: QuantitySnapshot) => entry.type === item.type,
    );
    item.quantity = snapshot?.quantity ?? 0;
  });
}

function findQuantity(
  items: QuestionQuantityLike[],
  type: EXAM_MANAGER_TYPE,
): number {
  return items.find((item: QuestionQuantityLike) => item.type === type)?.quantity ?? -1;
}

export default function SpecialExercisesViewTest() {
  describe('SpecialExercisesViewTest', () => {
    let specialExercisesView: SpecialExercisesViewLike | undefined;
    let classifySnapshot: QuantitySnapshot[];
    let questionTypeSnapshot: QuantitySnapshot[];
    let examService: ExamServiceLike;

    beforeEach(() => {
      classifySnapshot = snapshotQuantities(CLASSIFY_DATA as QuestionQuantityLike[]);
      questionTypeSnapshot = snapshotQuantities(
        DATA_BY_QUESTION_TYPE as QuestionQuantityLike[],
      );
      specialExercisesView = createSpecialExercisesViewForTest();
      const view = specialExercisesView as SpecialExercisesViewWithExamService;
      examService = {
        getEasyQuestionCount: (): number => EASY_COUNT,
        getSimpleQuestionCount: (): number => SIMPLE_COUNT,
        getMiddleQuestionCount: (): number => NORMAL_COUNT,
        getMistakeQuestionCount: (): number => MISTAKE_COUNT,
        getHardQuestionCount: (): number => DIFFICULT_COUNT,
        getRadioQuestionCount: (): number => SINGLE_COUNT,
        getJudgeQuestionCount: (): number => JUDGING_COUNT,
        getTotalCount: (): number => TOTAL_COUNT,
      };
      view.examService = examService;
      view.totalCount = 0;

      (CLASSIFY_DATA as QuestionQuantityLike[]).forEach((item: QuestionQuantityLike) => {
        item.quantity = -1;
      });
      (DATA_BY_QUESTION_TYPE as QuestionQuantityLike[]).forEach((item: QuestionQuantityLike) => {
        item.quantity = -1;
      });
    });

    afterEach(() => {
      restoreQuantities(
        CLASSIFY_DATA as QuestionQuantityLike[],
        classifySnapshot,
      );
      restoreQuantities(
        DATA_BY_QUESTION_TYPE as QuestionQuantityLike[],
        questionTypeSnapshot,
      );
      specialExercisesView?.aboutToBeDeleted?.();
    });

    it('updates difficulty, question type and total counts from exam service', 0, () => {
      const view = specialExercisesView as SpecialExercisesViewLike;
      view.setQuestionCount();

      expect(
        findQuantity(CLASSIFY_DATA as QuestionQuantityLike[], EXAM_MANAGER_TYPE.easy),
      ).assertEqual(EASY_COUNT);
      expect(
        findQuantity(CLASSIFY_DATA as QuestionQuantityLike[], EXAM_MANAGER_TYPE.simple),
      ).assertEqual(SIMPLE_COUNT);
      expect(
        findQuantity(CLASSIFY_DATA as QuestionQuantityLike[], EXAM_MANAGER_TYPE.normal),
      ).assertEqual(NORMAL_COUNT);
      expect(
        findQuantity(CLASSIFY_DATA as QuestionQuantityLike[], EXAM_MANAGER_TYPE.mistake),
      ).assertEqual(MISTAKE_COUNT);
      expect(
        findQuantity(
          CLASSIFY_DATA as QuestionQuantityLike[],
          EXAM_MANAGER_TYPE.difficult,
        ),
      ).assertEqual(DIFFICULT_COUNT);
      expect(
        findQuantity(
          DATA_BY_QUESTION_TYPE as QuestionQuantityLike[],
          EXAM_MANAGER_TYPE.single,
        ),
      ).assertEqual(SINGLE_COUNT);
      expect(
        findQuantity(
          DATA_BY_QUESTION_TYPE as QuestionQuantityLike[],
          EXAM_MANAGER_TYPE.judging,
        ),
      ).assertEqual(JUDGING_COUNT);
      expect(view.totalCount).assertEqual(TOTAL_COUNT);
    });
  });
}
