/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { InternalAxiosRequestConfig } from '@ohos/axios';
import { describe, beforeEach, afterEach, it, expect, MockKit, when } from '@ohos/hypium';
import { OrderStatus, QueryGoodListSource, URL_MAP } from '../main/ets/common/Constant';
import { IOrderUpdate, IQueryGood, IQueryGoodList, IQueryOrderList, ISubmitOrderRequest, IUpdateCity } from '../main/ets/model/IRequest';
import { IUserInfo } from '../main/ets/model/IResponse';
import { getMockResponse } from '../main/ets/http/HttpMockMap';
import { MockApi } from '../main/ets/http/MockApi';

type RequestParams = IQueryGoodList | IQueryGood | IQueryOrderList | IOrderUpdate;
type HttpMockRequestConfig = InternalAxiosRequestConfig<string>;

function buildConfig(url: string, params?: RequestParams, data?: string): HttpMockRequestConfig {
  return {
    url,
    params,
    data,
  } as HttpMockRequestConfig;
}

function expectNoArgRoute(mockKit: MockKit, url: string, originalMethod: Function, methodName: string, response: string): void {
  const mockedMethod = mockKit.mockFunc(MockApi, originalMethod);
  when(mockedMethod)().afterReturn(response);

  expect(getMockResponse(buildConfig(url))).assertEqual(response);
  mockKit.verify(methodName, []).once();
}

function expectConfigRoute(
  mockKit: MockKit,
  config: HttpMockRequestConfig,
  originalMethod: Function,
  methodName: string,
  response: string,
  expectedParams?: RequestParams,
  expectedData?: string
): void {
  const mockedMethod = mockKit.mockFunc(MockApi, originalMethod);
  when(mockedMethod)(config).afterAction((actualConfig?: HttpMockRequestConfig): string => {
    expect(actualConfig?.url).assertEqual(config.url);
    if (expectedData !== undefined) {
      expect(actualConfig?.data).assertEqual(expectedData);
    } else {
      expect(actualConfig?.data).assertUndefined();
    }
    if (expectedParams !== undefined) {
      expect(JSON.stringify(actualConfig?.params)).assertEqual(JSON.stringify(expectedParams));
    } else {
      expect(actualConfig?.params).assertUndefined();
    }
    return response;
  });

  expect(getMockResponse(config)).assertEqual(response);
  mockKit.verify(methodName, [config]).once();
}

