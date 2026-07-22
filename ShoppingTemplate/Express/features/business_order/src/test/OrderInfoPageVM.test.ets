import { describe, expect, it } from '@ohos/hypium';
import { OrderInfoPageVM } from '../main/ets/viewModels/OrderInfoPageVM';

export default function OrderInfoPageVMTest() {
  describe('OrderInfoPageVMTest', () => {
    it('clears the detail record without discarding the reusable view model', 0, () => {
      const viewModel = new OrderInfoPageVM();
      viewModel.orderInfo = { logisticsInfo: [] } as never;

      viewModel.clear();

      expect(viewModel.orderInfo).assertUndefined();
    });

    it('does not request a driving route before order information is loaded', 0, async () => {
      const viewModel = new OrderInfoPageVM();

      await viewModel.testDrivingRoutes();

      expect(viewModel.orderInfo).assertUndefined();
    });
  });
}
