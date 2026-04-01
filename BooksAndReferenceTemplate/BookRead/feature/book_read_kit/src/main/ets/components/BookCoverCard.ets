import { BookApi, BookInfo, Constants, NavHeaderBar } from 'common';
import { promptAction } from '@kit.ArkUI';


@ComponentV2
export struct BookCoverCard {
  @Param @Require book: BookInfo;
  @Local isAddSuccess: boolean = false;

  async aboutToAppear(): Promise<void> {
    const rsp = await BookApi.getBooksShelfList('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
    let books: BookInfo[] = rsp.books;
    books.forEach((book) => {
      if (book.id === this.book.id) {
        this.isAddSuccess = true;
        return;
      }
    });
  }

  async addBook2Shelf(isAdd: boolean, toast: ResourceStr) {
    const rsp = await BookApi.getBooksShelfList('favBooks', Constants.API_GET_BOOK_FAVOURITE_PATH, '');
    let books: BookInfo[] = rsp.books;
    if (isAdd) {
      books.push(this.book);
      AppStorage.set('favBooks', books);
      this.isAddSuccess = true;
    } else {
      let index = books.findIndex(book => this.book.id === book.id)
      if (index !== -1) {
        books.splice(index, 1);
        this.isAddSuccess = false;
      }
      AppStorage.set('historyBooks', books)
    }
    promptAction.showToast({
      message: toast,
      duration: 2000
    });
  }

  build() {
    Column() {
      NavHeaderBar({
        title: $r('app.string.read'),
        hasBackButton: false,
        hasBgColor: false,
        isMainPage: true,
      })

      Stack() {
        Image($r(this.book.coverUrl?.toString()))
          .objectFit(ImageFit.Auto)
          .borderRadius(10)
      }.width(168)
      .height(232)

      .margin({ top: 10 })


      Column() {
        // 黑色加粗
        Row() {
          Text(this.book.name)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .height(50)

          Image(this.isAddSuccess ? $r('app.media.ic_add_book_shelf_success') : $r('app.media.ic_add_book_shelf'))
            .id('book_cover_card_shelf_action')
            .width(32)
            .height(32)
            .onClick(async () => {
              if (!this.isAddSuccess) {
                await this.addBook2Shelf(true, $r('app.string.add_shelf_success'));
              } else if (this.isAddSuccess) {
                //   再次点击从书架删除
                await this.addBook2Shelf(false, $r('app.string.del_shelf_success'));
              }
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)


        // 灰色
        Text(this.book.author)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .textAlign(TextAlign.Start)
          .width(Constants.FULL_SIZE)
          .height(20)

        Row({ space: 50 }) {
          Column({ space: 5 }) {
            Row() {
              Text(this.book.rate)
                .fontSize(15)
                .fontColor($r('sys.color.font_primary'))
              Text(' ')
              Text($r('app.string.rating_point'))
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
            }

            Text($r('app.string.popular'))
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }

          Column({ space: 5 }) {
            Row() {
              Text(this.book.count)
                .fontSize(15)
                .fontColor($r('sys.color.font_primary'))
              Text(' ')
              Text($r('app.string.ten_thousand_words'))
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
            }

            Text($r('app.string.publishing_house'))
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }

          Column({ space: 5 }) {
            Row() {
              Text(this.book.popular)
                .fontSize(15)
                .fontColor($r('sys.color.font_primary'))
              Text(' ')
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
              Text($r('app.string.ten_thousand'))
                .fontSize(12)
                .fontColor($r('sys.color.font_secondary'))
            }

            Text($r('app.string.popular'))
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }
        }
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.Center)
        .padding({ top: 25 })
      }
      .width(Constants.FULL_SIZE)
      .height(200)
      .padding({ top: 20, left: 30, right: 30 })
      .alignItems(HorizontalAlign.Start)

      Blank()
        .height(200)
      Text($r('app.string.start_reading'))
    }.width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
  }
}
