import { describe, expect, it } from '@ohos/hypium';
import { CommonUtils, GoodInfo, IServiceDetail, IServiceDetailItem } from 'module_base';
import { OrderVM } from '../main/ets/viewmodel/OrderVM';

export default function OrderVMTest() {
  describe('OrderVMTest', () => {
    it('returns the vip price when the good has no service option', 0, () => {
      const viewModel: OrderVM = OrderVM.instance(true) as OrderVM;
      const good: GoodInfo = new GoodInfo();
      good.vipPrice = 88;
      good.serviceDetailList = [];
      viewModel.goodInfo = good;

      expect(viewModel.getTotalCash()).assertEqual(good.vipPrice.toString());
    });

    it('calculates the selected service price including its extra count', 0, () => {
      const viewModel: OrderVM = OrderVM.instance(true) as OrderVM;
      const good: GoodInfo = new GoodInfo();
      good.vipPrice = 88;
      const serviceItem: IServiceDetailItem = {
        desc: 'standard',
        count: 2,
        price: 30,
        extraCount: 2
      };
      const serviceDetail: IServiceDetail = {
        title: 'cleaning',
        subTitle: 'standard',
        prices: [serviceItem]
      };
      good.serviceDetailList = [serviceDetail];
      viewModel.goodInfo = good;
      viewModel.selectServiceOutIndex = 0;
      viewModel.selectServiceInsideIndex = 0;

      expect(viewModel.getTotalCash()).assertEqual(CommonUtils.handleCash(120));
    });

    it('falls back to the vip price when the selected service item is missing', 0, () => {
      const viewModel: OrderVM = OrderVM.instance(true) as OrderVM;
      const good: GoodInfo = new GoodInfo();
      good.vipPrice = 88;
      const serviceDetail: IServiceDetail = {
        title: 'cleaning',
        subTitle: 'standard',
        prices: []
      };
      good.serviceDetailList = [serviceDetail];
      viewModel.goodInfo = good;
      viewModel.selectServiceOutIndex = 0;
      viewModel.selectServiceInsideIndex = 0;

      expect(viewModel.getTotalCash()).assertEqual(CommonUtils.handleCash(88));
    });

    it('falls back to the vip price when the selected service group is invalid', 0, () => {
      const viewModel: OrderVM = OrderVM.instance(true) as OrderVM;
      const good: GoodInfo = new GoodInfo();
      good.vipPrice = 88;
      const serviceDetail: IServiceDetail = {
        title: 'cleaning',
        subTitle: 'standard',
        prices: []
      };
      good.serviceDetailList = [serviceDetail];
      viewModel.goodInfo = good;
      viewModel.selectServiceOutIndex = 1;
      viewModel.selectServiceInsideIndex = 0;

      expect(viewModel.getTotalCash()).assertEqual(CommonUtils.handleCash(88));
    });
  });
}
