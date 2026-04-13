import { afterEach, beforeEach, describe, expect, it } from '@ohos/hypium';
import { InternalAxiosRequestConfig } from '@ohos/axios';
import {
  AppointState,
  GroupOrderStatus,
  OrderType,
  URL_MAP,
} from '../main/ets/common/Constant';
import { getMockResponse } from '../main/ets/http/AxiosBase';
import { MockApi } from '../main/ets/http/MockApi';
import { MockData } from '../main/ets/http/MockData';
import {
  ICancelReserveRequest,
  ICreateAppointmentRequest,
  IQueryAppointList,
  IRefundGroup,
  ISubmitOrderRequest,
  IUpdateAppointmentRequest,
} from '../main/ets/model/IRequest';

const INITIAL_APPOINTMENT_ID: number = 20;

function createConfig(url: string, params?: Object, data?: Object): InternalAxiosRequestConfig {
  return {
    url,
    params,
    data: data === undefined ? undefined : JSON.stringify(data),
  } as InternalAxiosRequestConfig;
}

function resetMockState() {
  MockApi.myAppointmentList = [];
  MockApi.myGroupList = [];
  MockApi.mySingleCardList = [];
  MockApi.isBindMobile = false;
  MockData.initialAppointId = INITIAL_APPOINTMENT_ID;
  MockData.USER_INFO_FULL = {
    userId: MockData.USER_ID,
    mobile: '11100001111',
    nickName: '华为用户',
  };
}

