import { describe, expect, it } from '@ohos/hypium';
import {
  ExpressStatus,
  IAddrInfo,
  ICourier,
  IGoods,
  ILogisticsInfo,
  IOrderInfo,
  IPosition,
  OrderStatus,
  OrderType,
  PaymentMethod,
  ShippingMethod
} from 'lib_foundation';
import { OrderInfoPageVM } from '../main/ets/viewModels/OrderInfoPageVM';

function createAddress(id: number): IAddrInfo {
  return {
    id,
    name: `contact-${id}`,
    cellphone: '13800000000',
    province: 'province',
    city: 'city',
    area: 'area',
    detailAddress: `address-${id}`,
    isDefault: false
  };
}

function createPosition(latitude: number, longitude: number): IPosition {
  return {
    latitude,
    longitude
  };
}

function createOrderInfo(): IOrderInfo {
  const goods: IGoods = {
    id: 1,
    name: 'box',
    weight: 2
  };
  const courier: ICourier = {
    name: 'courier',
    cellphone: '13900000000'
  };
  const logisticsInfo: ILogisticsInfo[] = [];
  return {
    id: 1,
    type: OrderType.SEND,
    status: OrderStatus.DO_ING,
    expressStatus: ExpressStatus.IN_TRANSIT,
    price: 12,
    companyName: 'company',
    goods,
    sendAddress: createAddress(1),
    getAddress: createAddress(2),
    sendPosition: 'send',
    getPosition: 'get',
    orderNo: 'NO1',
    courier,
    logisticsInfo,
    origins: createPosition(31.97, 118.75),
    destination: createPosition(31.98, 118.76),
    waypoints: [],
    shippingMethod: ShippingMethod.PICK_UP_AT_HOME,
    day: 'today',
    time: '09:00',
    paymentMethod: PaymentMethod.PAY_NOW,
    mailCode: 100000
  };
}

export default function OrderInfoPageVMTest() {
  describe('OrderInfoPageVMTest', () => {
    it('clears the detail record without discarding the reusable view model', 0, () => {
      const viewModel = new OrderInfoPageVM();
      viewModel.orderInfo = createOrderInfo();

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
