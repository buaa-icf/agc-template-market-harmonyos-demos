import { afterAll, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { TransactionDatasetMock } from '../../../main/ets/mocks/mockData/TransactionDatasetMock';
import { ITransactionItem } from '../../../main/ets/types/responseTypes/GetTransactionRecordListResp';

const CONTROLLED_TRANSACTIONS: ITransactionItem[] = [
  {
    id: 1,
    type: 2,
    amount: 100,
    share: 10,
    date: '2026-07-01',
    productName: 'Alpha Product',
    bankCardNo: '1001'
  },
  {
    id: 2,
    type: 3,
    amount: 200,
    share: 20,
    date: '2026-07-02',
    productName: 'Alpha Plus',
    bankCardNo: '1002'
  },
  {
    id: 1,
    type: 2,
    amount: 100,
    share: 10,
    date: '2026-07-01',
    productName: 'Alpha Product',
    bankCardNo: '1001'
  },
  {
    id: 3,
    type: 2,
    amount: 300,
    share: 30,
    date: '2026-06-01',
    productName: 'Beta Product',
    bankCardNo: '1003'
  }
];

export default function TransactionDatasetMockTest() {
  describe('TransactionDatasetMockTest', () => {
    let originalTransactions: ITransactionItem[] = [];

    beforeAll(() => {
      originalTransactions = TransactionDatasetMock.transactionList;
    });

    beforeEach(() => {
      TransactionDatasetMock.transactionList = CONTROLLED_TRANSACTIONS.slice();
    });

    afterAll(() => {
      TransactionDatasetMock.transactionList = originalTransactions;
    });

    it('groups searched transactions by month and skips duplicate ids', 0, () => {
      const response = TransactionDatasetMock.getMonthTransactionList({
        userId: 1,
        searchText: 'Product'
      });

      expect(response.code).assertEqual(0);
      expect(response.data.length).assertEqual(2);
      expect(response.data[0].month).assertEqual('2026-07');
      expect(response.data[0].transactionList.length).assertEqual(1);
      expect(response.data[1].month).assertEqual('2026-06');
      expect(response.data[1].transactionList.length).assertEqual(1);
    });

    it('groups all transactions into distinct months', 0, () => {
      const response = TransactionDatasetMock.getMonthTransactionList({
        userId: 1
      });

      expect(response.code).assertEqual(0);
      expect(response.data.length).assertEqual(2);
      expect(response.data[0].transactionList.length).assertEqual(2);
      expect(response.data[1].transactionList.length).assertEqual(1);
    });

    it('filters grouped transactions by transaction type', 0, () => {
      const response = TransactionDatasetMock.getMonthTransactionList({
        userId: 1,
        transactionType: 2
      });

      expect(response.code).assertEqual(0);
      for (let monthIndex: number = 0; monthIndex < response.data.length; monthIndex++) {
        const transactions = response.data[monthIndex].transactionList;
        for (let itemIndex: number = 0; itemIndex < transactions.length; itemIndex++) {
          expect(transactions[itemIndex].type).assertEqual(2);
        }
      }
    });

    it('handles every transaction date filter', 0, () => {
      for (let transactionDate: number = 1; transactionDate <= 4; transactionDate++) {
        const response = TransactionDatasetMock.getMonthTransactionList({
          userId: 1,
          transactionDate: transactionDate
        });
        expect(response.code).assertEqual(0);
      }
    });
  });
}
