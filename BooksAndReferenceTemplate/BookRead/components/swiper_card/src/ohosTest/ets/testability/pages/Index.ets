import { BookInfo } from '../../../../../../../../src/main/ets/model/Book';
import { LazyDataVM } from '../../../../../../../../src/main/ets/model/LazyDataVM';
import { TUISwiper } from '../../../../../../../../src/main/ets/components/TUISwiper';

const HOST_ANCHOR_ID: string = 'tui_swiper_test_host_anchor';
const FLAT_WRAPPER_ID: string = 'tui_swiper_wrapper_flat';
const COVERED_WRAPPER_ID: string = 'tui_swiper_wrapper_covered';
const OVERSIZE_WRAPPER_ID: string = 'tui_swiper_wrapper_oversize';

const FIXTURE_IMG_WIDTH: number = 200;
const FIXTURE_IMG_HEIGHT: number = 100;

function buildFixtureBooks(): BookInfo[] {
  const items: BookInfo[] = [];
  for (let i = 0; i < 4; i++) {
    items.push({
      id: `id_${i}`,
      name: `Book ${i}`,
      rate: '5.0',
      description: 'desc',
      author: 'author',
      localPath: '',
      epubUrl: '',
      category: 'cat'
    });
  }
  return items;
}

@Builder
function renderBookItem(book: BookInfo) {
  Column() {
    Text(book?.name ?? '-')
      .fontSize(14)
      .fontColor(Color.Black)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .backgroundColor(Color.Gray)
}

const BOOK_ITEM_BUILDER: WrappedBuilder<[BookInfo]> = wrapBuilder(renderBookItem);

@Entry
@ComponentV2
struct Index {
  @Local books: LazyDataVM<BookInfo> = new LazyDataVM<BookInfo>(buildFixtureBooks());
  @Local builders: WrappedBuilder<[BookInfo]>[] = [BOOK_ITEM_BUILDER, BOOK_ITEM_BUILDER, BOOK_ITEM_BUILDER, BOOK_ITEM_BUILDER];

  build() {
    Column({ space: 4 }) {
      Text('TUISwiper UITest Host')
        .id(HOST_ANCHOR_ID)
        .fontSize(14)
        .fontWeight(FontWeight.Medium);

      Column() {
        TUISwiper({
          isCovered: false,
          imgWidth: FIXTURE_IMG_WIDTH,
          imgHeight: FIXTURE_IMG_HEIGHT,
          isLoop: false,
          interval: 60000,
          builderList: this.builders,
          bookList: this.books
        });
      }
      .id(FLAT_WRAPPER_ID)
      .width('100%');

      Column() {
        TUISwiper({
          isCovered: true,
          imgWidth: FIXTURE_IMG_WIDTH,
          imgHeight: FIXTURE_IMG_HEIGHT,
          isLoop: false,
          interval: 60000,
          builderList: this.builders,
          bookList: this.books
        });
      }
      .id(COVERED_WRAPPER_ID)
      .width('100%');

      Column() {
        TUISwiper({
          isCovered: false,
          imgWidth: 10000,
          imgHeight: 10000,
          isLoop: false,
          interval: 60000,
          builderList: this.builders,
          bookList: this.books
        });
      }
      .id(OVERSIZE_WRAPPER_ID)
      .width('100%');
    }
    .width('100%')
    .height('100%')
    .padding(8)
    .backgroundColor(Color.White);
  }
}
