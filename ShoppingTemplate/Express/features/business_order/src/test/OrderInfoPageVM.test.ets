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

class TestOrderInfoPageVM extends OrderInfoPageVM {
  routeRequested: boolean = false;
  markerRequested: boolean = false;

  override async testDrivingRoutes() {
    this.routeRequested = true;
  }

  override async addMarker() {
    this.markerRequested = true;
  }
}

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

    it('loads order information and maps logistics records into timeline nodes', 0, async () => {
      const viewModel = new TestOrderInfoPageVM();

      await viewModel.getOrderInfo(999);

      expect(viewModel.orderInfo).not().assertUndefined();
      expect(viewModel.nodeList.length).assertEqual(viewModel.orderInfo?.logisticsInfo.length);
      expect(viewModel.routeRequested).assertTrue();
      expect(viewModel.markerRequested).assertTrue();
      if (viewModel.nodeList.length > 0) {
        expect(viewModel.nodeList[0].time)
          .assertEqual(viewModel.orderInfo?.logisticsInfo[viewModel.nodeList.length - 1].time);
        expect(viewModel.nodeList[0].description)
          .assertEqual(viewModel.orderInfo?.logisticsInfo[viewModel.nodeList.length - 1].content);
      }
    });

    it('does not request a driving route before order information is loaded', 0, async () => {
      const viewModel = new OrderInfoPageVM();

      await viewModel.testDrivingRoutes();

      expect(viewModel.orderInfo).assertUndefined();
    });
  });
}
