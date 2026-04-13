import { describe, beforeEach, it, expect } from '@ohos/hypium';
import { AxiosRequestHeaders } from '@ohos/axios';
import { RequestUrl } from '../main/ets/constants/Common';
import { getMockResponse, HttpRequestConfig } from '../main/ets/httprequest/AxiosHttp';
import { MockData } from '../main/ets/mock/MockData';
import { CommonReq } from '../main/ets/models/RequestModel';
import { BaseResponse, PayRecord, PlateNumber, ShoppingMall, StoreGuide, UserInfo, Wallet } from '../main/ets/models/ResponseModel';

function createConfig(url: string, params?: CommonReq): HttpRequestConfig {
  return {
    url,
    headers: {} as AxiosRequestHeaders,
    params: params ?? {} as CommonReq,
  } as HttpRequestConfig;
}

function createPayRecord(time: string): PayRecord {
  return new PayRecord({
    plate: '苏DDDDDD',
    money: '7.5',
    carStatue: 0,
    payStatue: 3,
    address: '商场停车场',
    parkingTime: 3000,
    entryTime: new Date(time).getTime(),
    exitTime: new Date(time).getTime(),
    payTime: new Date(time).getTime(),
  });
}

function resetMockDataState(): void {
  MockData.resultSuccess = new BaseResponse(0, 'success', undefined);
  MockData.resultFailed = new BaseResponse(1, 'failed', undefined);
  MockData.plateNumberList = [
    new PlateNumber('1', '苏A55WW2', '1'),
    new PlateNumber('2', '苏A55WW33', '2'),
    new PlateNumber('3', '苏A55WW44', '3')
  ];
  MockData.payRecordList = [
    createPayRecord('2025-05-25'),
    createPayRecord('2025-04-25'),
    createPayRecord('2025-03-25')
  ];
  MockData.plateNumberId = 3;
  MockData.plateNum = 999;
  MockData.userInfo = new UserInfo('1', '华为用户', '');
}

