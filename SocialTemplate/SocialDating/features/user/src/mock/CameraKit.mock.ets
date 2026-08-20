class PickerMediaTypeMock {
  PHOTO: string = 'photo'
  VIDEO: string = 'video'
}

class PickerResultMock {
  resultCode: number
  mediaType: string
  resultUri: string

  constructor(resultCode: number, mediaType: string, resultUri: string) {
    this.resultCode = resultCode
    this.mediaType = mediaType
    this.resultUri = resultUri
  }
}

class CameraPickerMock {
  PickerMediaType: PickerMediaTypeMock = new PickerMediaTypeMock()
  private pickCount: number = 0

  async pick(_context: Context, _mediaTypes: string[], _profile: Object): Promise<PickerResultMock> {
    this.pickCount++
    if (this.pickCount % 3 === 1) {
      return new PickerResultMock(0, this.PickerMediaType.PHOTO, 'camera-image-uri')
    }
    if (this.pickCount % 3 === 2) {
      return new PickerResultMock(1, this.PickerMediaType.PHOTO, 'ignored-failed-camera-uri')
    }
    return new PickerResultMock(0, this.PickerMediaType.VIDEO, 'ignored-video-uri')
  }
}

export default new CameraPickerMock()
