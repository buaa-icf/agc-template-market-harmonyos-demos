import { AxiosRequestHeaders } from '@ohos/axios'
import { afterEach, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium'
import { HttpRequestConfig } from '../main/ets/axiosHttpRequest/AxiosModel'
import { DnState, RequestUrl } from '../main/ets/constants/Common'
import { MockData } from '../main/ets/mock/MockData'
import { getMockResponse } from '../main/ets/mock/MockResponse'
import { AddCarReq, AddDnOrderReq, CommonReq, MyOrderReq } from '../main/ets/models/RequestModel'
import {
  CouponResp,
  DishesType,
  GetGoodSpecResp,
  GetHelpMsgResp,
  GetHmSystemResp,
  GetMyCarResp,
  GetMyOrderResp,
  GetStoreInfoResp,
  GetTableInfoResp,
  GetUserInfoResp,
  Good,
  MyCouponResp,
  TableTitle,
} from '../main/ets/models/ResponseModel'

function buildConfig(url: string, params?: Object): HttpRequestConfig {
  return {
    url,
    params,
    headers: {} as AxiosRequestHeaders,
  } as HttpRequestConfig
}

function resetMockState(): void {
  MockData.userInfo.userTel = ''
  MockData.couponsOri.forEach((item) => {
    item.state = 2
  })
  MockData.myCoupons = []
  MockData.myCar = new GetMyCarResp(0, [], 0, 0)
  MockData.myCarId = 0
  MockData.orderList = []
  MockData.orderId = 1
}

function buildCommonReq(): CommonReq {
  return {
    storeId: '',
    userId: '',
    openId: '',
    unionId: '',
    hmAppid: '',
    orderId: '',
    goodId: '',
    spec: '',
    combination: [],
    couponId: '',
    code: '',
    id: '',
    num: '',
  }
}

function buildAddCarParams(): AddCarReq {
  return {
    goodId: '1',
    num: '2',
    specType: '1',
    spec: '',
    combination: [],
    money: '16.4',
    boxMoney: '1',
  }
}

function buildOrderParams(): AddDnOrderReq {
  return {
    tableId: '1',
    userId: '1',
    storeId: '26',
    money: 16.4,
    discount: '0',
    mjMoney: '0',
    xyhMoney: '0',
    note: 'less sugar',
    type: 0,
    formId: 1,
    formId2: 1,
    payType: 1,
    sz: JSON.stringify([{
      id: '1',
      img: 'test-1pvkp/CateringOrderTemplate/good_logo1.png',
      money: '16.4',
      name: '圆形面包',
      num: '1',
      spec: '',
      combination: [],
    }]),
    tableware: '2',
    yhqMoney: '0',
    couponId: '',
    orderType: 0,
    boxMoney: 1,
    reductionMoney: 0,
  }
}

function buildMyOrderParams(dnState: string = DnState.ALL): MyOrderReq {
  return {
    storeId: '26',
    dnState,
    userId: '1',
    page: 1,
    pagesize: 10,
  }
}

function createOrderByMockResponse(): string {
  return getMockResponse<string>(buildConfig(RequestUrl.GET_ADD_DN_ORDER_URL, buildOrderParams()))
}

export default function MockResponseTest() {
  describe('MockResponseTest', () => {
    let mockKit: MockKit = new MockKit()

    beforeEach(() => {
      resetMockState()
      mockKit = new MockKit()
    })

    afterEach(() => {
      mockKit.clear(MockData)
    })

    it('routes static mock urls to static payloads', 0, () => {
      let hmSystem = getMockResponse<GetHmSystemResp>(buildConfig(RequestUrl.GET_HM_SYSTEM_URL))
      expect(hmSystem.storeId).assertEqual('26')
      expect(hmSystem.storeType).assertEqual(2)

      let userInfo = getMockResponse<GetUserInfoResp>(buildConfig(RequestUrl.GET_LOGIN_HM_URL))
      expect(userInfo.id).assertEqual('1')
      expect(userInfo.name).assertEqual('华为用户')

      let coupons = getMockResponse<CouponResp[]>(buildConfig(RequestUrl.GET_COUPONS_URL))
      expect(coupons.length).assertEqual(5)
      expect(coupons[0].id).assertEqual('1')

      let storeInfo = getMockResponse<GetStoreInfoResp>(buildConfig(RequestUrl.GET_STORE_INFO_URL))
      expect(storeInfo.store.id).assertEqual('id')
      expect(storeInfo.store.name).assertEqual('点餐')

      let tableTitle = getMockResponse<TableTitle[]>(buildConfig(RequestUrl.GET_TABLE_TITLE_URL))
      expect(tableTitle.length).assertEqual(10)
      expect(tableTitle[0].name).assertEqual('1号桌')

      let dishesList = getMockResponse<DishesType[]>(buildConfig(RequestUrl.GET_DISHES_LIST_URL))
      expect(dishesList.length).assertEqual(12)
      expect(dishesList[0].typeName).assertEqual('热销')

      let myCar = getMockResponse<GetMyCarResp>(buildConfig(RequestUrl.GET_MY_CAR_URL))
      expect(myCar.num).assertEqual(0)
      expect(myCar.res?.length).assertEqual(0)

      let myCoupons = getMockResponse<MyCouponResp[]>(buildConfig(RequestUrl.GET_MY_COUPONS_URL))
      expect(myCoupons.length).assertEqual(0)

      let help = getMockResponse<GetHelpMsgResp[]>(buildConfig(RequestUrl.GET_HELP_URL))
      expect(help.length).assertEqual(1)
      expect(help[0].id).assertEqual('1')

      let isNew = getMockResponse<number>(buildConfig(RequestUrl.GET_IS_NEW_URL))
      expect(isNew).assertEqual(1)
    })

    it('routes open login to the phone binding response', 0, () => {
      let response = getMockResponse<GetUserInfoResp>(buildConfig(RequestUrl.GET_OPEN_LOGIN_HM_URL))
      expect(response.userTel).assertEqual('10000002222')
      expect(MockData.userInfo.userTel).assertEqual('10000002222')
    })

    it('routes close login to the unbind response', 0, () => {
      MockData.userInfo.userTel = '10000002222'
      let response = getMockResponse<GetUserInfoResp>(buildConfig(RequestUrl.GET_CLOSE_LOGIN_HM_URL))
      expect(response.userTel).assertEqual('')
      expect(MockData.userInfo.userTel).assertEqual('')
    })

    it('routes table info requests with params', 0, () => {
      let params = buildCommonReq()
      params.id = '1'
      let response = getMockResponse<GetTableInfoResp>(buildConfig(RequestUrl.GET_ZHUO_HAO_URL, params))
      expect(response.tableName).assertEqual('1号桌')
      expect(response.typeName).assertEqual('1人桌')
      expect(response.status).assertEqual('0')
    })

    it('routes good info requests with params', 0, () => {
      let params = buildCommonReq()
      params.goodId = '1'
      let response = getMockResponse<Good>(buildConfig(RequestUrl.GET_GOOD_INFO_URL, params))
      expect(response.id).assertEqual('1')
      expect(response.specType).assertEqual('2')
      expect(response.spec?.length).assertEqual(3)
    })

    it('routes good spec requests with params', 0, () => {
      let params = buildCommonReq()
      params.goodId = '1'
      params.spec = '动物奶油'
      params.combination = []
      let response = getMockResponse<GetGoodSpecResp>(buildConfig(RequestUrl.GET_GOOD_SPEC_URL, params))
      expect(response.goodId).assertEqual('1')
      expect(response.specType).assertEqual('2')
      expect(response.spec).assertEqual('动物奶油')
      expect(response.money).assertEqual('16.4')
    })

    it('routes add car requests to the addCar helper', 0, () => {
      let request = buildAddCarParams()
      let capturedGoodId = ''
      let capturedNum = ''
      let addCarMock = mockKit.mockFunc(MockData, MockData.addCar)
      when(addCarMock)(request).afterAction((params: AddCarReq): number => {
        capturedGoodId = params.goodId ?? ''
        capturedNum = params.num ?? ''
        return 1
      })

      let response = getMockResponse<number>(buildConfig(RequestUrl.GET_ADD_CAR_URL, request))
      expect(response).assertEqual(1)
      expect(capturedGoodId).assertEqual('1')
      expect(capturedNum).assertEqual('2')
    })

    it('routes update car requests to the getUpdCar helper', 0, () => {
      let capturedId = ''
      let capturedNum = ''
      let params = buildCommonReq()
      params.id = 'cart-1'
      params.num = '3'
      let updCarMock = mockKit.mockFunc(MockData, MockData.getUpdCar)
      when(updCarMock)(params).afterAction((params: CommonReq): number => {
        capturedId = params.id
        capturedNum = params.num
        return 1
      })

      let response = getMockResponse<number>(buildConfig(RequestUrl.GET_UPD_CAR_URL, params))
      expect(response).assertEqual(1)
      expect(capturedId).assertEqual('cart-1')
      expect(capturedNum).assertEqual('3')
    })

    it('routes clear cart requests and resets cart state', 0, () => {
      MockData.myCar = new GetMyCarResp(1, [], 1, 16.4)
      let response = getMockResponse<number>(buildConfig(RequestUrl.GET_DEL_CAR_URL))
      expect(response).assertEqual(1)
      expect(MockData.myCar.num).assertEqual(0)
      expect(MockData.myCar.res?.length).assertEqual(0)
      expect(MockData.myCar.money).assertEqual(0)
    })

    it('routes coupon claim requests and stores claimed coupon', 0, () => {
      let params = buildCommonReq()
      params.couponId = '1'
      let response = getMockResponse<number>(buildConfig(RequestUrl.GET_LQ_COUPONS_URL, params))
      expect(response).assertEqual(1)
      expect(MockData.myCoupons.length).assertEqual(1)
      expect(MockData.myCoupons[0].couponId).assertEqual('1')
      expect(MockData.couponsOri[0].state).assertEqual(1)
    })

    it('routes add order requests and persists a pending order', 0, () => {
      let response = getMockResponse<string>(buildConfig(RequestUrl.GET_ADD_DN_ORDER_URL, buildOrderParams()))
      expect(response).assertEqual('1')
      expect(MockData.orderList.length).assertEqual(1)
      expect(MockData.orderList[0].order?.dnState).assertEqual(DnState.TO_BE_PAID)
      expect(MockData.myCar.num).assertEqual(0)
    })

    it('routes my order requests and returns the stored order', 0, () => {
      let orderId = createOrderByMockResponse()
      let response = getMockResponse<GetMyOrderResp[]>(buildConfig(RequestUrl.GET_MY_ORDER_URL, buildMyOrderParams()))
      expect(response.length).assertEqual(1)
      expect(response[0].order?.id).assertEqual(orderId)
      expect(response[0].table?.id).assertEqual('1')
    })

    it('routes order info requests and returns the target order', 0, () => {
      let orderId = createOrderByMockResponse()
      let params = buildCommonReq()
      params.orderId = orderId
      let response = getMockResponse<GetMyOrderResp>(buildConfig(RequestUrl.GET_ORDER_INFO_URL, params))
      expect(response.order?.id).assertEqual(orderId)
      expect(response.good?.length).assertEqual(1)
      expect(response.good?.[0].id).assertEqual('1')
    })

    it('routes cancel order requests and changes order state', 0, () => {
      let orderId = createOrderByMockResponse()
      let params = buildCommonReq()
      params.orderId = orderId
      let response = getMockResponse<number>(buildConfig(RequestUrl.GET_CANCEL_ORDER_URL, params))
      expect(response).assertEqual(1)
      expect(MockData.orderList[0].order?.dnState).assertEqual(DnState.CANCELED)
    })

    it('routes delete order requests and removes the order', 0, () => {
      let orderId = createOrderByMockResponse()
      let params = buildCommonReq()
      params.orderId = orderId
      let response = getMockResponse<number>(buildConfig(RequestUrl.GET_DELETE_ORDER_URL, params))
      expect(response).assertEqual(1)
      expect(MockData.orderList.length).assertEqual(0)
    })

    it('routes add goods requests to the addGoods helper', 0, () => {
      let capturedOrderId = ''
      let params = buildCommonReq()
      params.orderId = '1'
      let addGoodsMock = mockKit.mockFunc(MockData, MockData.addGoods)
      when(addGoodsMock)(params).afterAction((params: CommonReq): number => {
        capturedOrderId = params.orderId
        return 1
      })

      let response = getMockResponse<number>(buildConfig(RequestUrl.GET_ADD_GOODS_URL, params))
      expect(response).assertEqual(1)
      expect(capturedOrderId).assertEqual('1')
    })

    it('routes huawei pay requests and completes the order', 0, () => {
      let orderId = createOrderByMockResponse()
      let params = buildCommonReq()
      params.orderId = orderId
      let response = getMockResponse<number>(buildConfig(RequestUrl.GET_HUAWEI_PAY_INFO_URL, params))
      expect(response).assertEqual(1)
      expect(MockData.orderList[0].order?.dnState).assertEqual(DnState.COMPLETED)
    })

    it('returns an empty string for unknown urls', 0, () => {
      let response = getMockResponse<string>(buildConfig('unknown'))
      expect(response).assertEqual('')
    })
  })
}
