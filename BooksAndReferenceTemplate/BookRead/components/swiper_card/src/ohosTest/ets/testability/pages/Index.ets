import { BookInfo } from '../../../../../../../../src/main/ets/model/Book';
import { LazyDataVM } from '../../../../../../../../src/main/ets/model/LazyDataVM';
import { TUISwiper } from '../../../../../../../../src/main/ets/components/TUISwiper';

const HOST_ANCHOR_ID: string = 'tui_swiper_test_host_anchor';
const MODE_LABEL_ID: string = 'tui_swiper_mode';
const MOUNT_FLAT_ID: string = 'tui_swiper_mount_flat';
const MOUNT_COVERED_ID: string = 'tui_swiper_mount_covered';
const MOUNT_OVERSIZE_ID: string = 'tui_swiper_mount_oversize';
const MOUNT_FLAT_UNDERSIZE_ID: string = 'tui_swiper_mount_flat_undersize';
const MOUNT_COVERED_OVERSIZE_ID: string = 'tui_swiper_mount_covered_oversize';
const MOUNT_COVERED_UNDERSIZE_ID: string = 'tui_swiper_mount_covered_undersize';
const MOUNT_INVALID_ID: string = 'tui_swiper_mount_invalid';
const UNMOUNT_ID: string = 'tui_swiper_unmount';
const AREA_ID: string = 'tui_swiper_area';
const AREA_HEIGHT_ID: string = 'tui_swiper_area_height';

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
      .fontColor(Color.Black);
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .backgroundColor(Color.Gray);
}

const BOOK_ITEM_BUILDER: WrappedBuilder<[BookInfo]> = wrapBuilder(renderBookItem);

@Entry
@ComponentV2
struct Index {
  @Local mode: string = 'none';
  @Local areaHeight: number = 0;
  private books: LazyDataVM<BookInfo> = new LazyDataVM<BookInfo>(buildFixtureBooks());
  private builders: WrappedBuilder<[BookInfo]>[] =
    [BOOK_ITEM_BUILDER, BOOK_ITEM_BUILDER, BOOK_ITEM_BUILDER, BOOK_ITEM_BUILDER];

  build() {
    Column({ space: 4 }) {
      Text('TUISwiper UITest Host')
        .id(HOST_ANCHOR_ID)
        .fontSize(14);

      Text(`mode:${this.mode}`)
        .id(MODE_LABEL_ID)
        .fontSize(12);

      Text(`h:${Math.round(this.areaHeight)}`)
        .id(AREA_HEIGHT_ID)
        .fontSize(12);

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
        Button('flat').id(MOUNT_FLAT_ID).fontSize(12)
          .onClick(() => {
            this.areaHeight = 0;
            this.mode = 'flat';
          });
        Button('covered').id(MOUNT_COVERED_ID).fontSize(12)
          .onClick(() => {
            this.areaHeight = 0;
            this.mode = 'covered';
          });
        Button('over').id(MOUNT_OVERSIZE_ID).fontSize(12)
          .onClick(() => {
            this.areaHeight = 0;
            this.mode = 'oversize';
          });
        Button('none').id(UNMOUNT_ID).fontSize(12)
          .onClick(() => {
            this.areaHeight = 0;
            this.mode = 'none';
          });
        Button('flat-small').id(MOUNT_FLAT_UNDERSIZE_ID).fontSize(12)
          .onClick(() => {
            this.areaHeight = 0;
            this.mode = 'flat-small';
          });
        Button('cover-big').id(MOUNT_COVERED_OVERSIZE_ID).fontSize(12)
          .onClick(() => {
            this.areaHeight = 0;
            this.mode = 'cover-big';
          });
        Button('cover-small').id(MOUNT_COVERED_UNDERSIZE_ID).fontSize(12)
          .onClick(() => {
            this.areaHeight = 0;
            this.mode = 'cover-small';
          });
        Button('invalid').id(MOUNT_INVALID_ID).fontSize(12)
          .onClick(() => {
            this.areaHeight = 0;
            this.mode = 'invalid';
          });
      }

      Column() {
        if (this.mode === 'flat') {
          TUISwiper({
            isCovered: false,
            imgWidth: 200,
            imgHeight: 100,
            isLoop: false,
            interval: 600000,
            builderList: this.builders,
            bookList: this.books
          });
        } else if (this.mode === 'covered') {
          TUISwiper({
            isCovered: true,
            imgWidth: 200,
            imgHeight: 100,
            isLoop: false,
            interval: 600000,
            builderList: this.builders,
            bookList: this.books
          });
        } else if (this.mode === 'oversize') {
          TUISwiper({
            isCovered: false,
            imgWidth: 10000,
            imgHeight: 10000,
            isLoop: false,
            interval: 600000,
            builderList: this.builders,
            bookList: this.books
          });
        } else if (this.mode === 'flat-small') {
          TUISwiper({
            isCovered: false,
            imgWidth: 50,
            imgHeight: 50,
            isLoop: false,
            interval: 600000,
            builderList: this.builders,
            bookList: this.books
          });
        } else if (this.mode === 'cover-big') {
          TUISwiper({
            isCovered: true,
            imgWidth: 10000,
            imgHeight: 10000,
            isLoop: false,
            interval: 600000,
            builderList: this.builders,
            bookList: this.books
          });
        } else if (this.mode === 'cover-small') {
          TUISwiper({
            isCovered: true,
            imgWidth: 50,
            imgHeight: 50,
            isLoop: false,
            interval: 600000,
            builderList: this.builders,
            bookList: this.books
          });
        } else if (this.mode === 'invalid') {
          TUISwiper({
            isCovered: false,
            imgWidth: 0,
            imgHeight: 0,
            isLoop: false,
            interval: 600000,
            builderList: this.builders,
            bookList: this.books
          });
        }
      }
      .id(AREA_ID)
      .width('100%')
      .onAreaChange((_o: Area, newV: Area) => {
        this.areaHeight = newV.height as number;
      });
    }
    .width('100%')
    .height('100%')
    .padding(8)
    .backgroundColor(Color.White);
  }
}