export default function HttpMockMapTest() {
  describe('HttpMockMapTest', () => {
    let mockKit: MockKit;

    beforeEach(() => {
      mockKit = new MockKit();
    });

    afterEach(() => {
      mockKit.clear(MockApi);
    });

    it('routes each configured url to the expected mock handler', 0, () => {
      const updateUserInfoData: IUserInfo = {
        userId: 1,
        nickName: 'tester',
      };
      const updateCitySelectedData: IUpdateCity = {
        city: '上海',
      };
      const updateCurrentCityData: IUpdateCity = {
        city: '深圳',
      };
      const getGoodListParams: IQueryGoodList = {
        source: QueryGoodListSource.SEARCH,
        keyword: '擦窗',
      };
      const getGoodParams: IQueryGood = {
        goodId: 'window_clean_0',
      };
      const preOrderData: ISubmitOrderRequest = {
        goodId: 'window_clean_0',
        addressName: '家',
        addressStr: '浦东大道 1 号',
        contactName: '测试用户',
        contactPhone: '13800138000',
        selectServiceId: 1,
        appointTime: 100,
        remark: '尽快上门',
        actualPay: 99,
      };
      const orderUpdateData: IOrderUpdate = {
        orderId: 'order_1',
      };
      const getOrderListParams: IQueryOrderList = {
        status: OrderStatus.ALL,
      };

      expectNoArgRoute(
        mockKit,
        URL_MAP.LOGIN_WITH_HUAWEI_ID,
        MockApi.loginWithHuaweiID,
        'loginWithHuaweiID',
        'loginWithHuaweiID'
      );
      expectNoArgRoute(mockKit, URL_MAP.GET_USER_INFO, MockApi.getUserInfo, 'getUserInfo', 'getUserInfo');
      expectNoArgRoute(mockKit, URL_MAP.GET_HOME_INFO, MockApi.getHomeInfo, 'getHomeInfo', 'getHomeInfo');
      expectNoArgRoute(
        mockKit,
        URL_MAP.GET_CATEGORY_INFO,
        MockApi.getAllCategoryServices,
        'getAllCategoryServices',
        'getAllCategoryServices'
      );

      const updateUserInfoConfig = buildConfig(
        URL_MAP.UPDATE_USER_INFO,
        undefined,
        JSON.stringify(updateUserInfoData)
      );
      expectConfigRoute(
        mockKit,
        updateUserInfoConfig,
        MockApi.updateUserInfo,
        'updateUserInfo',
        'updateUserInfo',
        undefined,
        JSON.stringify(updateUserInfoData)
      );

      const updateCitySelectedConfig = buildConfig(
        URL_MAP.UPDATE_CITY_SELECTED,
        undefined,
        JSON.stringify(updateCitySelectedData)
      );
      expectConfigRoute(
        mockKit,
        updateCitySelectedConfig,
        MockApi.updateCitySelected,
        'updateCitySelected',
        'updateCitySelected',
        undefined,
        JSON.stringify(updateCitySelectedData)
      );

      const updateCurrentCityConfig = buildConfig(
        URL_MAP.UPDATE_CITY_CURRENT,
        undefined,
        JSON.stringify(updateCurrentCityData)
      );
      expectConfigRoute(
        mockKit,
        updateCurrentCityConfig,
        MockApi.updateCurrentCity,
        'updateCurrentCity',
        'updateCurrentCity',
        undefined,
        JSON.stringify(updateCurrentCityData)
      );

      const getGoodListConfig = buildConfig(URL_MAP.GET_GOOD_LIST, getGoodListParams);
      expectConfigRoute(
        mockKit,
        getGoodListConfig,
        MockApi.getGoodList,
        'getGoodList',
        'getGoodList',
        getGoodListParams
      );

      const getGoodConfig = buildConfig(URL_MAP.GET_GOOD, getGoodParams);
      expectConfigRoute(mockKit, getGoodConfig, MockApi.getGood, 'getGood', 'getGood', getGoodParams);

      const preOrderConfig = buildConfig(
        URL_MAP.PRE_ORDER,
        undefined,
        JSON.stringify(preOrderData)
      );
      expectConfigRoute(
        mockKit,
        preOrderConfig,
        MockApi.preOrder,
        'preOrder',
        'preOrder',
        undefined,
        JSON.stringify(preOrderData)
      );

      const payOrderConfig = buildConfig(URL_MAP.PAY_ORDER, undefined, JSON.stringify(orderUpdateData));
      expectConfigRoute(
        mockKit,
        payOrderConfig,
        MockApi.payOrder,
        'payOrder',
        'payOrder',
        undefined,
        JSON.stringify(orderUpdateData)
      );

      const getOrderListConfig = buildConfig(URL_MAP.GET_ORDER_LIST, getOrderListParams);
      expectConfigRoute(
        mockKit,
        getOrderListConfig,
        MockApi.getOrderList,
        'getOrderList',
        'getOrderList',
        getOrderListParams
      );

      const getOrderConfig = buildConfig(URL_MAP.GET_ORDER, orderUpdateData);
      expectConfigRoute(mockKit, getOrderConfig, MockApi.getOrder, 'getOrder', 'getOrder', orderUpdateData);

      const refundConfig = buildConfig(URL_MAP.REFUND, undefined, JSON.stringify(orderUpdateData));
      expectConfigRoute(
        mockKit,
        refundConfig,
        MockApi.refund,
        'refund',
        'refund',
        undefined,
        JSON.stringify(orderUpdateData)
      );

      const cancelOrderConfig = buildConfig(URL_MAP.CANCEL_ORDER, undefined, JSON.stringify(orderUpdateData));
      expectConfigRoute(
        mockKit,
        cancelOrderConfig,
        MockApi.cancelOrder,
        'cancelOrder',
        'cancelOrder',
        undefined,
        JSON.stringify(orderUpdateData)
      );
    });

    it('returns an empty string when the url is missing or not mapped', 0, () => {
      expect(getMockResponse()).assertEqual('');
      expect(getMockResponse(buildConfig('/api/unknown'))).assertEqual('');
    });
  });
}