export default function AxiosBaseTest() {
  describe('AxiosBaseTest', () => {
    beforeEach(() => {
      resetMockState();
    });

    afterEach(() => {
      resetMockState();
    });

    it('maps static routes to the expected mock payloads', 0, () => {
      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.LOGIN_WITH_HUAWEI_ID)))).assertEqual(
        JSON.stringify(MockData.LOGIN_RESP));
      expect(getMockResponse(createConfig(URL_MAP.REFRESH_TOKEN))).assertEqual(true);
      expect(getMockResponse(createConfig(URL_MAP.CONFIRM_REBIND_MOBILE))).assertEqual(true);
      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.GET_STORE_INFO)))).assertEqual(
        JSON.stringify(MockData.STORE_INFO));
      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.GET_STORE_LIST)))).assertEqual(
        JSON.stringify(MockData.STORE_LIST));
      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.GET_GOOD_LIST)))).assertEqual(
        JSON.stringify(MockData.GOOD_LIST));
      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.GET_SINGLE_VISIT_CARD_LIST)))).assertEqual(
        JSON.stringify(MockData.SINGLE_CARD_LIST));
      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.GET_GROUP_LIST)))).assertEqual(
        JSON.stringify(MockData.GROUP_LIST));
    });

    it('updates user binding and membership state through mapped routes', 0, () => {
      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.GET_USER_INFO)))).assertEqual(
        JSON.stringify(MockData.USER_INFO_UNBIND));

      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.BIND_MOBILE_WITH_CODE)))).assertEqual(
        JSON.stringify({
          status: '0',
          rebindSecret: '',
        }));
      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.GET_USER_INFO)))).assertEqual(
        JSON.stringify(MockData.USER_INFO_FULL));

      expect(MockData.USER_INFO_FULL.memberId ?? '').assertEqual('');
      expect(getMockResponse(createConfig(URL_MAP.ACTIVE_MEMBER_CARD))).assertEqual(true);
      expect((MockData.USER_INFO_FULL.memberId ?? '') === '').assertEqual(false);

      expect(getMockResponse(createConfig(URL_MAP.UNBIND_MOBILE))).assertEqual(true);
      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.GET_USER_INFO)))).assertEqual(
        JSON.stringify(MockData.USER_INFO_UNBIND));
    });

    it('passes reservation configs to the appointment mock workflows', 0, () => {
      const createAppointmentPayload: ICreateAppointmentRequest = {
        name: '测试用户',
        phone: '13800000000',
        reserveTime: '1710000000000',
        goodId: '2',
        remarks: '预约备注',
        numbers: '2',
      };
      const newAppointmentQuery: IQueryAppointList = {
        status: [AppointState.NEW],
      };
      const updateAppointmentPayload: IUpdateAppointmentRequest = {
        reserveId: 0,
        setSchedule: 1,
        setSubscription: 1,
      };
      const cancelAppointmentPayload: ICancelReserveRequest = {
        reserveId: 0,
      };
      const canceledAppointmentQuery: IQueryAppointList = {
        status: [AppointState.CANCEL],
      };

      expect(getMockResponse(createConfig(URL_MAP.CREATE_APPOINTMENT_INFO, undefined, createAppointmentPayload)))
        .assertEqual(true);
      expect(MockApi.myAppointmentList.length).assertEqual(1);
      expect(MockApi.myAppointmentList[0].contactName).assertEqual(createAppointmentPayload.name);
      expect(MockApi.myAppointmentList[0].itemName).assertEqual('贵气祖母绿日式美甲');

      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.GET_APPOINTMENT_LIST, newAppointmentQuery)))).assertEqual(
        JSON.stringify(MockApi.myAppointmentList));

      updateAppointmentPayload.reserveId = MockApi.myAppointmentList[0].id;
      expect(getMockResponse(createConfig(URL_MAP.UPDATE_APPOINTMENT_INFO, undefined, updateAppointmentPayload)))
        .assertEqual(true);
      expect(MockApi.myAppointmentList[0].setSchedule).assertEqual(1);
      expect(MockApi.myAppointmentList[0].setSubscription).assertEqual(1);

      cancelAppointmentPayload.reserveId = MockApi.myAppointmentList[0].id;
      expect(getMockResponse(createConfig(URL_MAP.CANCEL_APPOINTMENT, undefined, cancelAppointmentPayload)))
        .assertEqual(true);
      expect(MockApi.myAppointmentList[0].state).assertEqual(AppointState.CANCEL);

      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.GET_APPOINTMENT_LIST, canceledAppointmentQuery))))
        .assertEqual(JSON.stringify(MockApi.myAppointmentList));
    });

    it('passes order configs to purchase and refund mock workflows', 0, () => {
      const singleCard = MockData.SINGLE_CARD_LIST[0];
      const singleOrderPayload: ISubmitOrderRequest = {
        projectId: singleCard.id,
        type: OrderType.SINGLE_CARD,
        contactName: '次卡联系人',
        contactPhone: '13800000001',
        remark: '次卡备注',
        numbers: 1,
        actualPay: singleCard.vipPrice,
      };
      expect(getMockResponse(createConfig(URL_MAP.PRE_ORDER, undefined, singleOrderPayload))).assertEqual(true);
      expect(MockApi.mySingleCardList.length).assertEqual(1);
      expect(MockApi.mySingleCardList[0].singleCardId).assertEqual(singleCard.id);
      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.GET_MY_SINGLE_VISIT_CARD_LIST)))).assertEqual(
        JSON.stringify(MockApi.mySingleCardList));

      const group = MockData.GROUP_LIST[0];
      const groupOrderPayload: ISubmitOrderRequest = {
        projectId: group.id,
        type: OrderType.GROUP,
        contactName: '团购联系人',
        contactPhone: '13800000002',
        remark: '团购备注',
        numbers: 2,
        actualPay: group.vipPrice * 2,
      };
      expect(getMockResponse(createConfig(URL_MAP.PRE_ORDER, undefined, groupOrderPayload))).assertEqual(true);
      expect(MockApi.myGroupList.length).assertEqual(1);
      expect(MockApi.myGroupList[0].groupId).assertEqual(group.id);
      expect(JSON.stringify(getMockResponse(createConfig(URL_MAP.GET_MY_GROUP_LIST)))).assertEqual(
        JSON.stringify(MockApi.myGroupList));

      const refundPayload: IRefundGroup = {
        orderNo: MockApi.myGroupList[0].orderNo,
      };
      expect(getMockResponse(createConfig(URL_MAP.REFUND_GROUP, undefined, refundPayload))).assertEqual(true);
      expect(MockApi.myGroupList[0].status).assertEqual(GroupOrderStatus.REFUND);
    });

    it('returns an empty string for missing or unsupported routes', 0, () => {
      expect(getMockResponse()).assertEqual('');
      expect(getMockResponse(createConfig('/api/mock/not-supported'))).assertEqual('');
    });
  });
}
