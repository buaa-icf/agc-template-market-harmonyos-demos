import { ReaderToolBar } from '../../../../../../../../src/main/ets/components/ReaderToolBar.ets';

interface MockUserInfo {
  bookCoins: number;
  continuousBuy: boolean;
}

interface MockCatalogItem {
  href?: string;
  resourceFile?: string;
  catalogName?: string;
  catalogId?: number;
}

interface MockSpineItem {
  idRef: string;
  index: number;
  href: string;
  properties: string;
}

interface MockReaderSetting {
  fontName: string;
  fontPath: string;
  fontSize: number;
  fontColor: string;
  fontWeight: number;
  lineHeight: number;
  nightMode: boolean;
  themeColor: string;
  themeBgImg: string;
  flipMode: string;
  scaledDensity: number;
  viewPortWidth: number;
  viewPortHeight: number;
}

class MockReaderComponentController {
  setPageConfig(_readerSetting: MockReaderSetting): void {
  }

  startPlay(_resourceIndex: number, _domPos: string): void {
  }
}

@Entry
@Component
struct Index {
  private readerComponentController: MockReaderComponentController = new MockReaderComponentController();
  private lockedStatus: boolean[] = [];
  private catalogItemList: MockCatalogItem[] = [];
  private spineList: MockSpineItem[] = [];
  private readerSetting: MockReaderSetting = {
    fontName: '',
    fontPath: '',
    fontSize: 18,
    fontColor: '#000000E6',
    fontWeight: 100,
    lineHeight: 2,
    nightMode: false,
    themeColor: 'rgba(251, 240, 219, 1)',
    themeBgImg: '',
    flipMode: '0',
    scaledDensity: 1,
    viewPortWidth: 1080,
    viewPortHeight: 1920
  };

  aboutToAppear(): void {
    const userInfo: MockUserInfo = {
      bookCoins: 100,
      continuousBuy: false
    };
    AppStorage.setOrCreate('userInfo', userInfo);
  }

  build() {
    Column() {
      ReaderToolBar({
        readerComponentController: this.readerComponentController,
        bookParserHandler: null,
        lockedStatus: this.lockedStatus,
        curChapterId: 0,
        catalogItemList: this.catalogItemList,
        spineList: this.spineList,
        readerSetting: this.readerSetting
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.End)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}
