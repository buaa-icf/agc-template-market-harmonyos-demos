import { afterEach, beforeEach, describe, expect, it } from '@ohos/hypium';
import {
  AppStorageMap,
  ConfirmDialogOption,
  CourseInfo,
  DialogMap,
  OrderInfo,
  RouterMap,
  RouterModule,
} from 'commonlib';
import { OrderActionMap } from '../main/ets/constants/Enums';
import { OrderUtil } from '../main/ets/utils/OrderUtil';

const mockOrder: OrderInfo = {
  orderTime: '2026-04-11 12:00:00',
  expireTime: '2026-04-11 13:00:00',
  orderStatus: 1,
  orderNo: 'ORDER_001',
  paymentMethod: 0,
  totalPrice: 99,
  orderStr: 'mock-order-str',
  student: '测试学员',
  phone: '13800000000',
  courseInfo: {
    courseId: 1,
    type: 1,
    name: '素描体验课',
    summary: '课程简介',
    detail: '课程详情',
    mainDiagram: 'main-diagram',
    price: 99,
    expireType: 0,
    startTime: '2026-04-12',
    endTime: '2026-05-12',
    orderTime: '2026-04-11',
    classHour: 12,
    status: 1,
    currentHour: 0,
    timetable: {
      weekdays: [1, 3],
      startTime: '09:00',
      endTime: '10:00',
    },
  },
};

export default function OrderUtilTest() {
  describe('OrderUtilTest', () => {
    let callbackCalled: boolean = false;

    const callback = () => {
      callbackCalled = true;
    };

    beforeEach(() => {
      callbackCalled = false;
      RouterModule.clear();
      AppStorage.setOrCreate(AppStorageMap.STORE_PHONE, '');
    });

    afterEach(() => {
      RouterModule.clear();
      AppStorage.setOrCreate(AppStorageMap.STORE_PHONE, '');
    });

    it('opens cancel order confirmation dialog', 0, () => {
      OrderUtil.handleOrderOperation(mockOrder, OrderActionMap.CANCEL_ORDER, callback);

      const dialogParam = RouterModule.getNavParam<ConfirmDialogOption>({
        url: DialogMap.COMMON_CONFIRM,
      });

      expect(RouterModule.size()).assertEqual(1);
      expect(!!dialogParam).assertTrue();
      expect(dialogParam?.title as string).assertEqual('提示');
      expect(dialogParam?.message as string).assertEqual('是否确认取消订单？');
      expect(callbackCalled).assertFalse();
    });

    it('opens contact customer service dialog with store phone', 0, () => {
      AppStorage.setOrCreate(AppStorageMap.STORE_PHONE, '400-123-4567');

      OrderUtil.handleOrderOperation(mockOrder, OrderActionMap.CONTACT_CUSTOMER_SERVICE, callback);

      const dialogParam = RouterModule.getNavParam<string>({
        url: DialogMap.CONTACT_CUSTOM_SERVICE,
      });

      expect(RouterModule.size()).assertEqual(1);
      expect(dialogParam as string).assertEqual('400-123-4567');
      expect(callbackCalled).assertFalse();
    });

    it('opens request refund confirmation dialog', 0, () => {
      OrderUtil.handleOrderOperation(mockOrder, OrderActionMap.REQUEST_REFUND, callback);

      const dialogParam = RouterModule.getNavParam<ConfirmDialogOption>({
        url: DialogMap.COMMON_CONFIRM,
      });

      expect(RouterModule.size()).assertEqual(1);
      expect(!!dialogParam).assertTrue();
      expect(dialogParam?.message as string).assertEqual('是否确认申请退款？');
      expect(callbackCalled).assertFalse();
    });

    it('opens cancel refund confirmation dialog', 0, () => {
      OrderUtil.handleOrderOperation(mockOrder, OrderActionMap.CANCEL_REFUND, callback);

      const dialogParam = RouterModule.getNavParam<ConfirmDialogOption>({
        url: DialogMap.COMMON_CONFIRM,
      });

      expect(RouterModule.size()).assertEqual(1);
      expect(!!dialogParam).assertTrue();
      expect(dialogParam?.message as string).assertEqual('是否取消退款申请？');
      expect(callbackCalled).assertFalse();
    });

    it('opens course detail page when reordering', 0, () => {
      OrderUtil.handleOrderOperation(mockOrder, OrderActionMap.REORDER, callback);

      const courseInfo = RouterModule.getNavParam<CourseInfo>({
        url: RouterMap.COURSE_DETAIL,
      });

      expect(RouterModule.size()).assertEqual(1);
      expect(!!courseInfo).assertTrue();
      expect(courseInfo?.courseId as number).assertEqual(mockOrder.courseInfo.courseId);
      expect(courseInfo?.name as string).assertEqual(mockOrder.courseInfo.name);
      expect(callbackCalled).assertFalse();
    });

    it('opens delete order confirmation dialog', 0, () => {
      OrderUtil.handleOrderOperation(mockOrder, OrderActionMap.DELETE, callback);

      const dialogParam = RouterModule.getNavParam<ConfirmDialogOption>({
        url: DialogMap.COMMON_CONFIRM,
      });

      expect(RouterModule.size()).assertEqual(1);
      expect(!!dialogParam).assertTrue();
      expect(dialogParam?.message as string).assertEqual('是否确认删除订单？');
      expect(callbackCalled).assertFalse();
    });

    it('does nothing for unsupported actions', 0, () => {
      OrderUtil.handleOrderOperation(mockOrder, 'UNKNOWN_ACTION' as OrderActionMap, callback);

      expect(RouterModule.size()).assertEqual(0);
      expect(callbackCalled).assertFalse();
    });
  });
}
