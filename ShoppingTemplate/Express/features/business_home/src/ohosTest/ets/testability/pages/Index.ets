import { HomeVisit } from '../../../../main/ets/components/HomeVisit'
import { ShippingInfo } from '../../../../main/ets/components/ShippingInfo'
import { ExpressPageVM } from '../../../../main/ets/viewModels/ExpressPageVM'
import { dayList as DAY_LIST_RAW, getTimeList } from '../../../../main/ets/constants'
import { IServicePoint, IPosition } from 'lib_foundation'

@Entry
@Component
struct TestabilityIndex {
  @State scenario: string = 'none'

  aboutToAppear(): void {
    const vm = ExpressPageVM.instance
    vm.sendAddress.cellphone = '13800000000'
    vm.sendAddress.name = 'sender'
    vm.sendAddress.detailAddress = 'send-addr'
    vm.getAddress.cellphone = '13900000000'
    vm.getAddress.name = 'receiver'
    vm.getAddress.detailAddress = 'recv-addr'
    vm.companyPickerList = ['CompanyA', 'CompanyB']
    vm.selectedCompanyIndex = 0
    vm.dayList = getTimeList(DAY_LIST_RAW)
    vm.timePickerList = vm.dayList[0].timeList
    vm.selectedDayIndex = 0
    vm.selectedTimeIndex = 0
    vm.selectedPayMethodIndex = 0
    vm.selectedGridIndex = 0
    vm.couponList = []
    vm.goodsName = ''
    vm.couponName = ''
    vm.selectedCompany = ''
    vm.selectedDayText = ''
    vm.selectedTime = ''
    vm.selectedPayMethod = ''
    vm.selectedGrid = ''
    const position: IPosition = { latitude: 0, longitude: 0 } as IPosition
    const servicePoint: IServicePoint = {
      id: 1,
      name: 'point',
      image: '',
      title: 'tip',
      tips: ['tip1'],
      distance: '1km',
      positionName: 'addr',
      position: position
    }
    vm.selectedServicePoint = servicePoint
  }

  build() {
    Column() {
      Row() {
        Button('home_visit')
          .id('btn_show_home_visit')
          .onClick(() => {
            this.scenario = 'home_visit'
          })
        Button('shipping_info')
          .id('btn_show_shipping_info')
          .onClick(() => {
            this.scenario = 'shipping_info'
          })
      }
      .id('scenario_bar')
      .height(60)

      if (this.scenario === 'home_visit') {
        Column() {
          HomeVisit()
        }
        .id('host_home_visit')
      } else if (this.scenario === 'shipping_info') {
        Column() {
          ShippingInfo()
        }
        .id('host_shipping_info')
      }
    }
    .width('100%')
    .height('100%')
  }
}
