import { beforeEach, describe, expect, it } from '@ohos/hypium';
import { HttpRequestConfig } from '../main/ets/axiosHttpRequest/AxiosModel';
import { OrderStateEnum, OrderTypeEnum, RequestUrl } from '../main/ets/constants/Common';
import { getMockResponse } from '../main/ets/mock/MockResponse';
import { MockData } from '../main/ets/mock/MockData';
import { AddDnOrderReq } from '../main/ets/models/RequestModel';
import {
  AddressInfo,
  BaseResponse,
  CouponResp,
  DishesType,
  Good,
  GoodSpecInfo,
  HmSystem,
  MyCar,
  MyCoupon,
  MyOrderInfo,
  StoreInfo,
  UserInfo
} from '../main/ets/models/ResponseModel';

function buildConfig(url: string, params?: ESObject): HttpRequestConfig {
  return {
    url,
    params,
    headers: {},
  } as HttpRequestConfig;
}

function resetUserInfo() {
  let userInfo = new UserInfo();
  userInfo.id = '1';
  userInfo.name = '华为用户';
  userInfo.sex = 0;
  userInfo.totalScore = '1074';
  userInfo.sixProcess = 2;
  userInfo.level = 1;
  userInfo.userTel = '';
  MockData.userInfo = userInfo;
}

function resetMockData() {
  resetUserInfo();
  MockData.myCoupons = [];
  MockData.couponsOri.forEach((item: CouponResp) => {
    item.state = 0;
  });
  MockData.myCar = new MyCar(0, [], 0, 0);
  MockData.myCarId = 0;
  MockData.orderList = [MockData.initOrderList()];
  MockData.orderId = 2;
  MockData.addressList = [];
  MockData.initAddress = false;
}

function createOrderParams(orderType: number = OrderTypeEnum.PICK_SELF): AddDnOrderReq {
  return {
    userId: '1',
    storeId: '1',
    money: 16.4,
    mjMoney: '0',
    xyhMoney: '0',
    note: '少冰',
    type: 0,
    formId: 1,
    formId2: 1,
    payType: 1,
    sz: JSON.stringify([{
      id: '0',
      goodId: '1',
      img: 'TeaDrinkOrders/good_logo1.png',
      money: '16.4',
      name: '甜橙美式咖啡',
      num: 1,
      spec: '',
      specType: '1',
      combination: [],
    }]),
    cutlery: '1',
    yhqMoney: '0',
    couponId: '',
    orderType,
    boxMoney: 1,
    bagMoney: 0,
    storeName: '店铺名称（宜悦城）',
    address: '南京市雨花台区华为路华为云楼',
    tel: '10000000002',
    coordinates: '31.97919489020034,118.76224773565536',
    addressPre: '雨花客厅',
    addressNum: 'D1栋1001',
    latitude: 31.9789782,
    longitude: 118.7641445,
    addressName: '索先生',
    addressTel: '10000000005',
  };
}

