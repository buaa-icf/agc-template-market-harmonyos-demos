import { describe, expect, it } from '@ohos/hypium';
import { BalanceChangeType, BalanceResourceItemModel, BalanceResourceModel } from 'bill_base';
import { ResourceManageVM } from '../main/ets/viewmodels/ResourceManageVM';

function createResourceItem(key: number, name: string, sortNum: number): BalanceResourceItemModel {
  const item = new BalanceResourceItemModel();
  item.key = key;
  item.name = name;
  item.type = BalanceChangeType.EXPENSE;
  item.sortNum = sortNum;
  return item;
}

function createResource(): BalanceResourceModel {
  const resource = new BalanceResourceModel();
  resource.expense = [
    createResourceItem(1, 'Food', 10),
    createResourceItem(2, 'Travel', 20)
  ];
  return resource;
}

export default function ResourceManageVMTest() {
  describe('ResourceManageVMTest', () => {
    it('moves two custom resources while retaining their sort numbers', 0, () => {
      const viewModel = new ResourceManageVM();
      viewModel.balanceType = BalanceChangeType.EXPENSE;
      viewModel.resource = createResource();

      viewModel.customSortResource(0, 1);

      expect(viewModel.resource!.expense[0].key).assertEqual(2);
      expect(viewModel.resource!.expense[0].sortNum).assertEqual(10);
      expect(viewModel.resource!.expense[1].key).assertEqual(1);
      expect(viewModel.resource!.expense[1].sortNum).assertEqual(20);
    });

    it('leaves the list unchanged when the destination index is outside the list', 0, () => {
      const viewModel = new ResourceManageVM();
      viewModel.resource = createResource();

      viewModel.customSortResource(0, 3);

      expect(viewModel.resource!.expense[0].key).assertEqual(1);
      expect(viewModel.resource!.expense[1].key).assertEqual(2);
    });
  });
}
