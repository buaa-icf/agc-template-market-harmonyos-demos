/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { describe, it, expect } from '@ohos/hypium';
import { PracticeDataSource, PracticeMode, SubjectExercises } from '../../../main/ets/viewModel/PracticeMode';

class MockDataChangeListener implements DataChangeListener {
  public reloadCount: number = 0;
  public addIndexes: number[] = [];
  public changeIndexes: number[] = [];
  public deleteIndexes: number[] = [];
  public movePairs: Array<number[]> = [];

  onDataReloaded(): void {
    this.reloadCount++;
  }

  onDataAdd(index: number): void {
    this.addIndexes.push(index);
  }

  onDataChange(index: number): void {
    this.changeIndexes.push(index);
  }

  onDataDelete(index: number): void {
    this.deleteIndexes.push(index);
  }

  onDataMove(from: number, to: number): void {
    this.movePairs.push([from, to]);
  }

  onDataAdded(index: number): void {
    this.onDataAdd(index);
  }

  onDataMoved(from: number, to: number): void {
    this.onDataMove(from, to);
  }

  onDataDeleted(index: number): void {
    this.onDataDelete(index);
  }

  onDataChanged(index: number): void {
    this.onDataChange(index);
  }

  onDatasetChange(dataOperations: DataOperation[]): void {
    this.reloadCount += dataOperations.length;
  }
}

export default function practiceModeTest() {
  describe('PracticeModeInstrumentTest', () => {
    it('PracticeMode_constructor_should_store_fields', 0, () => {
      const item: PracticeMode = new PracticeMode('mock://practice_icon', 'daily', '1/100');
      expect(item.imageSrc).assertEqual('mock://practice_icon');
      expect(item.name).assertEqual('daily');
      expect(item.describe).assertEqual('1/100');
    });

    it('SubjectExercises_constructor_should_store_fields', 0, () => {
      const item: SubjectExercises = new SubjectExercises('mock://subject_icon', 'subject_a', 3, 10);
      expect(item.imageSrc).assertEqual('mock://subject_icon');
      expect(item.name).assertEqual('subject_a');
      expect(item.progress).assertEqual(3);
      expect(item.total).assertEqual(10);
    });

    it('PracticeDataSource_basic_data_should_match_input', 0, () => {
      const input: PracticeMode[] = [
        new PracticeMode('mock://icon_1', 'p1', 'd1'),
        new PracticeMode('mock://icon_2', 'p2', 'd2')
      ];
      const dataSource: PracticeDataSource = new PracticeDataSource(input);

      expect(dataSource.totalCount()).assertEqual(2);
      expect(dataSource.getData(0).name).assertEqual('p1');
      expect(dataSource.getData(1).describe).assertEqual('d2');
    });

    it('PracticeDataSource_notify_should_call_registered_listener', 0, () => {
      const dataSource: PracticeDataSource = new PracticeDataSource([]);
      const listener: MockDataChangeListener = new MockDataChangeListener();

      dataSource.registerDataChangeListener(listener);
      dataSource.notifyDataReload();
      dataSource.notifyDataAdd(3);
      dataSource.notifyDataChange(5);
      dataSource.notifyDataDelete(1);
      dataSource.notifyDataMove(2, 4);

      expect(listener.reloadCount).assertEqual(1);
      expect(listener.addIndexes.length).assertEqual(1);
      expect(listener.addIndexes[0]).assertEqual(3);
      expect(listener.changeIndexes[0]).assertEqual(5);
      expect(listener.deleteIndexes[0]).assertEqual(1);
      expect(listener.movePairs.length).assertEqual(1);
      expect(listener.movePairs[0][0]).assertEqual(2);
      expect(listener.movePairs[0][1]).assertEqual(4);
    });

    it('PracticeDataSource_unregister_should_stop_listener_notification', 0, () => {
      const dataSource: PracticeDataSource = new PracticeDataSource([]);
      const listener: MockDataChangeListener = new MockDataChangeListener();

      dataSource.registerDataChangeListener(listener);
      dataSource.unregisterDataChangeListener(listener);
      dataSource.notifyDataReload();
      dataSource.notifyDataAdd(0);

      expect(listener.reloadCount).assertEqual(0);
      expect(listener.addIndexes.length).assertEqual(0);
    });

    it('PracticeDataSource_register_same_listener_once_only', 0, () => {
      const dataSource: PracticeDataSource = new PracticeDataSource([]);
      const listener: MockDataChangeListener = new MockDataChangeListener();

      dataSource.registerDataChangeListener(listener);
      dataSource.registerDataChangeListener(listener);
      dataSource.notifyDataReload();

      expect(listener.reloadCount).assertEqual(1);
    });
  });
}
