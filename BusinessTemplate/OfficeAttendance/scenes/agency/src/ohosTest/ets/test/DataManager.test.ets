import { beforeEach, afterAll, describe, expect, it } from '@ohos/hypium';
import { DataManager } from '../../../main/ets/mock/DataManager';
import { TaskItem } from '../../../main/ets/types/Types';

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

    it('saveTodo_assigns_id_and_persists_new_todo', 0, () => {
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

    it('saveTodo_updates_existing_todo_in_place', 0, () => {
      const todo: TaskItem = { title: 'Initial title', isFinished: false };
      const anotherTodo: TaskItem = { title: 'Keep me', isFinished: false };
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

    it('getId_returns_incrementing_ids', 0, () => {
      const firstId = Number(DataManager.getId());
      const secondId = Number(DataManager.getId());
      expect(secondId - firstId).assertEqual(1);
    });

    it('init_can_be_called_without_throwing', 0, () => {
      DataManager.init();
      DataManager.init();
      expect(true).assertEqual(true);
    });
  });
}
