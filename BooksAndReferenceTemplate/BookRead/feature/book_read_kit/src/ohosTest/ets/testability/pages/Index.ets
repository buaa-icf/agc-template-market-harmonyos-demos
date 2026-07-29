import { BookInfo, TCRouter } from 'common';
import { BookCoverCard } from '../../../../../../../../src/main/ets/components/BookCoverCard';

const BOOK_COVER_HOST_ID = 'book_cover_card_host_page';
const HOST_ROUTE = 'book_read_kit_test_host';

@Entry
@ComponentV2
struct Index {
  private coverBook: BookInfo = {
    id: 'book-cover-card-test-book',
    name: '\u4e09\u4f53',
    author: '\u5218\u6148\u6b23',
    coverUrl: $r('app.media.book_image_1'),
    rate: '9.6',
    description: 'BookCoverCard instrument test data',
    localPath: '',
    epubUrl: '',
    category: '\u79d1\u5e7b',
    count: '52.1',
    popular: '88.8'
  };

  aboutToAppear(): void {
    AppStorage.setOrCreate('windowTopHeight', 0);
    AppStorage.setOrCreate('bottomRectHeight', 0);
    AppStorage.setOrCreate('favBooks', [] as BookInfo[]);
    TCRouter.init();
    TCRouter.replace(HOST_ROUTE);
  }

  @Builder
  hostPage() {
    NavDestination() {
      Column() {
        BookCoverCard({ book: this.coverBook })
      }
      .id(BOOK_COVER_HOST_ID)
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'));
    }
    .hideTitleBar(true)
  }

  @Builder
  routerMap(name: string) {
    if (name === HOST_ROUTE) {
      this.hostPage();
    }
  }

  build() {
    Navigation(TCRouter.getStack()) {
    }
    .hideNavBar(true)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .width('100%')
    .height('100%')
    .navDestination(this.routerMap);
  }
}
