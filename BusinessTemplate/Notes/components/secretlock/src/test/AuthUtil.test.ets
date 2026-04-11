import { describe, it, expect } from '@ohos/hypium'
import { AuthUtil } from '../main/ets/util/AuthUtil'

export default function AuthUtilTest() {
  describe('AuthUtilTest', () => {
    it('returns mapped messages for common framework error codes', 0, () => {
      expect(AuthUtil.getErrorMsg(201)).assertEqual(
        'Permission verification failed. The application does not have the permission required to call the API.'
      )
      expect(AuthUtil.getErrorMsg(202)).assertEqual(
        'Permission verification failed. A non-system application calls a system API.'
      )
      expect(AuthUtil.getErrorMsg(401)).assertEqual('Incorrect parameters.')
      expect(AuthUtil.getErrorMsg(801)).assertEqual(
        'Capability not supported. Failed to call the API due to limited device capabilities.'
      )
    })

    it('returns mapped messages for authentication result codes', 0, () => {
      expect(AuthUtil.getErrorMsg(12500001)).assertEqual('Authentication failed.')
      expect(AuthUtil.getErrorMsg(12500002)).assertEqual('General operation error.')
      expect(AuthUtil.getErrorMsg(12500003)).assertEqual('The operation is canceled.')
      expect(AuthUtil.getErrorMsg(12500004)).assertEqual('The operation is time-out.')
      expect(AuthUtil.getErrorMsg(12500005)).assertEqual('The authentication type is not supported.')
      expect(AuthUtil.getErrorMsg(12500006)).assertEqual('The authentication trust level is not supported.')
      expect(AuthUtil.getErrorMsg(12500007)).assertEqual('The authentication task is busy.')
      expect(AuthUtil.getErrorMsg(12500009)).assertEqual('The authenticator is locked.')
      expect(AuthUtil.getErrorMsg(12500010)).assertEqual('The type of credential has not been enrolled.')
      expect(AuthUtil.getErrorMsg(12500011)).assertEqual('Switched to the custom authentication process.')
      expect(AuthUtil.getErrorMsg(12700013)).assertEqual('Operation failed because of PIN expired.')
    })

    it('falls back to the provided default message for unknown error codes', 0, () => {
      expect(AuthUtil.getErrorMsg(99999999, 'custom fallback')).assertEqual('custom fallback')
    })

    it('returns an empty string for unknown error codes without a default message', 0, () => {
      expect(AuthUtil.getErrorMsg(99999999)).assertEqual('')
    })
  })
}
