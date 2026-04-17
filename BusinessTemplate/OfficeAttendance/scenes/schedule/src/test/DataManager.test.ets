import { describe, beforeEach, afterEach, it, expect } from '@ohos/hypium';
import { DataManager } from '../main/ets/mock/DataManager';
import { ScheduleInfo } from '../main/ets/types/Types';

function createSchedule(title: string, startTime: string, endTime: string, id?: string): ScheduleInfo {
  return {
    id,
    title,
    startTime,
    endTime
  };
}

export default function DataManagerTest() {
  describe('DataManagerTest', () => {
    beforeEach(() => {
      DataManager.save([]);
    });

    afterEach(() => {
      DataManager.save([]);
    });

    it('saveOne should assign an id and persist a new schedule', 0, () => {
      const item = createSchedule('Morning Standup', '2024-05-01 09:00', '2024-05-01 09:30');

      DataManager.saveOne(item);

      const savedItems = DataManager.loadAll();
      expect(savedItems.length).assertEqual(1);
      expect(savedItems[0].title).assertEqual('Morning Standup');
      expect(!!savedItems[0].id).assertEqual(true);
      expect(savedItems[0].id === item.id).assertEqual(true);
    });

    it('saveOne should replace the schedule with the same id', 0, () => {
      DataManager.save([
        createSchedule('Draft Plan', '2024-05-01 09:00', '2024-05-01 10:00', '1'),
        createSchedule('Team Sync', '2024-05-02 14:00', '2024-05-02 15:00', '2')
      ]);

      DataManager.saveOne(createSchedule('Updated Plan', '2024-05-01 11:00', '2024-05-01 12:00', '1'));

      const allItems = DataManager.loadAll();
      const updatedItem = DataManager.queryById('1');
      const preservedItem = DataManager.queryById('2');

      expect(allItems.length).assertEqual(2);
      expect(!!updatedItem).assertEqual(true);
      expect(!!preservedItem).assertEqual(true);
      if (updatedItem) {
        expect(updatedItem.title).assertEqual('Updated Plan');
        expect(updatedItem.startTime).assertEqual('2024-05-01 11:00');
      }
      if (preservedItem) {
        expect(preservedItem.title).assertEqual('Team Sync');
      }
    });

    it('queryByDate should return schedules on the requested day', 0, () => {
      DataManager.save([
        createSchedule('Morning Standup', '2024-05-01 09:00', '2024-05-01 09:30', '1'),
        createSchedule('Design Review', '2024-05-01 15:00', '2024-05-01 16:00', '2'),
        createSchedule('Planning', '2024-05-02 10:00', '2024-05-02 11:00', '3')
      ]);

      const result = DataManager.queryByDate('2024-05-01');

      expect(result.length).assertEqual(2);
      expect(result[0].id).assertEqual('1');
      expect(result[1].id).assertEqual('2');
    });

    it('queryById should return the matching schedule and undefined for missing ids', 0, () => {
      DataManager.save([
        createSchedule('Weekly Review', '2024-05-03 10:00', '2024-05-03 11:00', '1')
      ]);

      const existing = DataManager.queryById('1');
      const missing = DataManager.queryById('404');

      expect(!!existing).assertEqual(true);
      if (existing) {
        expect(existing.title).assertEqual('Weekly Review');
      }
      expect(missing === undefined).assertEqual(true);
    });

    it('queryByName should return schedules whose title contains the keyword', 0, () => {
      DataManager.save([
        createSchedule('Project Review', '2024-05-03 09:00', '2024-05-03 10:00', '1'),
        createSchedule('Weekly Review', '2024-05-03 11:00', '2024-05-03 12:00', '2'),
        createSchedule('Budget Sync', '2024-05-03 13:00', '2024-05-03 14:00', '3')
      ]);

      const result = DataManager.queryByName('Review');

      expect(result.length).assertEqual(2);
      expect(result[0].title).assertContain('Review');
      expect(result[1].title).assertContain('Review');
    });

    it('queryScheduleDates should return all stored schedule start times', 0, () => {
      DataManager.save([
        createSchedule('Morning Standup', '2024-05-01 09:00', '2024-05-01 09:30', '1'),
        createSchedule('Design Review', '2024-05-02 15:00', '2024-05-02 16:00', '2')
      ]);

      const dates = DataManager.queryScheduleDates('2024-05-01', '2024-05-31');

      expect(dates.length).assertEqual(2);
      expect(dates[0]).assertEqual('2024-05-01 09:00');
      expect(dates[1]).assertEqual('2024-05-02 15:00');
    });

    it('deleteById should remove only the matching schedule', 0, () => {
      DataManager.save([
        createSchedule('Morning Standup', '2024-05-01 09:00', '2024-05-01 09:30', '1'),
        createSchedule('Design Review', '2024-05-02 15:00', '2024-05-02 16:00', '2')
      ]);

      DataManager.deleteById('1');

      const remaining = DataManager.loadAll();
      expect(remaining.length).assertEqual(1);
      expect(remaining[0].id).assertEqual('2');
      expect(DataManager.queryById('1') === undefined).assertEqual(true);
    });
  });
}
