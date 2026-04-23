import { MyPosition } from 'common';
import { CarouseCutToolBar } from '../../../../../../../../src/main/ets/components/CarouseCutToolBar';

const HOST_ANCHOR_ID: string = 'carouse_cut_tool_bar_test_host_anchor';
const RATIO_OUTPUT_ID: string = 'cut_ratio_output';
const CUT_INDEX_OUTPUT_ID: string = 'cut_select_index_output';
const CLIP_RECT_OUTPUT_ID: string = 'cut_clip_rect_output';

@Entry
@Component
struct Index {
  @State cropRatioHolder: number = -999;
  @State clipRectHolder: MyPosition = { x: 0, y: 0, width: 1080, height: 1920 };
  @State clipRectMaxHHolder: number = 0;
  @State clipRectMaxWHolder: number = 0;
  @State carouselCutTabIndexHolder: number = 0;
  @State barIndexHolder: number = 0;
  @State imageAreaHolder: MyPosition = { x: 0, y: 0, width: 1080, height: 1920 };

  build() {
    Column({ space: 4 }) {
      Text('CarouseCutToolBar UITest Host')
        .id(HOST_ANCHOR_ID)
        .fontSize(14);

      Text(`ratio:${this.cropRatioHolder}`)
        .id(RATIO_OUTPUT_ID)
        .fontSize(14);

      Text(`clip:${this.clipRectHolder.x},${this.clipRectHolder.y},${this.clipRectHolder.width},${this.clipRectHolder.height}`)
        .id(CLIP_RECT_OUTPUT_ID)
        .fontSize(12);

      CarouseCutToolBar({
        carouselCutTabIndex: $carouselCutTabIndexHolder,
        barIndex: $barIndexHolder,
        cropRatio: $cropRatioHolder,
        clipRect: $clipRectHolder,
        clipRectMaxH: $clipRectMaxHHolder,
        clipRectMaxW: $clipRectMaxWHolder,
        imageArea: this.imageAreaHolder,
      });
    }
    .width('100%')
    .height('100%')
    .padding(8)
    .backgroundColor(Color.White);
  }
}
