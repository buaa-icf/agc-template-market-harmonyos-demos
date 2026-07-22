import { afterEach, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { https } from 'network';
import { State } from 'network/src/main/ets/types/responseTypes/GetTransactionRecordInfoResp';
import { TransactionInfoVM } from '../main/ets/viewModels/TransactionInfoVM';

export default function TransactionInfoVMTest() {
  describe('TransactionInfoVMTest', () => {
    let mockKit: MockKit;

    beforeEach(() => {
      mockKit = new MockKit();
    });

    afterEach(() => {
      mockKit.clear(https);
    });

    it('maps an in-progress purchase record into its three timeline nodes', 0, async () => {
      const getTransactionRecordInfo = mockKit.mockFunc(https, https.getTransactionRecordInfo);
      const response = {
        code: 0,
        data: {
          state: State.IN_PROGRESS,
          type: 2,
          status: [
            { status: 1, date: '2026-01-01 10:00' },
            { status: 2, date: '2026-01-02 10:00' },
            { status: 3, date: '2026-01-03 10:00' }
          ]
        }
      };
      when(getTransactionRecordInfo)(101).afterReturn(Promise.resolve(response));
      const viewModel = new TransactionInfoVM();

      await viewModel.getTransactionRecordInfo(101);

      expect(viewModel.totalSize).assertEqual(3);
      expect(viewModel.timeLineList.length).assertEqual(3);
      expect(viewModel.timeLineList[0].nodeStatus).assertEqual(1);
      expect(viewModel.timeLineList[0].nextNodeStatus).assertEqual(2);
      expect(viewModel.timeLineList[2].nodeStatus).assertEqual(3);
    });

    it('maps an in-progress redemption record into its two timeline nodes', 0, async () => {
      const getTransactionRecordInfo = mockKit.mockFunc(https, https.getTransactionRecordInfo);
      const response = {
        code: 0,
        data: {
          state: State.IN_PROGRESS,
          type: 3,
          status: [
            { status: 4, date: '2026-01-04 10:00' },
            { status: 5, date: '2026-01-05 10:00' }
          ]
        }
      };
      when(getTransactionRecordInfo)(102).afterReturn(Promise.resolve(response));
      const viewModel = new TransactionInfoVM();

      await viewModel.getTransactionRecordInfo(102);

      expect(viewModel.totalSize).assertEqual(2);
      expect(viewModel.timeLineList.length).assertEqual(2);
      expect(viewModel.timeLineList[0].nextNodeStatus).assertEqual(5);
    });
  });
}
