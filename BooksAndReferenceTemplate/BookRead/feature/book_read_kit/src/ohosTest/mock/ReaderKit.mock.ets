import { BusinessError } from '@kit.BasicServicesKit';

export namespace bookParser {
  export interface CatalogItem {
    catalogId: number;
    catalogName: string;
    catalogLevel?: number;
    playOrder?: number;
    idRef?: string;
    href?: string;
    resourceFile?: string;
  }

  export interface SpineItem {
    idRef: string;
    index: number;
    href: string;
    properties: string;
  }

  export type CallbackRes<T, R> = (value: T) => R;

  export class BookParserHandler {
    getCatalogList(): CatalogItem[] {
      return [];
    }

    getSpineList(): SpineItem[] {
      return [];
    }

    getDomPosByCatalogHref(_href: string): string {
      return '';
    }
  }

  export async function getDefaultHandler(_path?: string): Promise<BookParserHandler> {
    return new BookParserHandler();
  }
}

export namespace readerCore {
  export interface ReaderSetting {
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

  export enum PageState {
    PAGE_WAITING = 1,
    PAGE_LOADING = 2,
    PAGE_ON_SHOW = 3
  }

  export class PageDataInfo {
    nodeType: string;
    dataId: string;
    pageHeaderContent: string = '';
    pageFooterContent: string = '';
    startDomPos: string = '';
    endDomPos: string = '';
    state: PageState = PageState.PAGE_WAITING;
    resourceIndex: number = 0;
    pageOffset: number = 0;

    constructor(nodeType: string, dataId: string) {
      this.nodeType = nodeType;
      this.dataId = dataId;
    }
  }

  export class ReaderComponentController {
    async init(_context: object): Promise<void> {
    }

    on(_type: string, _callback: object): void {
    }

    off(_type: string): void {
    }

    registerBookParser(_handler: bookParser.BookParserHandler): void {
    }

    setPageConfig(_setting: ReaderSetting): void {
    }

    startPlay(_resourceIndex: number, _domPos: string): void {
    }

    releaseBook(): void {
    }
  }
}

@ComponentV2
export struct ReadPageComponent {
  @Param controller: readerCore.ReaderComponentController = new readerCore.ReaderComponentController();
  @Param readerCallback:
    (error: BusinessError, controller: readerCore.ReaderComponentController) => void =
    (_error: BusinessError, _controller: readerCore.ReaderComponentController): void => {
    };

  build() {
    Column() {
    }
  }
}
