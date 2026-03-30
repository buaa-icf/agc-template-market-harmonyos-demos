import { describe, beforeAll, afterAll, it } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';

const HOST_MEMBER_AGREEMENT_PAGE_BUTTON_ID = 'member_agreement_page_test_open';
const MEMBER_AGREEMENT_PAGE_ROOT_ID = 'member_agreement_page_root';
const MEMBER_AGREEMENT_PAGE_SCROLL_ID = 'member_agreement_page_scroll';
const DRIVER = Driver.create();

async function findByText(text: string, timeout: number = 5000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.text(text), timeout);
  if (component === null) {
    throw new Error(`Unable to find text: ${text}`);
  }
  return component;
}

async function findById(id: string, timeout: number = 5000): Promise<Component> {
  const component = await DRIVER.waitForComponent(ON.id(id), timeout);
  if (component === null) {
    throw new Error(`Unable to find id: ${id}`);
  }
  return component;
}

async function clickById(id: string, timeout: number = 5000): Promise<void> {
  await (await findById(id, timeout)).click();
  await DRIVER.waitForIdle(500, 5000);
}

async function assertTextVisible(text: string, timeout: number = 5000): Promise<void> {
  await findByText(text, timeout);
}

async function scrollToBottomById(id: string, timeout: number = 5000): Promise<void> {
  await (await findById(id, timeout)).scrollToBottom();
  await DRIVER.waitForIdle(1000, 5000);
}

async function waitForHostPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(HOST_MEMBER_AGREEMENT_PAGE_BUTTON_ID, 10000);
}

async function waitForMemberAgreementPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(MEMBER_AGREEMENT_PAGE_ROOT_ID, 10000);
}

export default function MemberAgreementPageTest() {
  describe('MemberAgreementPageTest', () => {
    beforeAll(async () => {
      await waitForHostPageLoaded();
    });

    afterAll(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_renders_member_agreement_sections', 0, async () => {
      await clickById(HOST_MEMBER_AGREEMENT_PAGE_BUTTON_ID);
      await waitForMemberAgreementPageLoaded();

      await assertTextVisible('《会员服务协议》');
      await assertTextVisible('会员服务协议');
      await assertTextVisible('生效日期：2025年1月1日');
      await assertTextVisible('欢迎您使用我们的会员服务！请仔细阅读以下条款和条件。');
      await assertTextVisible('1. 会员权益');
      await assertTextVisible('2. 会员费用');
      await assertTextVisible('3. 服务期限');
      await assertTextVisible('4. 用户义务');

      await scrollToBottomById(MEMBER_AGREEMENT_PAGE_SCROLL_ID);
      await assertTextVisible('5. 服务变更');
      await assertTextVisible('6. 联系我们');
      await assertTextVisible('最后更新时间：2025年1月1日');
    }, 60000);
  });
}
