import { specialExercisesViewBuilder } from '../main/ets/pages/specialExercises/SpecialExercisesView';

interface ViewV2Host {
  create: (component: Object) => void;
}

declare const ViewV2: ViewV2Host;

export interface SpecialExercisesViewLike {
  examService: Object;
  totalCount: number;
  setQuestionCount: () => void;
  aboutToBeDeleted?: () => void;
}

interface SpecialExercisesViewTestHostLike {
  initialRender: () => void;
}

@ComponentV2
struct SpecialExercisesViewTestHost {
  build() {
    specialExercisesViewBuilder();
  }
}

export function createSpecialExercisesViewForTest(): SpecialExercisesViewLike {
  let capturedView: SpecialExercisesViewLike | undefined = undefined;
  const viewV2Host = ViewV2 as Object as ViewV2Host;
  const originalCreate = viewV2Host.create;
  viewV2Host.create = (component: Object) => {
    capturedView = component as SpecialExercisesViewLike;
    originalCreate(component);
  }

  try {
    const host = new SpecialExercisesViewTestHost() as Object as SpecialExercisesViewTestHostLike;
    host.initialRender();
  } finally {
    viewV2Host.create = originalCreate;
  }

  if (capturedView === undefined) {
    throw new Error('Failed to capture SpecialExercisesView instance.');
  }

  return capturedView as SpecialExercisesViewLike;
}
