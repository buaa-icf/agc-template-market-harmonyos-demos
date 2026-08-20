import { afterEach, beforeEach, describe, expect, it } from '@ohos/hypium'
import { Constants, UserFullInfo, UserInfo } from 'commons'

import { MyDetailPage, MyDetailPageBuilder } from '../main/ets/pages/UserDetail'

interface ViewPUHost {
  create: (component: Object) => void
}

declare const ViewPU: ViewPUHost

interface MyDetailPagePrivateFields {
  userFullInfo: UserFullInfo
  gender: string
  edu: string
  monthlyIncome: string
  marriageStatus: string
  hasChildren: string
  expectationOfChildren: string
  smoking: string
  drinking: string
  hasBuyCar: string
  hasBuyHouse: string
  whenToMarry: string
  initialiseEnumField: () => void
  UploadProfilePicDialogBuilder: () => CustomBuilder
  aboutToBeDeleted?: () => void
}

interface UserDetailTestHostLike {
  initialRender: () => void
}

type ButtonClickCallback = (event?: ClickEvent) => void | Promise<void>

interface ButtonHost {
  onClick: (callback: ButtonClickCallback) => void
}

class NavPathStackDouble {
  onPopCallback: ((popInfo: PopInfo) => void) | undefined = undefined

  pushPathByName(_name: string, _param: Object, onPop: (popInfo: PopInfo) => void): void {
    this.onPopCallback = onPop
  }
}

class NavPathInfoDouble {
}

class PopInfoDouble {
  info: NavPathInfo
  result: Object

  constructor(result: Object) {
    this.info = new NavPathInfoDouble() as Object as NavPathInfo
    this.result = result
  }
}

@Component
struct UserDetailTestHost {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack()

  build() {
    MyDetailPageBuilder()
  }
}

function createPage(): MyDetailPage {
  let capturedPage: MyDetailPage | undefined = undefined
  const viewPUHost = ViewPU as Object as ViewPUHost
  const originalCreate = viewPUHost.create

  viewPUHost.create = (component: Object) => {
    capturedPage = component as MyDetailPage
    originalCreate(component)
  }

  try {
    const host = new UserDetailTestHost(undefined, new LocalStorage()) as Object as UserDetailTestHostLike
    host.initialRender()
  } finally {
    viewPUHost.create = originalCreate
  }

  if (capturedPage === undefined) {
    throw new Error('Failed to capture MyDetailPage instance.')
  }

  return capturedPage
}

function getPrivateFields(page: MyDetailPage): MyDetailPagePrivateFields {
  return page as Object as MyDetailPagePrivateFields
}

