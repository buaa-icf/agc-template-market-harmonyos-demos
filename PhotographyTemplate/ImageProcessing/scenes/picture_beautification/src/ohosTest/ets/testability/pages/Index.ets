import { StickerShowModel } from 'common';
import { StickerModel } from '../../../../main/ets/model/BeautificationParam';
import { StickerToolBar } from '../../../../main/ets/components/StickerToolBar';
import { Constants } from '../../../../main/ets/model/Constants';

@Entry
@Component
struct Index {
  @State barIndex: number = 4
  @State stickerList: StickerModel[] = []
  private testSearchList: StickerShowModel[] = Constants.stickerList.slice(0, 2)

  build() {
    Column() {
      StickerToolBar({
        barIndex: this.barIndex,
        stickerList: this.stickerList,
        testSearchList: this.testSearchList
      })
    }
    .width('100%')
    .height('100%')
    .id('sticker_toolbar_test_host')
  }
}
