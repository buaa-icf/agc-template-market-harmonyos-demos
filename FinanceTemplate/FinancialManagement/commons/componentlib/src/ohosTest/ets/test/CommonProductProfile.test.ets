import { describe, beforeAll, it, expect } from '@ohos/hypium'
import { Driver, ON } from '@kit.TestKit'

const DRIVER = Driver.create()
const UI_TIMEOUT = 10000
const HOST_PAGE_ID = 'common_product_profile_host_page'
const WITH_CONTRACT_BUTTON_ID = 'common_product_profile_with_contract_button'
const WITHOUT_CONTRACT_BUTTON_ID = 'common_product_profile_without_contract_button'
const TITLE_ID = 'common_product_profile_title'
const CONTRACT_ACTION_ID = 'common_product_profile_contract_action'
const INFORMATION_ACTION_ID = 'common_product_profile_information_action'
const LAST_ROUTE_ID = 'common_product_profile_last_route'
const LAST_PARAM_ID = 'common_product_profile_last_param'

async function waitForIdle(milliseconds: number = 600): Promise<void> {
  await DRIVER.delayMs(milliseconds)
}

async function findById(id: string, timeout: number = UI_TIMEOUT) {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout)
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`)
  }
  return component
}

async function assertTextVisible(text: string, timeout: number = UI_TIMEOUT): Promise<void> {
  const component = await DRIVER.waitForComponent(ON.text(text), timeout)
  if (component === null) {
    throw new Error(`Unable to find text: ${text}`)
  }
}

async function getTextById(id: string): Promise<string> {
  const component = await findById(id)
  return await component.getText()
}

export default function CommonProductProfileTest() {
  describe('CommonProductProfileTest', () => {
    beforeAll(async () => {
      await findById(HOST_PAGE_ID)
      await waitForIdle()
    })

    it('build_renders_profile_content_and_uses_preview_route_for_both_actions', 0, async () => {
      const withContractButton = await findById(WITH_CONTRACT_BUTTON_ID)
      await withContractButton.click()
      await waitForIdle()

      await findById(TITLE_ID)
      await findById(CONTRACT_ACTION_ID)
      await findById(INFORMATION_ACTION_ID)
      await assertTextVisible('Balanced Fund')
      await assertTextVisible('Alpha AMC')
      await assertTextVisible('CN-12345')
      await assertTextVisible('2025-01-02')

      const contractAction = await findById(CONTRACT_ACTION_ID)
      await contractAction.click()
      await waitForIdle()

      expect(await getTextById(LAST_ROUTE_ID)).assertEqual('Route:Preview')
      expect(await getTextById(LAST_PARAM_ID)).assertEqual('Param:contract-preview.pdf')

      const informationAction = await findById(INFORMATION_ACTION_ID)
      await informationAction.click()
      await waitForIdle()

      expect(await getTextById(LAST_ROUTE_ID)).assertEqual('Route:Preview')
      expect(await getTextById(LAST_PARAM_ID)).assertEqual('Param:contract-preview.pdf')
    })

    it('build_keeps_route_state_unchanged_when_contract_is_missing', 0, async () => {
      const withoutContractButton = await findById(WITHOUT_CONTRACT_BUTTON_ID)
      await withoutContractButton.click()
      await waitForIdle()

      const contractAction = await findById(CONTRACT_ACTION_ID)
      await contractAction.click()
      await waitForIdle()

      expect(await getTextById(LAST_ROUTE_ID)).assertEqual('Route:none')
      expect(await getTextById(LAST_PARAM_ID)).assertEqual('Param:none')

      const informationAction = await findById(INFORMATION_ACTION_ID)
      await informationAction.click()
      await waitForIdle()

      expect(await getTextById(LAST_ROUTE_ID)).assertEqual('Route:none')
      expect(await getTextById(LAST_PARAM_ID)).assertEqual('Param:none')
    })
  })
}
