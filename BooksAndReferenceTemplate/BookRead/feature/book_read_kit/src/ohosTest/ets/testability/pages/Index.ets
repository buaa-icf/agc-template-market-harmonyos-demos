import { BookInfo } from 'common';
import { BookCoverCard } from '../../../../../../../../src/main/ets/components/BookCoverCard';

const HOST_PAGE_ID = 'book_cover_card_host_page';

@Entry
@ComponentV2
struct Index {
  private book: BookInfo = {
    id: 'book-cover-card-test-book',
    name: '三体',
    author: '刘慈欣',
    coverUrl: $r('app.media.book_image_1'),
    rate: '9.6',
    description: '用于 BookCoverCard build 测试的宿主数据',
    localPath: '',
    epubUrl: '',
    category: '科幻',
    count: '52.1',
    popular: '88.8'
  };

  aboutToAppear(): void {
    AppStorage.setOrCreate('windowTopHeight', 0);
    AppStorage.setOrCreate('favBooks', [] as BookInfo[]);
  }

  build() {
    Column() {
      BookCoverCard({ book: this.book })
    }
    .id(HOST_PAGE_ID)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'));
  }
}
