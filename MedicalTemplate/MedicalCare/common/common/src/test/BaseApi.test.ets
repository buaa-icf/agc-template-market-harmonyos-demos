import { authentication } from '@kit.AccountKit';
import { describe, expect, it } from '@ohos/hypium';

import { BaseApi, RequestMethod } from '../main/ets/api/BaseApi';
import { BaseError } from '../main/ets/exception/BaseError';
import { BaseResponse } from '../main/ets/model/BaseResponse';
import { AuthenticationUtil } from '../main/ets/utils/AuthenticationUtil';
import { HttpUtil } from '../main/ets/utils/HttpUtil';

class MockPayload {
  id: string = '';
  value: string = '';
}

class FakeCredential {
  openID: string = 'auth-token';
}

class CallbackRecorder {
  public values: string[] = [];

  public record(payload: MockPayload): void {
    this.values.push(payload.value);
  }

  public dump(): string {
    return this.values.join(',');
  }
}

class LoadingRecorder {
  public values: boolean[] = [];

  public record(isLoading: boolean): void {
    this.values.push(isLoading);
  }

  public dump(): string {
    return this.values.map((item: boolean) => String(item)).join(',');
  }
}

class PreferenceDouble {
  public cachedValue: MockPayload | undefined = undefined;
  public savedKey: string = '';
  public savedValue: string = '';

  public get(_key: string, defaultValue?: object | string): object | string | undefined {
    if (this.cachedValue !== undefined) {
      return this.cachedValue;
    }
    return defaultValue;
  }

  public put(key: string, value: object | string): void {
    this.savedKey = key;
    this.savedValue = JSON.stringify(value);
  }
}

class HttpUtilDouble extends HttpUtil {
  public nextGetResponse: BaseResponse | undefined = undefined;
  public nextPostResponse: BaseResponse | undefined = undefined;
  public nextPutError: BaseError | undefined = undefined;
  public nextDeleteResponse: BaseResponse | undefined = undefined;

  constructor() {
    super('http://unit.test');
  }

  public async get<T>(_url: string, _params?: object): Promise<T> {
    return this.nextGetResponse as T;
  }

  public async post<T>(_url: string, _data?: object): Promise<T> {
    return this.nextPostResponse as T;
  }

  public async put<T>(_url: string, _data?: object): Promise<T> {
    throw this.nextPutError as BaseError;
  }

  public async delete<T>(_url: string, _data?: object): Promise<T> {
    return this.nextDeleteResponse as T;
  }
}

class ResponseFactory {
  public static createPayloadResponse(code: number, message: string, payloadValue: string): BaseResponse {
    const payload = new MockPayload();
    payload.id = 'payload-id';
    payload.value = payloadValue;

    const response = new BaseResponse<MockPayload>();
    response.code = code;
    response.message = message;
    response.data = payload;
    return response as BaseResponse;
  }
}

class BaseApiMutableView {
  authorization: string = '';
  preferenceUtil: PreferenceDouble = new PreferenceDouble();
  httpUtil: HttpUtilDouble = new HttpUtilDouble();
}

class BaseApiAccessor {
  public static setAuthorization(api: BaseApi, value: string): void {
    (api as Object as BaseApiMutableView).authorization = value;
  }

  public static setPreferenceUtil(api: BaseApi, value: PreferenceDouble): void {
    (api as Object as BaseApiMutableView).preferenceUtil = value;
  }

  public static setHttpUtil(api: BaseApi, value: HttpUtilDouble): void {
    (api as Object as BaseApiMutableView).httpUtil = value;
  }
}

