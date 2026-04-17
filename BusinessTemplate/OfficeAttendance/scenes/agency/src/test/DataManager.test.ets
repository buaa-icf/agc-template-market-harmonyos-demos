import { beforeEach, afterAll, describe, expect, it } from '@ohos/hypium';
import { DataManager } from '../main/ets/mock/DataManager';
import { TaskItem } from '../main/ets/types/Types';

function taskId(todo: TaskItem): string {
  return todo.taskID ? todo.taskID : '';
}

function clearTodos() {
  const todos = DataManager.loadTodos();
  todos.forEach((todo: TaskItem) => {
    const id = taskId(todo);
    if (id.length > 0) {
      DataManager.deleteById(id);
    }
  });
}

export default function DataManagerTest() {
  describe('DataManagerTest', () => {
    beforeEach(() => {
      DataManager.init();
      clearTodos();
    });

    afterAll(() => {
      clearTodos();
    });

    it('returns empty results when no todo has been saved', 0, () => {
      expect(DataManager.loadTodos().length).assertEqual(0);
      expect(DataManager.queryById('missing-task') === undefined).assertEqual(true);
      expect(DataManager.querySubTasks('missing-task').length).assertEqual(0);
      expect(DataManager.queryTasks('keyword', true).length).assertEqual(0);
    });

    it('assigns an id and stores a new todo', 0, () => {
      const todo: TaskItem = {
        title: 'Write weekly summary',
        isFinished: false
      };

      DataManager.saveTodo(todo);

      const savedTodos = DataManager.loadTodos();
      expect(taskId(todo).length > 0).assertEqual(true);
      expect(savedTodos.length).assertEqual(1);
      expect(savedTodos[0].title).assertEqual('Write weekly summary');
      expect(savedTodos[0].taskID).assertEqual(taskId(todo));
    });

    it('updates an existing todo without creating a duplicate', 0, () => {
      const todo: TaskItem = {
        title: 'Initial title',
        isFinished: false
      };
      const anotherTodo: TaskItem = {
        title: 'Keep me',
        isFinished: false
      };
      DataManager.saveTodo(todo);
      DataManager.saveTodo(anotherTodo);

      const updatedTodo: TaskItem = {
        taskID: taskId(todo),
        title: 'Updated title',
        isFinished: true
      };
      DataManager.saveTodo(updatedTodo);

      const savedTodos = DataManager.loadTodos();
      expect(savedTodos.length).assertEqual(2);
      expect(savedTodos[0].title).assertEqual('Updated title');
      expect(savedTodos[0].isFinished === true).assertEqual(true);
      expect(savedTodos[1].title).assertEqual('Keep me');
      expect(DataManager.queryById(taskId(todo))?.title).assertEqual('Updated title');
    });

    it('queries subtasks by parent id', 0, () => {
      const parent: TaskItem = {
        title: 'Parent task',
        isFinished: false
      };
      DataManager.saveTodo(parent);

      const subTaskA: TaskItem = {
        parentID: taskId(parent),
        title: 'Sub task A',
        isFinished: false
      };
      const subTaskB: TaskItem = {
        parentID: taskId(parent),
        title: 'Sub task B',
        isFinished: true
      };
      const unrelatedTask: TaskItem = {
        title: 'Unrelated task',
        isFinished: false
      };

      DataManager.saveTodo(subTaskA);
      DataManager.saveTodo(subTaskB);
      DataManager.saveTodo(unrelatedTask);

      const subTasks = DataManager.querySubTasks(taskId(parent));
      const subTaskIds = subTasks.map((todo: TaskItem) => taskId(todo)).join(',');
      expect(subTasks.length).assertEqual(2);
      expect(subTaskIds.indexOf(taskId(subTaskA)) >= 0).assertEqual(true);
      expect(subTaskIds.indexOf(taskId(subTaskB)) >= 0).assertEqual(true);
    });

    it('filters todos by finished state and title keyword', 0, () => {
      DataManager.saveTodo({ title: 'Review contract', isFinished: true });
      DataManager.saveTodo({ title: 'Review budget', isFinished: true });
      DataManager.saveTodo({ title: 'Review contract', isFinished: false });
      DataManager.saveTodo({ title: 'Prepare slides', isFinished: true });

      const finishedReviews = DataManager.queryTasks('Review', true);
      const unfinishedReviews = DataManager.queryTasks('Review', false);

      expect(finishedReviews.length).assertEqual(2);
      expect(unfinishedReviews.length).assertEqual(1);
      expect(finishedReviews.filter((todo: TaskItem) => todo.title ? todo.title.indexOf('Review') >= 0 : false).length)
        .assertEqual(2);
      expect(unfinishedReviews.filter((todo: TaskItem) => todo.isFinished === false).length).assertEqual(1);
    });

    it('returns all todos in a state when the query name is empty', 0, () => {
      DataManager.saveTodo({ title: 'Sync report', isFinished: true });
      DataManager.saveTodo({ isFinished: true });
      DataManager.saveTodo({ title: 'Plan trip', isFinished: false });

      const finishedTodos = DataManager.queryTasks('', true);

      expect(finishedTodos.length).assertEqual(2);
      expect(finishedTodos.filter((todo: TaskItem) => todo.isFinished === true).length).assertEqual(2);
    });

    it('deletes a todo by id', 0, () => {
      const todoA: TaskItem = {
        title: 'Todo A',
        isFinished: false
      };
      const todoB: TaskItem = {
        title: 'Todo B',
        isFinished: true
      };

      DataManager.saveTodo(todoA);
      DataManager.saveTodo(todoB);
      DataManager.deleteById(taskId(todoA));

      const savedTodos = DataManager.loadTodos();
      expect(savedTodos.length).assertEqual(1);
      expect(savedTodos[0].title).assertEqual('Todo B');
      expect(DataManager.queryById(taskId(todoA)) === undefined).assertEqual(true);
    });

    it('generates incrementing ids', 0, () => {
      const firstId = Number(DataManager.getId());
      const secondId = Number(DataManager.getId());

      expect(secondId - firstId).assertEqual(1);
    });
  });
}
