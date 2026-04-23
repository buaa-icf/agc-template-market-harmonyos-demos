import { AppStorageV2 } from '@kit.ArkUI'
import { RouterModule, UserInfo } from 'lib_foundation'
import { EditNamePage } from '../../../../main/ets/pages/EditNamePage'
import { EditPhonePage } from '../../../../main/ets/pages/EditPhonePage'

function seedUser(): UserInfo {
  return AppStorageV2.connect(UserInfo, () => new UserInfo())!
}

@Entry
@Component
struct TestabilityIndex {
  aboutToAppear(): void {
    const user: UserInfo = seedUser()
    user.id = 1
    user.nickname = 'initNick'
    user.cellphone = '13800000000'
  }

  @Builder
  routerMap(name: string) {
    if (name === 'editName') {
      EditNamePage()
    } else if (name === 'editPhone') {
      EditPhonePage()
    }
  }

  build() {
    Column() {
      Row() {
        Button('name')
          .id('btn_show_name')
          .onClick(() => {
            RouterModule.push({ url: 'editName' })
          })
        Button('phone')
          .id('btn_show_phone')
          .onClick(() => {
            RouterModule.push({ url: 'editPhone' })
          })
        Button('back')
          .id('btn_pop')
          .onClick(() => {
            RouterModule.pop()
          })
      }
      .id('scenario_bar')
      .height(40)

      Row() {
        Button('nE')
          .id('btn_seed_name_empty')
          .onClick(() => {
            seedUser().nickname = ''
          })
        Button('nL')
          .id('btn_seed_name_long')
          .onClick(() => {
            seedUser().nickname = 'abcdefghij'
          })
        Button('pE')
          .id('btn_seed_phone_empty')
          .onClick(() => {
            seedUser().cellphone = ''
          })
        Button('pS')
          .id('btn_seed_phone_short')
          .onClick(() => {
            seedUser().cellphone = '123'
          })
      }
      .id('seed_bar')
      .height(40)

      Navigation(RouterModule.stack) {
      }
      .hideTitleBar(true)
      .navDestination(this.routerMap)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
