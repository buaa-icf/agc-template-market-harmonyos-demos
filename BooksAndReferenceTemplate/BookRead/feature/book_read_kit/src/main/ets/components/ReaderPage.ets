import { BookApi, BookInfo, Constants, EpubUtils, ReadSet, TCRouter} from 'common';
import { bookParser, readerCore, ReadPageComponent } from '@kit.ReaderKit';
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { ReaderTopCard } from './ReaderTopCard';
import { BookCoverCard } from './BookCoverCard';
import { ReaderToolBar } from 'reader_tool_bar';
import { baseActionSheet,UserInfo } from 'base_common';

export class ReaderPageTestBridge {
  static enabled: boolean = false;
  static catalogItemList: bookParser.CatalogItem[] = [];
  static spineList: bookParser.SpineItem[] = [];
  static pageData: readerCore.PageDataInfo | undefined = undefined;
  static userInfo: UserInfo | undefined = undefined;
  static onComplete: ((lockedCount: number, chapterId: number, isLoading: boolean) => void) | undefined = undefined;
}

@ComponentV2
export struct ReaderPage {
  @Local userInfo: UserInfo | undefined
  @Local book: BookInfo | undefined = undefined
  @Local catalogItemList: bookParser.CatalogItem[] = [];
  @Local lockedStatus: boolean[] = []
  @Local curChapterId: number = 0
  @Local readerComponentController: readerCore.ReaderComponentController | null =
    ReaderPageTestBridge.enabled ? null : new readerCore.ReaderComponentController();
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Local bookParserHandler: bookParser.BookParserHandler | null = null;
  @Local spineList: bookParser.SpineItem[] = []
  private windowClass = this.context.windowStage.getMainWindowSync();
  @Local isLoading: boolean = true;
  @Local startTime: number = 0;
  @Local endTime: number = 0;
  @Local showController: boolean = false;
  @Local price: number = 10
  @Local isShowBuySheet: boolean = false
  @Provider('pageData') pageData: readerCore.PageDataInfo | undefined = undefined
  @Local readSet: ReadSet = AppStorageV2.connect(ReadSet, () => new ReadSet())!
  @Local readerSetting: readerCore.ReaderSetting = this.readSet.readerSetting
  windowTopHeight: number = AppStorage.get('windowTopHeight') as number
  bottomRectHeight: number = AppStorage.get('bottomRectHeight') as number
  textClockController: TextClockController = new TextClockController();

  private getReaderComponentController(): readerCore.ReaderComponentController {
    return this.readerComponentController!;
  }

