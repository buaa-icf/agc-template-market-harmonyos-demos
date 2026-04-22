import { describe, beforeAll, afterAll, it, expect } from '@ohos/hypium'
import { Driver, ON, Component } from '@kit.TestKit'

const HOST_PAGE_ID = 'transaction_search_host_page'
const EMPTY_BUTTON_ID = 'transaction_search_host_empty'
const TOTAL_ID = 'transaction_search_total'
const EMPTY_ID = 'transaction_search_empty'
const DETAIL_PARAM_ID = 'transaction_search_detail_param'
const DETAIL_BACK_ID = 'transaction_search_detail_back'
const DRIVER = Driver.create()

async function waitForIdle(delayMs: number = 500): Promise<void> {
  await DRIVER.waitForIdle(delayMs, 10000)
}

async function findById(id: string, timeout: number = 5000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout)
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`)
  }
  return component
}

async function waitForSearchPageLoaded(): Promise<void> {
  await waitForIdle(1000)
  await findById(TOTAL_ID, 10000)
}

async function waitForHostPageLoaded(): Promise<void> {
  await waitForIdle()
  await findById(HOST_PAGE_ID, 10000)
}

async function getTextById(id: string, timeout: number = 5000): Promise<string> {
  return await (await findById(id, timeout)).getText()
}

export default function TransactionSearchTest() {
  describe('TransactionSearchTest', () => {
    beforeAll(async () => {
      await waitForSearchPageLoaded()
    })

    afterAll(async () => {
      await waitForIdle()
    })

    it('build_renders_transaction_rows_and_routes_to_detail', 0, async () => {
      expect(await getTextById('transaction_search_name_101')).assertEqual('Alpha Fund')
      expect(await getTextById('transaction_search_name_102')).assertEqual('Beta Income')
      expect(await getTextById('transaction_search_name_103')).assertEqual('Gamma Cash')
      expect(await getTextById(TOTAL_ID)).assertContain('3')

      await (await findById('transaction_search_item_101')).click()
      await waitForIdle()

      expect(await getTextById(DETAIL_PARAM_ID, 10000)).assertEqual('Detail:101')

      await (await findById(DETAIL_BACK_ID)).click()
      await waitForHostPageLoaded()
    })

    it('build_shows_empty_state_when_transaction_list_is_empty', 0, async () => {
      await (await findById(EMPTY_BUTTON_ID)).click()
      await waitForSearchPageLoaded()

      expect(await getTextById(TOTAL_ID)).assertContain('0')
      await findById(EMPTY_ID, 10000)
    })
  })
}