export default function BaseApiTest() {
  describe('BaseApiTest', () => {
    it('applies the expected default config values when optional fields are omitted', 0, () => {
      const api = new BaseApi({
        showLoading: false
      });

      expect(api.config.baseUrl).assertEqual('http://10.0.2.2:8080');
      expect(api.config.isMock).assertEqual(false);
      expect(api.config.showLoading).assertEqual(false);
      expect(api.config.showDefaultErrorToast).assertEqual(true);
    });

    it('uses cached data first and then returns the fresh GET response', 0, async () => {
      const loadingRecorder = new LoadingRecorder();
      const api = new BaseApi({
        showLoading: false,
        showDefaultErrorToast: false,
        onLoadingCallback: (isLoading: boolean) => {
          loadingRecorder.record(isLoading);
        }
      });
      const callbackRecorder = new CallbackRecorder();
      const preferenceDouble = new PreferenceDouble();
      const httpUtilDouble = new HttpUtilDouble();
      const cachedPayload = new MockPayload();

      cachedPayload.id = 'cached-id';
      cachedPayload.value = 'cached-value';
      preferenceDouble.cachedValue = cachedPayload;
      httpUtilDouble.nextGetResponse = ResponseFactory.createPayloadResponse(0, 'ok', 'fresh-value');

      AuthenticationUtil.loginWithHuaweiIDCredential = new FakeCredential() as authentication.LoginWithHuaweiIDCredential;
      BaseApiAccessor.setPreferenceUtil(api, preferenceDouble);
      BaseApiAccessor.setHttpUtil(api, httpUtilDouble);

      const data = await api.sendRequest<MockPayload>('/patient', RequestMethod.GET, undefined, undefined,
        (payload: MockPayload) => {
          callbackRecorder.record(payload);
        });

      expect(data.value).assertEqual('fresh-value');
      expect(callbackRecorder.dump()).assertEqual('cached-value,fresh-value');
      expect(preferenceDouble.savedKey).assertContain('/patient_0_auth-token');
      expect(preferenceDouble.savedValue).assertContain('fresh-value');
      expect(loadingRecorder.dump()).assertEqual('true,false');
      AuthenticationUtil.loginWithHuaweiIDCredential = undefined;
    });

    it('routes POST requests through httpUtil.post and returns the parsed payload', 0, async () => {
      const api = new BaseApi({
        showLoading: false,
        showDefaultErrorToast: false
      });
      const httpUtilDouble = new HttpUtilDouble();

      httpUtilDouble.nextPostResponse = ResponseFactory.createPayloadResponse(0, 'ok', 'post-value');
      BaseApiAccessor.setAuthorization(api, 'auth-token');
      BaseApiAccessor.setHttpUtil(api, httpUtilDouble);

      const data = await api.sendRequest<MockPayload>('/patient', RequestMethod.POST, undefined, false);

      expect(data.value).assertEqual('post-value');
    });

    it('routes PUT requests through httpUtil.put and propagates transport failures', 0, async () => {
      const api = new BaseApi({
        showLoading: false,
        showDefaultErrorToast: false
      });
      const httpUtilDouble = new HttpUtilDouble();
      let errorMessage = '';

      httpUtilDouble.nextPutError = new BaseError('put failed');
      BaseApiAccessor.setAuthorization(api, 'auth-token');
      BaseApiAccessor.setHttpUtil(api, httpUtilDouble);

      try {
        await api.sendRequest<MockPayload>('/patient', RequestMethod.PUT, undefined, false);
      } catch (error) {
        errorMessage = (error as BaseError).message;
      }

      expect(errorMessage).assertEqual('put failed');
    });

    it('routes DELETE requests through httpUtil.delete and converts non-zero codes into BaseError', 0, async () => {
      const api = new BaseApi({
        showLoading: false,
        showDefaultErrorToast: false
      });
      const httpUtilDouble = new HttpUtilDouble();
      let errorMessage = '';

      httpUtilDouble.nextDeleteResponse = ResponseFactory.createPayloadResponse(1, 'delete failed', 'delete-value');
      BaseApiAccessor.setAuthorization(api, 'auth-token');
      BaseApiAccessor.setHttpUtil(api, httpUtilDouble);

      try {
        await api.sendRequest<MockPayload>('/patient', RequestMethod.DELETE, undefined, false);
      } catch (error) {
        errorMessage = (error as BaseError).message;
      }

      expect(errorMessage).assertEqual('delete failed');
    });

    it('rejects unsupported request methods before sending a request', 0, async () => {
      const api = new BaseApi({
        showLoading: false,
        showDefaultErrorToast: false
      });
      let errorMessage = '';

      try {
        await api.sendRequest<MockPayload>('/unit/test', 99 as RequestMethod, undefined, false);
      } catch (error) {
        errorMessage = (error as BaseError).message;
      }

      expect(errorMessage).assertEqual('Method not implemented.');
    });
  });
}
