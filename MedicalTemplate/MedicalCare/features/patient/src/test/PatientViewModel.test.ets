import { describe, expect, it } from '@ohos/hypium'

import { PatientModel } from '../main/ets/model/PatientModel'
import { PatientViewModel } from '../main/ets/viewmodel/PatientViewModel'

function createValidPatient(): PatientModel {
  const patient = new PatientModel()
  patient.patientName = '张三'
  patient.phone = '13800138000'
  patient.idCardType = '身份证'
  patient.idCard = '110101199001011234'
  patient.sex = '男'
  patient.birthday = '1990-01-01'
  patient.country = '中国'
  patient.city = '北京'
  patient.address = '朝阳区阜通东大街'
  patient.insuranceType = '职工医保'
  return patient
}

function createViewModel(): PatientViewModel {
  const viewModel = new PatientViewModel()
  viewModel.patientList = []
  viewModel.defaultPatient = null
  viewModel.patientDetailInfo = createValidPatient()
  return viewModel
}

export default function PatientViewModelTest() {
  describe('PatientViewModelTest', () => {
    it('stops bindPatient when the patient name is blank', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.patientName = ' '

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the phone is blank', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.phone = ' '

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the id card type is blank', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.idCardType = ' '

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the id card is blank', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.idCard = ' '

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the sex is blank', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.sex = ' '

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the birthday is blank', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.birthday = ' '

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the country is blank', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.country = ' '

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the city is blank', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.city = ' '

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the address is blank', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.address = ' '

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the insurance type is blank', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.insuranceType = ' '

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the patient name is too long', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.patientName = '张三张三张三张'

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the phone length is invalid', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.phone = '1380013800'

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the id card length is invalid', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.idCardType = '身份证'
      viewModel.patientDetailInfo.idCard = '12345678901234'

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the passport length is invalid', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.idCardType = '护照'
      viewModel.patientDetailInfo.idCard = '123456'

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('stops bindPatient when the hk permit length is invalid', 0, () => {
      const viewModel = createViewModel()
      viewModel.patientDetailInfo.idCardType = '港澳通行证'
      viewModel.patientDetailInfo.idCard = '1234567'

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
      expect(viewModel.isLoading).assertEqual(false)
    })

    it('keeps the patient list unchanged when valid data is submitted in edit mode', 0, () => {
      const viewModel = createViewModel()

      viewModel.bindPatient()

      expect(viewModel.patientList.length).assertEqual(0)
    })
  })
}
