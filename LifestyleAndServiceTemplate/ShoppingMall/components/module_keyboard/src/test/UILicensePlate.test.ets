import { afterEach, describe, expect, it } from '@ohos/hypium'

import { UILicensePlate } from '../main/ets/components/UILicensePlate'

interface KeyItemLike {
  key: string
  disable: boolean
}

interface UILicensePlateLike {
  inputIndex: number
  keyBordTotal: Array<Array<KeyItemLike>>
  updateView(): void
  aboutToBeDeleted?(): void
}

class UILicensePlateParams extends LocalStorage {
  intFocus: boolean = false
  plateNumber: string = ''
  onChange: (carNumber: string[], isComplete: boolean) => void = (_carNumber: string[], _isComplete: boolean): void => {
  }
  onFormatError: (plateNumber: string) => void = (_plateNumber: string): void => {
  }
}

const createdComponents: Array<UILicensePlateLike> = []

function createComponent(): UILicensePlateLike {
  const component = new UILicensePlate(undefined, new UILicensePlateParams()) as UILicensePlateLike
  createdComponents.push(component)
  return component
}

function findKeyItem(component: UILicensePlateLike, key: string): KeyItemLike {
  for (let rowIndex = 0; rowIndex < component.keyBordTotal.length; rowIndex++) {
    const row = component.keyBordTotal[rowIndex]
    for (let columnIndex = 0; columnIndex < row.length; columnIndex++) {
      const item = row[columnIndex]
      if (item.key === key) {
        return item
      }
    }
  }
  throw new Error(`key ${key} not found`)
}

function expectKeyDisabled(component: UILicensePlateLike, key: string, expectedDisabled: boolean): void {
  expect(findKeyItem(component, key).disable).assertEqual(expectedDisabled)
}

export default function UILicensePlateTest() {
  describe('UILicensePlateTest', () => {
    afterEach(() => {
      while (createdComponents.length > 0) {
        createdComponents.pop()?.aboutToBeDeleted?.()
      }
    })

    it('disables digits and special suffix keys for the second plate character', 0, () => {
      const component = createComponent()
      component.inputIndex = 1

      component.updateView()

      expectKeyDisabled(component, '1', true)
      expectKeyDisabled(component, '港', true)
      expectKeyDisabled(component, '警', true)
      expectKeyDisabled(component, 'A', false)
      expectKeyDisabled(component, 'Q', false)
    })

    it('disables O and suffix keys for the standard alphanumeric positions', 0, () => {
      const standardIndexes: Array<number> = [2, 3, 4, 5, 7]

      for (let index = 0; index < standardIndexes.length; index++) {
        const component = createComponent()
        component.inputIndex = standardIndexes[index]

        component.updateView()

        expectKeyDisabled(component, 'O', true)
        expectKeyDisabled(component, '港', true)
        expectKeyDisabled(component, '澳', true)
        expectKeyDisabled(component, '学', true)
        expectKeyDisabled(component, '警', true)
        expectKeyDisabled(component, '1', false)
        expectKeyDisabled(component, 'Q', false)
      }
    })

    it('only disables O for the sixth alphanumeric position', 0, () => {
      const component = createComponent()
      component.inputIndex = 6

      component.updateView()

      expectKeyDisabled(component, 'O', true)
      expectKeyDisabled(component, '港', false)
      expectKeyDisabled(component, '澳', false)
      expectKeyDisabled(component, '学', false)
      expectKeyDisabled(component, '警', false)
      expectKeyDisabled(component, '1', false)
    })

    it('keeps the current keyboard state when the province position is focused', 0, () => {
      const component = createComponent()
      component.inputIndex = 6
      component.updateView()

      const disabledO = findKeyItem(component, 'O').disable
      const disabledGang = findKeyItem(component, '港').disable
      const disabledOne = findKeyItem(component, '1').disable

      component.inputIndex = 0
      component.updateView()

      expectKeyDisabled(component, 'O', disabledO)
      expectKeyDisabled(component, '港', disabledGang)
      expectKeyDisabled(component, '1', disabledOne)
    })
  })
}