export default function MockResponseTest() {
  describe('MockResponseTest', () => {
    beforeEach(() => {
      resetMockData();
    });

    it('should return fixed mock payloads for static request urls', 0, () => {
      let hmSystemResp = getMockResponse<BaseResponse<HmSystem>>(buildConfig(RequestUrl.GET_HM_SYSTEM_URL));
      expect(hmSystemResp.code).assertEqual(0);
      expect(hmSystemResp.data.tel).assertEqual('10000000000');

      let couponsResp = getMockResponse<CouponResp[]>(buildConfig(RequestUrl.GET_COUPONS_URL));
      expect(couponsResp.length).assertEqual(6);
      expect(couponsResp[0].name).assertEqual('新人优惠券');

      let storeListResp = getMockResponse<BaseResponse<Array<StoreInfo>>>(buildConfig(RequestUrl.GET_STORE_LIST_URL));
      expect(storeListResp.code).assertEqual(0);
      expect(storeListResp.data.length).assertEqual(3);
      expect(storeListResp.data[1].name).assertEqual('店铺名称（雨花客厅店）');

      let dishesListResp = getMockResponse<Array<DishesType>>(buildConfig(RequestUrl.GET_DISHES_LIST_URL));
      expect(dishesListResp.length).assertEqual(12);
      expect(dishesListResp[0].good.length).assertEqual(4);

      let privacyResp = getMockResponse<BaseResponse<string>>(buildConfig(RequestUrl.GET_PRIVACY_INFO));
      expect(privacyResp.code).assertEqual(0);
      expect(privacyResp.data).assertContain('隐私声明');

      let unknownResp = getMockResponse<string>(buildConfig('unknownUrl'));
      expect(unknownResp).assertEqual('');
    });

    it('should route user related urls and update login state', 0, () => {
      let loginResp = getMockResponse<BaseResponse<UserInfo>>(buildConfig(RequestUrl.GET_LOGIN_HM_URL));
      expect(loginResp.code).assertEqual(0);
      expect(loginResp.data.name).assertEqual('华为用户');

      let modifyUserInfoResp = getMockResponse<BaseResponse<UserInfo>>(buildConfig(RequestUrl.MODIFY_USER_INFO, {
        name: '测试用户',
        sex: 1,
      } as ESObject));
      expect(modifyUserInfoResp.code).assertEqual(0);
      expect(modifyUserInfoResp.data.name).assertEqual('测试用户');
      expect(modifyUserInfoResp.data.sex).assertEqual(1);

      let openLoginResp = getMockResponse<BaseResponse<UserInfo>>(buildConfig(RequestUrl.GET_OPEN_LOGIN_HM_URL));
      expect(openLoginResp.code).assertEqual(0);
      expect(openLoginResp.data.userTel).assertEqual('10000000001');

      let closeLoginResp = getMockResponse<UserInfo>(buildConfig(RequestUrl.GET_CLOSE_LOGIN_HM_URL));
      expect(closeLoginResp.userTel).assertEqual('');
    });

    it('should route store and good lookup urls with params', 0, () => {
      let storeInfoResp = getMockResponse<StoreInfo>(buildConfig(RequestUrl.GET_STORE_INFO_URL, {
        storeId: '2',
      } as ESObject));
      expect(storeInfoResp.id).assertEqual('2');
      expect(storeInfoResp.name).assertEqual('店铺名称（雨花客厅店）');

      let goodInfoResp = getMockResponse<Good | undefined>(buildConfig(RequestUrl.GET_GOOD_INFO_URL, {
        goodId: '1',
      } as ESObject));
      expect(goodInfoResp?.id || '').assertEqual('1');
      expect(goodInfoResp?.spec?.length || 0).assertEqual(3);

      let goodSpecResp =
        getMockResponse<BaseResponse<GoodSpecInfo | undefined>>(buildConfig(RequestUrl.GET_GOOD_SPEC_URL, {
          goodId: '1',
          spec: '6寸',
          combination: [],
        } as ESObject));
      expect(goodSpecResp.code).assertEqual(0);
      expect(goodSpecResp.data?.money || '').assertEqual('16.4');
      expect(goodSpecResp.data?.goodName || '').assertEqual('甜橙美式咖啡');
    });

    it('should route cart urls for reading and clearing cart state', 0, () => {
      MockData.myCar.boxMoney = 1;
      MockData.myCar.num = 1;
      MockData.myCar.money = 16.4;
      let myCarResp = getMockResponse<MyCar>(buildConfig(RequestUrl.GET_MY_CAR_URL));
      expect(myCarResp.num || 0).assertEqual(1);
      expect(myCarResp.money || 0).assertEqual(16.4);
      expect(myCarResp.boxMoney || 0).assertEqual(1);

      let cleanCarResp = getMockResponse<number>(buildConfig(RequestUrl.GET_DEL_CAR_URL));
      expect(cleanCarResp).assertEqual(1);

      let clearedCarResp = getMockResponse<MyCar>(buildConfig(RequestUrl.GET_MY_CAR_URL));
      expect(clearedCarResp.carGoods.length).assertEqual(0);
      expect(clearedCarResp.money || 0).assertEqual(0);
    });

    it('should route order urls for creating, querying, canceling and deleting orders', 0, () => {
      let orderId = getMockResponse<string>(buildConfig(RequestUrl.GET_ADD_DN_ORDER_URL, createOrderParams() as ESObject));
      expect(orderId).assertEqual('2');

      let orderInfoResp = getMockResponse<MyOrderInfo | undefined>(buildConfig(RequestUrl.GET_ORDER_INFO_URL, {
        orderId,
      } as ESObject));
      expect(orderInfoResp ? orderInfoResp.order.state : -1).assertEqual(OrderStateEnum.TO_BE_PAID);

      let cancelOrderResp = getMockResponse<BaseResponse>(buildConfig(RequestUrl.GET_CANCEL_ORDER_URL, {
        orderId,
      } as ESObject));
      expect(cancelOrderResp.code).assertEqual(0);

      let canceledOrderResp = getMockResponse<MyOrderInfo | undefined>(buildConfig(RequestUrl.GET_ORDER_INFO_URL, {
        orderId,
      } as ESObject));
      expect(canceledOrderResp?.order.state || -1).assertEqual(OrderStateEnum.CANCELED);

      let deleteOrderResp = getMockResponse<BaseResponse>(buildConfig(RequestUrl.GET_DELETE_ORDER_URL, {
        orderId,
      } as ESObject));
      expect(deleteOrderResp.code).assertEqual(0);

      let deletedOrderResp = getMockResponse<MyOrderInfo | undefined>(buildConfig(RequestUrl.GET_ORDER_INFO_URL, {
        orderId,
      } as ESObject));
      expect(deletedOrderResp ? 'exists' : 'deleted').assertEqual('deleted');
    });

    it('should route coupon and address urls with mutable params', 0, () => {
      let lqCouponsResp = getMockResponse<BaseResponse>(buildConfig(RequestUrl.LQ_COUPONS_URL, {
        couponId: '1',
      } as ESObject));
      expect(lqCouponsResp.code).assertEqual(0);

      let myCouponsResp = getMockResponse<BaseResponse<Array<MyCoupon>>>(buildConfig(RequestUrl.GET_MY_COUPONS_URL));
      expect(myCouponsResp.code).assertEqual(0);
      expect(myCouponsResp.data.length).assertEqual(1);
      expect(myCouponsResp.data[0].couponId).assertEqual('1');

      let addressListResp =
        getMockResponse<BaseResponse<Array<AddressInfo>>>(buildConfig(RequestUrl.GET_USER_ADDRESS_LIST));
      expect(addressListResp.code).assertEqual(0);
      expect(addressListResp.data.length).assertEqual(3);

      let userAddressResp = getMockResponse<BaseResponse<AddressInfo | undefined>>(buildConfig(RequestUrl.GET_USER_ADDRESS, {
        id: 1,
      } as ESObject));
      expect(userAddressResp.code).assertEqual(0);
      expect(userAddressResp.data?.name || '').assertEqual('索先生');

      let modifyAddressResp = getMockResponse<BaseResponse>(buildConfig(RequestUrl.MODIFY_USER_ADDRESS, {
        id: 1,
        addressPre: '软件大道',
        addressNum: 'A1-1001',
        name: '张三',
        sex: false,
        tel: '13800000000',
        tag: 2,
        latitude: 31.1,
        longitude: 118.1,
      } as ESObject));
      expect(modifyAddressResp.code).assertEqual(0);

      let updatedAddressResp =
        getMockResponse<BaseResponse<AddressInfo | undefined>>(buildConfig(RequestUrl.GET_USER_ADDRESS, {
          id: 1,
        } as ESObject));
      expect(updatedAddressResp.data?.name || '').assertEqual('张三');
      expect(updatedAddressResp.data?.addressPre || '').assertEqual('软件大道');

      let deleteAddressResp = getMockResponse<BaseResponse>(buildConfig(RequestUrl.DELETE_USER_ADDRESS, {
        id: 1,
      } as ESObject));
      expect(deleteAddressResp.code).assertEqual(0);

      let remainingAddressResp =
        getMockResponse<BaseResponse<Array<AddressInfo>>>(buildConfig(RequestUrl.GET_USER_ADDRESS_LIST));
      expect(remainingAddressResp.data.length).assertEqual(2);
    });
  });
}
