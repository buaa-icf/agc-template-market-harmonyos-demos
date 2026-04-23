import { describe, beforeEach, expect, it } from '@ohos/hypium';
import { HotelOrderPageVM } from '../main/ets/viewmodels/HotelOrderPageVM';
import { HotelBookingVM } from '../main/ets/viewmodels/HotelBookingVM';
import { DatePickerPanelVM } from '../main/ets/viewmodels/DatePickerPanelVM';
import { CheckInData } from '../main/ets/models/CheckInData';

function resetState() {
  const orderVM = HotelOrderPageVM.instance;
  const bookingVM = HotelBookingVM.instance;
  const datePickerVM = DatePickerPanelVM.instance;

  orderVM.pageTitle = '';
  orderVM.checkInData = new CheckInData();

  bookingVM.hotelInfo.orgUnitName = '';
  bookingVM.hotelInfo.orgUnitNo = '';
  bookingVM.hotelInfo.hotelId = -1;
  bookingVM.roomInfo.roomCode = '';
  bookingVM.roomInfo.roomId = -1;
  bookingVM.roomInfo.roomName = '';
  bookingVM.roomInfo.currency = '';
  bookingVM.roomInfo.isPrepaid = '';
  bookingVM.roomInfo.rmRate = '';
  bookingVM.roomInfo.rateCode = '';
  bookingVM.roomInfo.rateName = '';

  datePickerVM.roomCount = 1;
}

export default function hotelOrderPageVMTest() {
  describe('HotelOrderPageVMTest', () => {
    beforeEach(() => {
      resetState();
    });

    it('initData copies date and room information into page state', 0, async () => {
      const orderVM = HotelOrderPageVM.instance;
      const bookingVM = HotelBookingVM.instance;
      const datePickerVM = DatePickerPanelVM.instance;
      const checkInDate = new Date(2026, 3, 23);
      const checkOutDate = new Date(2026, 3, 25);

      bookingVM.hotelInfo.orgUnitName = 'Palm Hotel';
      bookingVM.roomInfo.roomName = 'Deluxe Suite';
      bookingVM.roomInfo.rateName = 'Breakfast Included';
      bookingVM.roomInfo.rmRate = '188.5';

      datePickerVM.checkInDate = checkInDate;
      datePickerVM.checkOutDate = checkOutDate;
      datePickerVM.roomCount = 2;

      await orderVM.initData();

      expect(orderVM.pageTitle).assertEqual('Palm Hotel');
      expect(orderVM.checkInData.checkInDateLabel).assertEqual(datePickerVM.getDateLabel(checkInDate));
      expect(orderVM.checkInData.checkInDateDescription).assertEqual(datePickerVM.getDateDescription(checkInDate));
      expect(orderVM.checkInData.checkOutDateLabel).assertEqual(datePickerVM.getDateLabel(checkOutDate));
      expect(orderVM.checkInData.checkOutDateDescription).assertEqual(datePickerVM.getDateDescription(checkOutDate));
      expect(orderVM.checkInData.totalDays).assertEqual(2);
      expect(orderVM.checkInData.roomCount).assertEqual(2);
      expect(JSON.stringify(orderVM.checkInData.roomTag)).assertEqual(JSON.stringify(['Deluxe Suite', 'Breakfast Included']));
      expect(orderVM.checkInData.actualPaidPrice).assertEqual('754');
    });

    it('initData falls back to placeholder price when room rate is invalid', 0, async () => {
      const orderVM = HotelOrderPageVM.instance;
      const bookingVM = HotelBookingVM.instance;
      const datePickerVM = DatePickerPanelVM.instance;

      bookingVM.hotelInfo.orgUnitName = 'Palm Hotel';
      bookingVM.roomInfo.roomName = 'Standard Room';
      bookingVM.roomInfo.rateName = 'Member Rate';
      bookingVM.roomInfo.rmRate = 'not-a-number';

      datePickerVM.checkInDate = new Date(2026, 4, 1);
      datePickerVM.checkOutDate = new Date(2026, 4, 4);
      datePickerVM.roomCount = 3;

      await orderVM.initData();

      expect(orderVM.checkInData.totalDays).assertEqual(3);
      expect(orderVM.checkInData.roomCount).assertEqual(3);
      expect(orderVM.checkInData.actualPaidPrice).assertEqual('--');
    });
  });
}
