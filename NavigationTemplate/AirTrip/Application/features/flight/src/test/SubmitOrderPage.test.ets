import { describe, expect, it } from '@ohos/hypium'
import { ArgumentMatchers, MockKit, when } from '@ohos/hamock'

import { DataStorage, PassengerInfo } from 'common'
import { GlobalDialog } from 'components'
import { FlightInfo, FlightSpaceInfo } from '../main/ets/model/FlightPageModel'
import { SubmitOrderPage } from '../main/ets/pages/SubmitOrderPage'
import { OrderApi } from 'common'

function buildPassenger(name: string, phone: string): PassengerInfo {
  const passenger = new PassengerInfo()
  passenger.id = `${name}_id`
  passenger.name = name
  passenger.certificateType = '身份证'
  passenger.certificateNo = '110101199001011234'
  passenger.phone = phone
  return passenger
}

function createPage(): SubmitOrderPage {
  const page = new SubmitOrderPage()
  const flightInfo = new FlightInfo()
  flightInfo.flightNo = 'MU1234'
  flightInfo.airlineName = '中国东方航空'
  flightInfo.aircraftType = 'A320'
  flightInfo.takeoffTime = '2030-01-10 09:30:00'
  flightInfo.landingTime = '2030-01-10 12:10:00'
  flightInfo.departureCity = '上海'
  flightInfo.departureAirport = '虹桥机场'
  flightInfo.destinationCity = '北京'
  flightInfo.destinationAirport = '首都机场'
  flightInfo.mealType = '含餐'

  const spaceInfo = new FlightSpaceInfo()
  spaceInfo.flightId = 'flight_1'
  spaceInfo.spaceType = 'ECONOMY_CLASS'
  spaceInfo.spacePrice = '560'

  page.dataStorage = new DataStorage()
  page.flightInfo = flightInfo
  page.spaceInfo = spaceInfo
  page.passengerList = []
  page.selectedCount = 0
  page.isCheckedInstruct = true
  page.contactName = ''
  page.contactPhone = ''
  return page
}

class MockOrderResult {
}

export default function SubmitOrderPageTest() {
  describe('SubmitOrderPageTest', () => {
    it('returns derived flight information labels', 0, () => {
      const page = createPage()

      expect(page.getWeekDay()).assertEqual('周四')
      expect(page.getSpaceLabel()).assertEqual('经济舱')
      expect(page.getFlyTime()).assertEqual('09:30:00 - 12:10:00')

      page.spaceInfo.spaceType = 'FIRST_CLASS'
      expect(page.getSpaceLabel()).assertEqual('公务舱/头等舱')
    })

    it('identifies whether the arrival date is the next day', 0, () => {
      const page = createPage()
      const sameDayFlight = new FlightInfo()
      sameDayFlight.takeoffTime = '2030-01-10 09:30:00'
      sameDayFlight.landingTime = '2030-01-10 12:10:00'
      const nextDayFlight = new FlightInfo()
      nextDayFlight.takeoffTime = '2030-01-10 23:30:00'
      nextDayFlight.landingTime = '2030-01-11 01:10:00'

      expect(page.isNextDay(sameDayFlight)).assertFalse()
      expect(page.isNextDay(nextDayFlight)).assertTrue()
    })

    it('deletes a passenger and recalculates the selected count', 0, () => {
      const page = createPage()
      const firstPassenger = buildPassenger('张三', '13800138000')
      firstPassenger.isChecked = true
      const secondPassenger = buildPassenger('李四', '13900139000')
      secondPassenger.isChecked = false
      page.passengerList = [firstPassenger, secondPassenger]
      page.selectedCount = 1

      page.deletePassenger(firstPassenger, 0)

      expect(page.passengerList.length).assertEqual(1)
      expect(page.passengerList[0].name).assertEqual('李四')
      expect(page.selectedCount).assertEqual(0)
    })

    it('keeps the page state unchanged when no passenger is selected', 0, () => {
      const page = createPage()
      page.contactName = '联系人'
      page.contactPhone = '13800138000'

      page.submitOrder()

      expect(page.selectedCount).assertEqual(0)
      expect(page.passengerList.length).assertEqual(0)
      expect(page.dataStorage.payOrderTime).assertEqual('')
    })

    it('keeps the page state unchanged when the contact name is missing', 0, () => {
      const page = createPage()
      page.passengerList = [buildPassenger('张三', '13800138000')]
      page.selectedCount = 1
      page.contactPhone = '13800138000'

      page.submitOrder()

      expect(page.selectedCount).assertEqual(1)
      expect(page.dataStorage.payOrderTime).assertEqual('')
    })

    it('keeps the page state unchanged when the phone is missing', 0, () => {
      const page = createPage()
      page.passengerList = [buildPassenger('张三', '13800138000')]
      page.selectedCount = 1
      page.contactName = '联系人'

      page.submitOrder()

      expect(page.selectedCount).assertEqual(1)
      expect(page.dataStorage.payOrderTime).assertEqual('')
    })

    it('keeps the page state unchanged when the phone is invalid', 0, () => {
      const page = createPage()
      page.passengerList = [buildPassenger('张三', '13800138000')]
      page.selectedCount = 1
      page.contactName = '联系人'
      page.contactPhone = '1380013800'

      page.submitOrder()

      expect(page.selectedCount).assertEqual(1)
      expect(page.dataStorage.payOrderTime).assertEqual('')
    })

    it('keeps the page state unchanged when the booking instruction is not checked', 0, () => {
      const page = createPage()
      page.passengerList = [buildPassenger('张三', '13800138000')]
      page.selectedCount = 1
      page.contactName = '联系人'
      page.contactPhone = '13800138000'
      page.isCheckedInstruct = false

      page.submitOrder()

      expect(page.selectedCount).assertEqual(1)
      expect(page.dataStorage.payOrderTime).assertEqual('')
    })

    it('keeps selected passengers unchanged when addPassenger is called', 0, () => {
      const page = createPage()
      const passenger = buildPassenger('张三', '13800138000')
      passenger.isChecked = true
      page.passengerList = [passenger]
      page.selectedCount = 1

      page.addPassenger()

      expect(page.passengerList.length).assertEqual(1)
      expect(page.selectedCount).assertEqual(1)
    })

    it('updates payOrderTime when submitOrder receives valid data', 0, async () => {
      const page = createPage()
      const mockKit = new MockKit()
      const passenger = buildPassenger('张三', '13800138000')
      passenger.isChecked = true
      page.passengerList = [passenger]
      page.selectedCount = 1
      page.contactName = '联系人'
      page.contactPhone = '13800138000'

      const mockShowDialog = mockKit.mockFunc(GlobalDialog, GlobalDialog.showDialogForCreateOrder)
      when(mockShowDialog)(ArgumentMatchers.anyObj).afterReturn(Promise.resolve())
      const mockOrderApi = mockKit.mockFunc(OrderApi, OrderApi.addOrUpdateOrder)
      when(mockOrderApi)(ArgumentMatchers.anyObj).afterReturn(Promise.resolve(new MockOrderResult()))

      page.submitOrder()
      await Promise.resolve()

      expect(page.dataStorage.payOrderTime === '').assertFalse()
      expect(page.selectedCount).assertEqual(1)
      expect(page.passengerList.length).assertEqual(1)

      mockKit.clearAll()
    })
  })
}
