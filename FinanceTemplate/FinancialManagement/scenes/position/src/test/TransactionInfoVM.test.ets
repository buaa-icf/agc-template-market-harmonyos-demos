import { afterEach, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { https } from 'network';
import {
  ITransactionInfo,
  ITransactionStatus,
  State
} from 'network/src/main/ets/types/responseTypes/GetTransactionRecordInfoResp';
import { TransactionInfoVM } from '../main/ets/viewModels/TransactionInfoVM';

interface TransactionResponse {
  code: number;
  data: ITransactionInfo;
}

function createInfo(type: number, statuses: ITransactionStatus[]): ITransactionInfo {
  return {
    id: 1,
    type,
    state: State.IN_PROGRESS,
    amount: 100,
    date: '2026-01-01',
    productName: 'Test product',
    productNumber: 'P-1',
    bankCardNumber: '****1234',
    status: statuses
  };
}

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
      const statuses: ITransactionStatus[] = [
        { status: 1, date: '2026-01-01 10:00' },
        { status: 2, date: '2026-01-02 10:00' },
        { status: 3, date: '2026-01-03 10:00' }
      ];
      const response: TransactionResponse = { code: 0, data: createInfo(2, statuses) };
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
      const statuses: ITransactionStatus[] = [
        { status: 4, date: '2026-01-04 10:00' },
        { status: 5, date: '2026-01-05 10:00' }
      ];
      const response: TransactionResponse = { code: 0, data: createInfo(3, statuses) };
      when(getTransactionRecordInfo)(102).afterReturn(Promise.resolve(response));
      const viewModel = new TransactionInfoVM();

      await viewModel.getTransactionRecordInfo(102);

      expect(viewModel.totalSize).assertEqual(2);
      expect(viewModel.timeLineList.length).assertEqual(2);
      expect(viewModel.timeLineList[0].nextNodeStatus).assertEqual(5);
    });

    it('leaves the current state unchanged when the request fails', 0, async () => {
      const getTransactionRecordInfo = mockKit.mockFunc(https, https.getTransactionRecordInfo);
      const response: TransactionResponse = {
        code: 1,
        data: createInfo(2, [])
      };
      when(getTransactionRecordInfo)(103).afterReturn(Promise.resolve(response));
      const viewModel = new TransactionInfoVM();

      await viewModel.getTransactionRecordInfo(103);

      expect(viewModel.transactionInfo).assertUndefined();
      expect(viewModel.timeLineList.length).assertEqual(0);
    });
  });
}