export default function AxiosHttpTest() {
  describe('AxiosHttpTest', () => {
    beforeEach(() => {
      resetMockDataState();
    });

    it('returns base mock responses for shopping mall and user info urls', 0, () => {
      let shoppingMallResp = getMockResponse<BaseResponse<ShoppingMall>>(createConfig(RequestUrl.GET_SHOPPING_MALL_INFO_URL));
      expect(shoppingMallResp.code).assertEqual(0);
      expect(shoppingMallResp.msg).assertEqual('success');
      expect(shoppingMallResp.data.name).assertEqual('商场模板');
      expect(shoppingMallResp.data.plateNum).assertEqual('999');

      let userInfoResp = getMockResponse<BaseResponse<UserInfo>>(createConfig(RequestUrl.GET_USER_INFO));
      expect(userInfoResp.code).assertEqual(0);
      expect(userInfoResp.data.id).assertEqual('1');
      expect(userInfoResp.data.name).assertEqual('华为用户');
      expect(userInfoResp.data.userTel).assertEqual('');

      let queryPlateResp = getMockResponse<BaseResponse<PlateNumber[]>>(createConfig(RequestUrl.QUERY_PLATE_NUMBER));
      expect(queryPlateResp.code).assertEqual(0);
      expect(queryPlateResp.data.length).assertEqual(3);
      expect(queryPlateResp.data[0].plate).assertEqual('苏A55WW2');
    });

    it('dispatches plate number operations to the matching mock handlers', 0, () => {
      let addParams = {
        plate: '苏A00001',
        type: '1',
        plateKind: 2,
      } as CommonReq;
      let addResp = getMockResponse<BaseResponse>(createConfig(RequestUrl.ADD_PLATE_NUMBER, addParams));
      expect(addResp.code).assertEqual(0);
      expect(MockData.plateNumberList.length).assertEqual(4);
      expect(MockData.plateNumberList[0].plate).assertEqual('苏A00001');
      expect(MockData.plateNumberList[0].kind).assertEqual(2);

      let deleteResp = getMockResponse<BaseResponse>(createConfig(RequestUrl.DELETE_PLATE_NUMBER, {
        id: MockData.plateNumberList[0].id
      } as CommonReq));
      expect(deleteResp.code).assertEqual(0);
      expect(MockData.plateNumberList.length).assertEqual(3);
      expect(MockData.plateNumberList[0].plate).assertEqual('苏A55WW2');
    });

    it('dispatches pay detail and pay order requests with request params', 0, () => {
      let detailResp = getMockResponse<BaseResponse<PayRecord>>(createConfig(RequestUrl.GET_PAY_DETAIL, {
        plate: '苏B88888'
      } as CommonReq));
      expect(detailResp.code).assertEqual(0);
      expect(detailResp.data.plate).assertEqual('苏B88888');
      expect(detailResp.data.address).assertEqual('商场停车场');
      expect(detailResp.data.money).assertEqual('7.5');

      let payRecordResp = getMockResponse<BaseResponse<PayRecord[]>>(createConfig(RequestUrl.GET_PAY_RECORD_LIST));
      expect(payRecordResp.code).assertEqual(0);
      expect(payRecordResp.data.length).assertEqual(3);

      let payOrderResp = getMockResponse<BaseResponse>(createConfig(RequestUrl.PAY_ORDER, {
        plate: '苏C66666',
        extraPay: '18.8'
      } as CommonReq));
      expect(payOrderResp.code).assertEqual(0);
      expect(MockData.payRecordList.length).assertEqual(4);
      expect(MockData.payRecordList[0].plate).assertEqual('苏C66666');
      expect(MockData.payRecordList[0].money).assertEqual('18.8');
    });

    it('dispatches user info and content urls to their mock sources', 0, () => {
      let openLoginResp = getMockResponse<BaseResponse<UserInfo>>(createConfig(RequestUrl.GET_OPEN_LOGIN_HM_URL));
      expect(openLoginResp.code).assertEqual(0);
      expect(openLoginResp.data.userTel).assertEqual('10000000001');

      let closeLoginResp = getMockResponse<UserInfo>(createConfig(RequestUrl.GET_CLOSE_LOGIN_HM_URL));
      expect(closeLoginResp.id).assertEqual('1');
      expect(closeLoginResp.userTel).assertEqual('');

      let modifyResp = getMockResponse<BaseResponse<UserInfo>>(createConfig(RequestUrl.MODIFY_USER_INFO, {
        name: '测试用户'
      } as CommonReq));
      expect(modifyResp.code).assertEqual(0);
      expect(modifyResp.data.name).assertEqual('测试用户');

      let walletResp = getMockResponse<BaseResponse<Wallet[]>>(createConfig(RequestUrl.GET_MY_WALLET_LIST_URL));
      expect(walletResp.code).assertEqual(0);
      expect(walletResp.data.length).assertEqual(8);
      expect(walletResp.data[0].name).assertEqual('停车缴费');

      let serviceResp = getMockResponse<BaseResponse<string>>(createConfig(RequestUrl.GET_SERVICE_URL));
      expect(serviceResp.code).assertEqual(0);
      expect(serviceResp.data).assertContain('雨伞租借说明');

      let storeGuideResp = getMockResponse<BaseResponse<StoreGuide[]>>(createConfig(RequestUrl.GET_STORE_GUIDE_URL));
      expect(storeGuideResp.code).assertEqual(0);
      expect(storeGuideResp.data.length).assertEqual(24);

      let privacyResp = getMockResponse<BaseResponse<string>>(createConfig(RequestUrl.GET_PRIVACY_INFO));
      expect(privacyResp.code).assertEqual(0);
      expect(privacyResp.data).assertContain('商场模板隐私声明');
    });

    it('returns an empty string for unsupported urls', 0, () => {
      let unknownResp = getMockResponse<string>(createConfig('unknownUrl'));
      expect(unknownResp).assertEqual('');
    });
  });
}