  @Builder
  buildBuyChapter(index: number) {
    Column({ space: 8 }) {
      Text(`价格：${this.price}书币`)
      Text(`余额：${this.userInfo!.bookCoins}书币`)
      Row() {
        Checkbox()
          .onChange((value) => {
            this.userInfo!.continuousBuy = value
          })
        Text('自动购买下一章')
      }

      Button('购买')
        .onClick(() => {
          if (this.price > this.userInfo!.bookCoins!) {
            promptAction.showToast({
              message: '余额不足',
              duration: 2000
            });
          } else {
            this.userInfo!.bookCoins -= this.price
            this.lockedStatus[index] = false
            this.isShowBuySheet = false
            baseActionSheet.close('buyChapter')
          }
        })
        .width('100%')
    }
    .padding({ bottom: this.bottomRectHeight, left: 16, right: 16 })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  private resourceRequest: bookParser.CallbackRes<string, ArrayBuffer> = (fontName: string): ArrayBuffer => {
    if (this.isFont(fontName)) {
      let res = $rawfile(this.readerSetting.fontPath);
      let context = this.getUIContext().getHostContext();
      if (res && context) {
        try {
          // 获取资源路径下的字体数据
          let value: Uint8Array = context.resourceManager.getRawFileContentSync(this.readerSetting.fontPath);
          hilog.info(0x0000, 'testTag', 'resourceRequest : get success');
          return value.buffer as ArrayBuffer;
        } catch (error) {
          let code = (error as BusinessError).code;
          let message = (error as BusinessError).message;
          hilog.error(0x0000, 'testTag',
            `callback getRawFileContent failed, error code: ${code}, message: ${message}.`);
        }
      }
    }
    return new ArrayBuffer(0);
  }

  private isFont(filePath: string): boolean {
    let options = ['.ttf', '.woff2', '.otf'];
    let path = filePath.toLowerCase();
    let result = path.indexOf(options[0]) !== -1 || path.indexOf(options[1]) !== -1 || path.indexOf(options[2]) !== -1;
    hilog.info(0x0000, 'testTag', 'isFont = ' + result);
    return result;
  }

  async loadBook() {
    this.userInfo = AppStorage.get<UserInfo>('userInfo');
    this.startTime = systemDateTime.getTime(false)
    // mock同一本书
    this.book!.localPath =
      await EpubUtils.loadEpubFileFromNetwork('mock', this.book!.epubUrl, getContext(this).cacheDir)
    const hisRsp = await BookApi.getBooksShelfList('historyBooks', Constants.API_GET_BOOK_HISTORY_PATH, '');
    let books = hisRsp.books;
    let index = books.findIndex(book => book.id === this.book!.id)
    if (index !== -1) {
      books.splice(index, 1);
    }
    books.unshift(this.book!);
    AppStorage.set('historyBooks', books);
  }

  private async preprocess() {
    if (ReaderPageTestBridge.enabled) {
      this.catalogItemList = ReaderPageTestBridge.catalogItemList;
      this.spineList = ReaderPageTestBridge.spineList;
    } else {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      let initPromise: Promise<void> = this.getReaderComponentController().init(context);
    let defaultHandlerPromise: Promise<bookParser.BookParserHandler> =
      bookParser.getDefaultHandler(this.book?.localPath);
    let result: [bookParser.BookParserHandler, void] = await Promise.all([defaultHandlerPromise, initPromise]);
    this.bookParserHandler = result[0];
    // 获取目录列表
    this.catalogItemList = this.bookParserHandler.getCatalogList() || [];
    // 获取书脊内容列表
    this.spineList = this.bookParserHandler.getSpineList();
    }
    if (this.book?.isFree! === '2') {
      this.lockedStatus = AppStorageV2.connect(Array, 'lockedStatus', () => []) as boolean[]
      if (AppStorage.has('paidPageData')) {
        this.pageData = AppStorage.get('paidPageData') as readerCore.PageDataInfo
      }
      // mock付费章节
      if (this.lockedStatus.length === 0) {
        this.lockedStatus.push(false)
        this.lockedStatus.push(false)
        this.lockedStatus.push(false)
        for (let i = 3; i < this.catalogItemList.length; i++) {
          this.lockedStatus.push(true)
        }
      }
      if (this.userInfo?.isMembership) {
        this.lockedStatus = Array(this.catalogItemList.length).fill(false)
      }
    } else {
      if (AppStorage.has('freePageData')) {
        this.pageData = AppStorage.get('freePageData') as readerCore.PageDataInfo
      }
      for (let i = 0; i < this.catalogItemList.length; i++) {
        this.lockedStatus.push(false)
      }
    }
    let pageShow = (data: readerCore.PageDataInfo): void => {
      hilog.info(0x0000, 'testTag', 'pageshow: data is: ' + JSON.stringify(data));
      if (data.state === readerCore.PageState.PAGE_ON_SHOW) {
        this.isLoading = false;
        let spineItem = this.spineList[data.resourceIndex]
        let catalogItem = this.catalogItemList.filter(item => item.resourceFile === spineItem.href)
        this.curChapterId = catalogItem[0].catalogId
        if (this.lockedStatus[this.curChapterId]) {
          if (this.userInfo!.continuousBuy && this.userInfo!.bookCoins > this.price) {
            // 自动购买
            this.userInfo!.bookCoins -= this.price
            this.lockedStatus[this.curChapterId] = false
          } else {
            if (!this.isShowBuySheet) {
              this.isShowBuySheet = true
              baseActionSheet.show({
                id: 'buyChapter',
                title: { title: '购买' },
                height: SheetSize.FIT_CONTENT,
                preferType: SheetType.CENTER,
                customContent: () => {
                  this.buildBuyChapter(this.curChapterId)
                },
                onWillDismiss: (dismissSheetAction: DismissSheetAction) => {
                  this.isShowBuySheet = false
                  if (this.lockedStatus[this.curChapterId]) {
                    this.getReaderComponentController().startPlay(this.pageData!.resourceIndex, this.pageData!.startDomPos)
                    dismissSheetAction.dismiss();
                  }
                }
              })
            }
          }
        } else {
          this.pageData = data
        }
      }
    };
    if (ReaderPageTestBridge.enabled) {
      if (ReaderPageTestBridge.pageData) {
        pageShow(ReaderPageTestBridge.pageData);
      }
      if (ReaderPageTestBridge.onComplete) {
        ReaderPageTestBridge.onComplete(this.lockedStatus.length, this.curChapterId, this.isLoading);
      }
    } else {
      this.getReaderComponentController().on('resourceRequest', this.resourceRequest);
      this.getReaderComponentController().on('pageShow', pageShow);
    }
  }

  async startPlay() {
    try {
      let spineIndex: number = 0
      let domPos: string = '';
      if (this.pageData) {
        spineIndex = this.pageData.resourceIndex
        domPos = this.pageData.startDomPos
      }
      if (this.bookParserHandler) {
        this.getReaderComponentController().registerBookParser(this.bookParserHandler);
        this.getReaderComponentController().setPageConfig(this.readerSetting)
        this.getReaderComponentController().startPlay(spineIndex, domPos);
      }
    } catch (err) {
      hilog.error(0x0000, 'testTag', `failed to startPlay, Code is ${err.code}, message is ${err.message}`);
    }

  }

  onWillHide(): void {
    if (this.book?.isFree! === '2') {
      AppStorage.setOrCreate('paidPageData', this.pageData)
    } else {
      AppStorage.setOrCreate('freePageData', this.pageData)
    }
    this.readSet.readerSetting = this.readerSetting
    this.endTime = systemDateTime.getTime(false)
    this.userInfo!.totalReading += Math.ceil((this.endTime - this.startTime) / 60000)
    AppStorage.set('userInfo', this.userInfo)
    this.getReaderComponentController().off('resourceRequest');
    this.getReaderComponentController().off('pageShow');
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
    // 退出需要释放阅读器实例
    this.getReaderComponentController().releaseBook();
    this.notFullScreen()
  }

  setFullScreen() {
    this.windowClass.setWindowSystemBarEnable([]);
  }

  notFullScreen() {
    this.windowClass.setWindowSystemBarEnable(['status', 'navigation']);
  }

  build() {
    NavDestination() {
      if (ReaderPageTestBridge.enabled) {
        Column() {
          Text('ReaderPage preprocess host')
        }
        .id('reader_page_preprocess_host')
        .width('100%')
        .height('100%')
      } else {
      Swiper() {

        BookCoverCard({ book: this.book })

        Stack() {
          ReadPageComponent({
            controller: this.getReaderComponentController(),
            readerCallback: (err: BusinessError, data: readerCore.ReaderComponentController) => {
              this.readerComponentController = data;
            }
          })
            .onClick(() => {
              this.showController = !this.showController
              if (this.showController) {
                this.notFullScreen()
              } else {
                this.setFullScreen()
              }
              this.getReaderComponentController().setPageConfig(this.readerSetting)
            })
          if (this.showController) {
            Column() {
              ReaderTopCard({ book: this.book })

              Column() {
              }
              .layoutWeight(1)
              .width('100%')
              .hitTestBehavior(HitTestMode.None)

              ReaderToolBar({
                spineList: this.spineList,
                catalogItemList: this.catalogItemList,
                readerSetting: this.readerSetting,
                lockedStatus: this.lockedStatus,
                curChapterId: this.curChapterId,
                bookParserHandler: this.bookParserHandler,
                readerComponentController: this.getReaderComponentController(),
              })
            }
            // 透传点击事件
            .hitTestBehavior(HitTestMode.None)
          } else {
            Row() {
              TextClock({ timeZoneOffset: -8, controller: this.textClockController })
                .format('hh:mm')

              Text(`${((this.pageData?.resourceIndex! + 1) / this.spineList.length * 100).toFixed(2)}%`)

            }
            .position({ bottom: this.bottomRectHeight })
            .padding({ left: 16, right: 16 })
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }


          Row() {
            Text('加载中...')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
          .visibility(this.isLoading ? Visibility.Visible : Visibility.None)
        }
        .width('100%')
        .height('100%')
      }
      .onChange((index) => {
        if (index === 1) {
          this.setFullScreen()
        }
      })
      .indicator(false)
      .loop(false)
      }
    }
    .hideTitleBar(true)
    .onWillAppear(async () => {
      const p = TCRouter.getParams<BookInfo>(Constants.READ_KIT_ROUTER);
      if (p) {
        this.book = p
      }
    })
    .onWillShow(async () => {
      if (ReaderPageTestBridge.enabled) {
        this.userInfo = ReaderPageTestBridge.userInfo
        await this.preprocess()
        return
      }
      await this.loadBook()
      await this.preprocess()
      await this.startPlay()
    })
    .onWillHide(() => {
      this.onWillHide()
    })
  }
}
