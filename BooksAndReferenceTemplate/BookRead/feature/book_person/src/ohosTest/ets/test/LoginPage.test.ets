import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { Driver, ON, Component } from '@kit.TestKit';
import { loginComponentManager } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Constants, TCRouter } from 'common';
import { UserInfo } from 'base_common';
import { ErrorCode, LoginPage } from '../../../main/ets/views/LoginPage';

const HOST_OPEN_BUTTON_ID = 'login_page_test_open';
const LOGIN_PAGE_ROOT_ID = 'login_page_root';
const LOGIN_PAGE_HUAWEI_BUTTON_ID = 'login_page_huawei_button';
const LOGIN_PAGE_AGREEMENT_CHECKBOX_ID = 'login_page_agreement_checkbox';
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

async function findByIdOrNull(id: string, timeout: number = 1000): Promise<Component | null> {
  return await DRIVER.waitForComponent(ON.id(id), timeout);
}

async function clickById(id: string, timeout: number = 5000): Promise<void> {
  await (await findById(id, timeout)).click();
  await DRIVER.waitForIdle(500, 5000);
}

async function assertTextVisible(text: string, timeout: number = 5000): Promise<void> {
  await findByText(text, timeout);
}

async function waitForHostPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(HOST_OPEN_BUTTON_ID, 10000);
}

async function waitForLoginPageLoaded(): Promise<void> {
  await DRIVER.waitForIdle(1000, 10000);
  await findById(LOGIN_PAGE_ROOT_ID, 10000);
}

async function ensureHostPageLoaded(): Promise<void> {
  const deadline = new Date().getTime() + 15000;
  while (new Date().getTime() <= deadline) {
    const hostPage = await findByIdOrNull(HOST_OPEN_BUTTON_ID, 1000);
    if (hostPage !== null) {
      return;
    }

    const loginPage = await findByIdOrNull(LOGIN_PAGE_ROOT_ID, 1000);
    if (loginPage !== null) {
      await DRIVER.pressBack();
      await DRIVER.waitForIdle(1000, 5000);
    } else {
      await DRIVER.waitForIdle(500, 1000);
    }
  }

  throw new Error('Unable to reach login page test host');
}

function clearLoginStorage(): void {
  AppStorage.setOrCreate('userInfo', undefined);
  AppStorage.setOrCreate('membershipStatus', undefined);
  AppStorage.setOrCreate('bookCoins', undefined);
}

function createCredential(): loginComponentManager.HuaweiIDCredential {
  return {
    authorizationCode: 'auth-code',
    openID: 'open-id',
    unionID: 'union-id',
    idToken: 'id-token'
  } as loginComponentManager.HuaweiIDCredential;
}

function createBusinessError(code: number, message: string): BusinessError {
  return {
    code,
    message,
    name: 'BusinessError'
  } as BusinessError;
}

async function wait(milliseconds: number): Promise<void> {
  await new Promise<void>((resolve: () => void) => {
    setTimeout(() => {
      resolve();
    }, milliseconds);
  });
}

export default function LoginPageTest() {
  describe('LoginPageTest', () => {
    beforeAll(async () => {
      clearLoginStorage();
      await ensureHostPageLoaded();
    });

    beforeEach(() => {
      clearLoginStorage();
    });

    afterEach(async () => {
      await DRIVER.waitForIdle(500, 5000);
    });

    afterAll(async () => {
      clearLoginStorage();
      await DRIVER.waitForIdle(500, 5000);
    });

    it('build_renders_login_content_and_agreement_controls', 0, async () => {
      await ensureHostPageLoaded();
      await clickById(HOST_OPEN_BUTTON_ID);
      await waitForLoginPageLoaded();

      await assertTextVisible('阅读听书');
      await assertTextVisible('阅读听书详细描述');
      await assertTextVisible('a11xxxx1111');
      await assertTextVisible('华为账号绑定号码');
      await findById(LOGIN_PAGE_HUAWEI_BUTTON_ID, 5000);
      await findById(LOGIN_PAGE_AGREEMENT_CHECKBOX_ID, 5000);

      await DRIVER.pressBack();
      await waitForHostPageLoaded();
    }, 60000);

    it('handleLoginWithHuaweiIDButton_logs_in_selected_user', 0, async () => {
      const page = new LoginPage();
      const response = createCredential();

      TCRouter.init();
      TCRouter.replace(Constants.LOGIN_ROUTE);
      AppStorage.setOrCreate('membershipStatus', true);
      AppStorage.setOrCreate('bookCoins', 18);
      page.isSelected = true;

      page.handleLoginWithHuaweiIDButton(undefined, response);

      const savedUserInfo = AppStorage.get('userInfo') as UserInfo;
      expect(savedUserInfo !== undefined).assertEqual(true);
      expect(savedUserInfo.nickName).assertEqual('华为用户');
      expect(savedUserInfo.isLogin).assertEqual(true);
      expect(savedUserInfo.isMembership).assertEqual(true);
      expect(savedUserInfo.bookCoins).assertEqual(18);

      await wait(400);
    });

    it('handleLoginWithHuaweiIDButton_keeps_logged_out_state_for_known_errors', 0, () => {
      const page = new LoginPage();
      const error = createBusinessError(ErrorCode.ERROR_CODE_LOGIN_OUT, 'logout');

      TCRouter.init();
      TCRouter.replace(Constants.LOGIN_ROUTE);
      page.handleLoginWithHuaweiIDButton(error, createCredential());

      expect(AppStorage.get('userInfo') === undefined).assertEqual(true);
    });
  });
}
