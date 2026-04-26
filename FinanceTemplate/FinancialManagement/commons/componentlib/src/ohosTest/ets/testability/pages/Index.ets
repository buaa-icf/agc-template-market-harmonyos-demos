import { RouterMap } from 'commonlib'
import { IProfile } from 'network/src/main/ets/types/responseTypes/GetProductResp'
import { CommonProductProfile } from '../../../../../../../../src/main/ets/components/CommonProductProfile'

const HOST_PAGE_ID: string = 'common_product_profile_host_page'
const WITH_CONTRACT_BUTTON_ID: string = 'common_product_profile_with_contract_button'
const WITHOUT_CONTRACT_BUTTON_ID: string = 'common_product_profile_without_contract_button'
const LAST_ROUTE_ID: string = 'common_product_profile_last_route'
const LAST_PARAM_ID: string = 'common_product_profile_last_param'

function createProfile(contract: string): IProfile {
  return {
    type: 'Balanced Fund',
    contract: contract,
    information: 'quarterly-disclosure.pdf',
    managementCompany: 'Alpha AMC',
    number: 'CN-12345',
    date: '2025-01-02',
  }
}

@Entry
@ComponentV2
export struct Index {
  @Local private profile: IProfile = createProfile('contract-preview.pdf')
  @Local private lastRoute: string = 'none'
  @Local private lastParam: string = 'none'

  private updateScenario(contract: string): void {
    this.profile = createProfile(contract)
    this.lastRoute = 'none'
    this.lastParam = 'none'
  }

  build() {
    Column({ space: 12 }) {
      Text('Common Product Profile Host')
        .id(HOST_PAGE_ID)

      Row({ space: 12 }) {
        Button('With Contract')
          .id(WITH_CONTRACT_BUTTON_ID)
          .onClick(() => {
            this.updateScenario('contract-preview.pdf')
          })

        Button('Without Contract')
          .id(WITHOUT_CONTRACT_BUTTON_ID)
          .onClick(() => {
            this.updateScenario('')
          })
      }

      Text(`Route:${this.lastRoute}`)
        .id(LAST_ROUTE_ID)

      Text(`Param:${this.lastParam}`)
        .id(LAST_PARAM_ID)

      CommonProductProfile({
        productProfile: this.profile,
        changeFactory: (router: RouterMap, param?: ESObject) => {
          this.lastRoute = router
          this.lastParam = typeof param === 'string' ? param : 'unknown'
        }
      })
    }
    .width('100%')
    .padding(16)
  }
}
