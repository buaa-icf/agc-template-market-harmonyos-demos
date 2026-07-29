import { beforeEach, describe, expect, it } from '@ohos/hypium';
import { DataManager } from '../../../main/ets/mock/DataManager';
import { ScheduleInfo } from '../../../main/ets/types/Types';

export default function dataManagerTest(): void {
  describe('ScheduleDataManagerTest', () => {
    beforeEach(async () => {
      await DataManager.save([]);
    });

    it('saveOne_should_cover_insert_and_update_paths', 0, () => {
      const inserted: ScheduleInfo = {
        title: 'inserted',
        startTime: '2026-07-29 09:00',
        endTime: '2026-07-29 10:00'
      };
      DataManager.saveOne(inserted);
      expect(inserted.id !== undefined).assertTrue();
      expect(DataManager.loadAll().length).assertEqual(1);

      const updated: ScheduleInfo = {
        id: inserted.id,
        title: 'updated',
        startTime: '2026-07-29 11:00',
        endTime: '2026-07-29 12:00'
      };
      DataManager.saveOne(updated);

      const stored: ScheduleInfo[] = DataManager.loadAll();
      expect(stored.length).assertEqual(1);
      expect(stored[0].title).assertEqual('updated');
    });

    it('saveOne_should_keep_other_items_when_updating', 0, () => {
      const first: ScheduleInfo = {
        id: 'first',
        title: 'first',
        startTime: '2026-07-29 09:00',
        endTime: '2026-07-29 10:00'
      };
      const second: ScheduleInfo = {
        id: 'second',
        title: 'second',
        startTime: '2026-07-29 11:00',
        endTime: '2026-07-29 12:00'
      };
      DataManager.saveOne(first);
      DataManager.saveOne(second);

      expect(DataManager.loadAll().length).assertEqual(2);
    });
  });
}