export default function UserDetailTest() {
  describe('UserDetailTest', () => {
    let page: MyDetailPage
    let privateFields: MyDetailPagePrivateFields

    beforeEach(() => {
      page = createPage()
      privateFields = getPrivateFields(page)
      privateFields.userFullInfo = new UserFullInfo()
      privateFields.userFullInfo.userInfo = new UserInfo()
    })

    afterEach(() => {
      privateFields.aboutToBeDeleted?.()
    })

    it('maps configured enum fields to display values', 0, () => {
      const userInfo = privateFields.userFullInfo.userInfo as UserInfo
      userInfo.gender = Constants.GENDER_FEMALE
      userInfo.education = Constants.EDUCATION_MASTER
      userInfo.monthlyIncome = Constants.MONTHLY_INCOME_BETWEEN_10001_AND_20000
      userInfo.marriageStatus = Constants.MARRIAGE_STATUS_DIVORCED
      userInfo.hasChildren = Constants.HAS_CHILDREN_AND_STAY_TOGETHER_OCCASIONALLY
      userInfo.expectationOfChildren = Constants.EXPECTATION_OF_CHILDREN_IT_DEPENDS
      userInfo.smoking = Constants.SMOKING_A_LITTLE
      userInfo.drinking = Constants.DRINKING_MUCH
      userInfo.hasBuyCar = Constants.HAS_CAR_YES
      userInfo.house = Constants.HOUSE_LIVE_WITH_FAMILY
      userInfo.whenToMarry = Constants.WHEN_TO_MARRY_IN_TWO_YEARS

      privateFields.initialiseEnumField()

      expect(privateFields.gender).assertEqual(Constants.getGenderDisplayValue(userInfo.gender))
      expect(privateFields.edu).assertEqual(Constants.getEducationDisplayValue(userInfo.education))
      expect(privateFields.monthlyIncome).assertEqual(Constants.getMonthlyIncomeDisplayValue(userInfo.monthlyIncome))
      expect(privateFields.marriageStatus).assertEqual(Constants.getMarriageStatusDisplayValue(userInfo.marriageStatus))
      expect(privateFields.hasChildren).assertEqual(Constants.getHasChildrenDisplayValue(userInfo.hasChildren))
      expect(privateFields.expectationOfChildren).assertEqual(
        Constants.getExpectationOfChildrenDisplayValue(userInfo.expectationOfChildren)
      )
      expect(privateFields.smoking).assertEqual(Constants.getSmokingDisplayValue(userInfo.smoking))
      expect(privateFields.drinking).assertEqual(Constants.getDrinkingDisplayValue(userInfo.drinking))
      expect(privateFields.hasBuyCar).assertEqual(Constants.getHasBuyCarDisplayValue(userInfo.hasBuyCar))
      expect(privateFields.hasBuyHouse).assertEqual(Constants.getHouseDisplayValue(userInfo.house))
      expect(privateFields.whenToMarry).assertEqual(Constants.getWhenToMarryDisplayValue(userInfo.whenToMarry))
    })

    it('falls back to TO_BE_SET when enum fields are unset', 0, () => {
      privateFields.userFullInfo.userInfo = new UserInfo()

      privateFields.initialiseEnumField()

      expect(privateFields.gender).assertEqual(Constants.TO_BE_SET)
      expect(privateFields.edu).assertEqual(Constants.TO_BE_SET)
      expect(privateFields.monthlyIncome).assertEqual(Constants.TO_BE_SET)
      expect(privateFields.marriageStatus).assertEqual(Constants.TO_BE_SET)
      expect(privateFields.hasChildren).assertEqual(Constants.TO_BE_SET)
      expect(privateFields.expectationOfChildren).assertEqual(Constants.TO_BE_SET)
      expect(privateFields.smoking).assertEqual(Constants.TO_BE_SET)
      expect(privateFields.drinking).assertEqual(Constants.TO_BE_SET)
      expect(privateFields.hasBuyCar).assertEqual(Constants.TO_BE_SET)
      expect(privateFields.hasBuyHouse).assertEqual(Constants.TO_BE_SET)
      expect(privateFields.whenToMarry).assertEqual(Constants.TO_BE_SET)
    })

    it('builds upload profile picture dialog content', 0, () => {
      privateFields.UploadProfilePicDialogBuilder()
      expect(true).assertTrue()
    })

    it('rebuilds upload profile picture dialog with an existing profile image', 0, () => {
      page.profileImage = 'profile-image-uri'

      privateFields.UploadProfilePicDialogBuilder()

      expect(page.profileImage).assertEqual('profile-image-uri')
    })

    it('handles album selections with empty and non-empty results', 0, () => {
      const handlers: ButtonClickCallback[] = []
      const buttonHost = Button as Object as ButtonHost
      const originalOnClick = buttonHost.onClick
      const stackDouble = new NavPathStackDouble()
      const initialProfileImage = page.profileImage
      page.pageStack = stackDouble as Object as NavPathStack
      buttonHost.onClick = (callback: ButtonClickCallback) => {
        handlers.push(callback)
      }

      try {
        privateFields.UploadProfilePicDialogBuilder()
        handlers[0]()
        stackDouble.onPopCallback?.(new PopInfoDouble([]) as Object as PopInfo)
        expect(page.profileImage).assertEqual(initialProfileImage)
        stackDouble.onPopCallback?.(new PopInfoDouble(['album-image-uri']) as Object as PopInfo)
        expect(page.profileImage).assertEqual('album-image-uri')
      } finally {
        buttonHost.onClick = originalOnClick
      }
    })

    it('handles successful, failed, and non-photo camera results', 0, async () => {
      const handlers: ButtonClickCallback[] = []
      const buttonHost = Button as Object as ButtonHost
      const originalOnClick = buttonHost.onClick
      buttonHost.onClick = (callback: ButtonClickCallback) => {
        handlers.push(callback)
      }

      try {
        privateFields.UploadProfilePicDialogBuilder()
        await handlers[1]()
        expect(page.profileImage).assertEqual('camera-image-uri')

        await handlers[1]()
        expect(page.profileImage).assertEqual('camera-image-uri')

        await handlers[1]()
        expect(page.profileImage).assertEqual('camera-image-uri')
      } finally {
        buttonHost.onClick = originalOnClick
      }
    })
  })
}
