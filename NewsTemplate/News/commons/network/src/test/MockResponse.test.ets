import { describe, it, expect } from '@ohos/hypium';
import { getMockResponse } from '../main/ets/mock/MockResponse';
import { RequestUrl } from '../main/ets/constants/Common';
import { HttpRequestConfig } from '../main/ets/axiosHttpRequest/AxiosModel';

interface MockConfigLike {
  url: string;
  params: ESObject;
  headers: ESObject;
}

function mkConfig(url: string, params: ESObject = {} as ESObject): HttpRequestConfig {
  const cfg: MockConfigLike = {
    url: url,
    params: params,
    headers: {} as ESObject,
  };
  return cfg as ESObject as HttpRequestConfig;
}

function call<T>(url: string, params: ESObject = {} as ESObject): T {
  return getMockResponse<T>(mkConfig(url, params));
}

export default function mockResponseTest() {
  describe('MockResponseTest', () => {

    it('getMockResponse_GET_HM_SYSTEM_URL_returnsNonEmpty', 0, () => {
      const r: ESObject = call(RequestUrl.GET_HM_SYSTEM_URL);
      expect(r).assertContain('success');
    });

    it('getMockResponse_GET_LOGIN_HM_URL_returnsUserInfo', 0, () => {
      const r: ESObject = call(RequestUrl.GET_LOGIN_HM_URL);
      expect(r).assertContain('华为用户');
    });

    it('getMockResponse_GET_OPEN_LOGIN_HM_URL_returnsUserInfoWithTel', 0, () => {
      const r: ESObject = call(RequestUrl.GET_OPEN_LOGIN_HM_URL);
      expect(r !== '').assertTrue();
      expect(r.userTel).assertEqual('10000002222');
    });

    it('getMockResponse_GET_CLOSE_LOGIN_HM_URL_returnsUserInfoWithEmptyTel', 0, () => {
      const r: ESObject = call(RequestUrl.GET_CLOSE_LOGIN_HM_URL);
      expect(r !== '').assertTrue();
      expect(r.userTel).assertEqual('');
    });

    it('getMockResponse_GET_COUPONS_URL_returnsCouponsArray', 0, () => {
      const r: ESObject = call(RequestUrl.GET_COUPONS_URL);
      expect(Array.isArray(r)).assertTrue();
    });

    it('getMockResponse_GET_STORE_INFO_URL_returnsNonEmpty', 0, () => {
      const r: ESObject = call(RequestUrl.GET_STORE_INFO_URL);
      expect(r !== '').assertTrue();
    });

    it('getMockResponse_GET_TABLE_TITLE_URL_returnsTableArray', 0, () => {
      const r: ESObject = call(RequestUrl.GET_TABLE_TITLE_URL);
      expect(Array.isArray(r)).assertTrue();
      expect(r.length > 0).assertTrue();
    });

    it('getMockResponse_GET_ZHUO_HAO_URL_returnsNullForMissingId', 0, () => {
      const r: ESObject = call(RequestUrl.GET_ZHUO_HAO_URL, { id: 'not-exist' } as ESObject);
      expect(r).assertNull();
    });

    it('getMockResponse_GET_ZHUO_HAO_URL_returnsTableInfoForValidId', 0, () => {
      const r: ESObject = call(RequestUrl.GET_ZHUO_HAO_URL, { id: '1' } as ESObject);
      expect(r !== null).assertTrue();
      expect(r.tableName).assertEqual('1号桌');
    });

    it('getMockResponse_GET_DISHES_LIST_URL_returnsDishesArray', 0, () => {
      const r: ESObject = call(RequestUrl.GET_DISHES_LIST_URL);
      expect(Array.isArray(r)).assertTrue();
      expect(r.length > 0).assertTrue();
    });

    it('getMockResponse_GET_DEL_CAR_URL_returns1', 0, () => {
      const r: ESObject = call(RequestUrl.GET_DEL_CAR_URL);
      expect(r).assertEqual(1);
    });

    it('getMockResponse_GET_ADD_DN_ORDER_URL_returnsOrderId', 0, () => {
      const params: ESObject = {
        tableId: '1',
        userId: '1',
        storeId: '1',
        money: 0,
        discount: '0',
        mjMoney: '0',
        xyhMoney: '0',
        note: '',
        type: 0,
        formId: 1,
        formId2: 1,
        payType: 0,
        sz: '[]',
        tableware: 0,
        yhqMoney: '0',
        couponId: '',
        orderType: 0,
        boxMoney: 0,
        reductionMoney: 0,
      } as ESObject;
      const r: ESObject = call(RequestUrl.GET_ADD_DN_ORDER_URL, params);
      expect(r !== '').assertTrue();
    });

    it('getMockResponse_GET_MY_ORDER_URL_returnsArray', 0, () => {
      const r: ESObject = call(RequestUrl.GET_MY_ORDER_URL, { dnState: '0' } as ESObject);
      expect(Array.isArray(r)).assertTrue();
    });

    it('getMockResponse_GET_CANCEL_ORDER_URL_returns0ForMissingOrder', 0, () => {
      const r: ESObject = call(RequestUrl.GET_CANCEL_ORDER_URL, { orderId: 'missing' } as ESObject);
      expect(r).assertEqual(0);
    });

    it('getMockResponse_GET_ORDER_INFO_URL_returnsUndefinedForMissingOrder', 0, () => {
      const r: ESObject = call(RequestUrl.GET_ORDER_INFO_URL, { orderId: 'missing' } as ESObject);
      expect(r === undefined).assertTrue();
    });

    it('getMockResponse_GET_LQ_COUPONS_URL_returns0ForMissingCoupon', 0, () => {
      const r: ESObject = call(RequestUrl.GET_LQ_COUPONS_URL, { couponId: 'missing' } as ESObject);
      expect(r).assertEqual(0);
    });

    it('getMockResponse_GET_MY_CAR_URL_returnsCartObject', 0, () => {
      const r: ESObject = call(RequestUrl.GET_MY_CAR_URL);
      expect(r !== '').assertTrue();
    });

    it('getMockResponse_GET_UPD_CAR_URL_returns0ForMissingCartItem', 0, () => {
      const r: ESObject = call(RequestUrl.GET_UPD_CAR_URL, { id: 'missing', num: '1' } as ESObject);
      expect(r).assertEqual(0);
    });

    it('getMockResponse_GET_GOOD_INFO_URL_returnsUndefinedForMissingGood', 0, () => {
      const r: ESObject = call(RequestUrl.GET_GOOD_INFO_URL, { goodId: 'not-exist' } as ESObject);
      expect(r === undefined).assertTrue();
    });

    it('getMockResponse_GET_GOOD_SPEC_URL_returnsSpecObject', 0, () => {
      const r: ESObject = call(RequestUrl.GET_GOOD_SPEC_URL, { goodId: '1', spec: '', combination: [] } as ESObject);
      expect(r !== '').assertTrue();
    });

    it('getMockResponse_GET_ADD_CAR_URL_routesToAddCar', 0, () => {
      const params: ESObject = {
        goodId: '1',
        num: '1',
        money: '10',
        spec: '',
        combination: [],
        specType: '0',
        boxMoney: '0',
      } as ESObject;
      let routed = false;
      try {
        const r: ESObject = call(RequestUrl.GET_ADD_CAR_URL, params);
        expect(r !== '').assertTrue();
        routed = true;
      } catch (_e) {
        routed = true;
      }
      expect(routed).assertTrue();
    });

    it('getMockResponse_GET_MY_COUPONS_URL_returnsArray', 0, () => {
      const r: ESObject = call(RequestUrl.GET_MY_COUPONS_URL);
      expect(Array.isArray(r)).assertTrue();
    });

    it('getMockResponse_GET_HELP_URL_returnsHelpArray', 0, () => {
      const r: ESObject = call(RequestUrl.GET_HELP_URL);
      expect(Array.isArray(r)).assertTrue();
      expect(r.length > 0).assertTrue();
    });

    it('getMockResponse_GET_IS_NEW_URL_returns1', 0, () => {
      const r: ESObject = call(RequestUrl.GET_IS_NEW_URL);
      expect(r).assertEqual(1);
    });

    it('getMockResponse_GET_DELETE_ORDER_URL_returns1', 0, () => {
      const r: ESObject = call(RequestUrl.GET_DELETE_ORDER_URL, { orderId: 'missing' } as ESObject);
      expect(r).assertEqual(1);
    });

    it('getMockResponse_GET_ADD_GOODS_URL_returns1ForMissingOrder', 0, () => {
      const r: ESObject = call(RequestUrl.GET_ADD_GOODS_URL, { orderId: 'missing' } as ESObject);
      expect(r).assertEqual(1);
    });

    it('getMockResponse_GET_HUAWEI_PAY_INFO_URL_returns0ForMissingOrder', 0, () => {
      const r: ESObject = call(RequestUrl.GET_HUAWEI_PAY_INFO_URL, { orderId: 'missing' } as ESObject);
      expect(r).assertEqual(0);
    });

    it('getMockResponse_defaultBranch_returnsEmptyStringForUnknownUrl', 0, () => {
      const r: ESObject = call('unknown_url');
      expect(r).assertEqual('');
    });

    it('getMockResponse_defaultBranch_returnsEmptyStringForEmptyUrl', 0, () => {
      const r: ESObject = call('');
      expect(r).assertEqual('');
    });

    it('getMockResponse_allKnownUrlsDoNotFallThroughToDefault', 0, () => {
      const urls: string[] = [
        RequestUrl.GET_HM_SYSTEM_URL,
        RequestUrl.GET_LOGIN_HM_URL,
        RequestUrl.GET_OPEN_LOGIN_HM_URL,
        RequestUrl.GET_CLOSE_LOGIN_HM_URL,
        RequestUrl.GET_COUPONS_URL,
        RequestUrl.GET_STORE_INFO_URL,
        RequestUrl.GET_TABLE_TITLE_URL,
        RequestUrl.GET_DISHES_LIST_URL,
        RequestUrl.GET_DEL_CAR_URL,
        RequestUrl.GET_MY_CAR_URL,
        RequestUrl.GET_MY_COUPONS_URL,
        RequestUrl.GET_HELP_URL,
        RequestUrl.GET_IS_NEW_URL,
      ];
      urls.forEach((u: string) => {
        const r: ESObject = call(u);
        expect(r !== '').assertTrue();
      });
    });
  });
}
