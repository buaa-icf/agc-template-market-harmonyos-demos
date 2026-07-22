import { describe, expect, it } from '@ohos/hypium';
import { CommonUtils, GoodInfo } from 'module_base';
import { OrderVM } from '../main/ets/viewmodel/OrderVM';

export default function OrderVMTest() {
  describe('OrderVMTest', () => {
    it('returns the vip price when the good has no service option', 0, () => {
      const viewModel = OrderVM.instance(true);
      const good = new GoodInfo();
      good.vipPrice = 88;
      good.serviceDetailList = [];
      viewModel.goodInfo = good;

      expect(viewModel.getTotalCash()).assertEqual(good.vipPrice.toString());
    });

    it('calculates the selected service price including its extra count', 0, () => {
      const viewModel = OrderVM.instance(true);
      const good = new GoodInfo();
      good.vipPrice = 88;
      good.serviceDetailList = [{ prices: [{ count: 2, price: 30, extraCount: 2 }] }] as never;
      viewModel.goodInfo = good;
      viewModel.selectServiceOutIndex = 0;
      viewModel.selectServiceInsideIndex = 0;

      expect(viewModel.getTotalCash()).assertEqual(CommonUtils.handleCash(120));
    });
  });
}
