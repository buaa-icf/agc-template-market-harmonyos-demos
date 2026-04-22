import { BeautyParam, MyPosition } from 'common';
import { image } from '@kit.ImageKit';
import { CarouseCutToolBar } from '../../../../../../../../src/main/ets/components/CarouseCutToolBar';
import { PictureBeautification } from '../../../../../../../../src/main/ets/pages/PictureBeautification';

const HOST_ANCHOR_ID: string = 'carouse_cut_tool_bar_test_host_anchor';
const RATIO_OUTPUT_ID: string = 'cut_ratio_output';
const CUT_INDEX_OUTPUT_ID: string = 'cut_select_index_output';
const CLIP_RECT_OUTPUT_ID: string = 'cut_clip_rect_output';

const PB_HOST_ANCHOR_ID: string = 'picture_beautification_test_host_anchor';
const PB_ROUTE_NAME: string = 'pictureBeautification';
const PB_TEST_PIXEL_MAP_KEY: string = 'pictureBeautification.testPixelMap';
const PB_RUN_FLAG: string = 'pictureBeautification.runTest';

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

  pathStack: NavPathStack = new NavPathStack();
  @State ready: boolean = false;
  @State pushed: boolean = false;
  @StorageLink(PB_RUN_FLAG) runPb: boolean = false;

  async aboutToAppear(): Promise<void> {
    AppStorage.setOrCreate('topRectHeight', 0);
    AppStorage.setOrCreate('bottomRectHeight', 0);
    try {
      const width = 1024;
      const height = 768;
      const buffer = new ArrayBuffer(width * height * 4);
      const view = new Uint8Array(buffer);
      for (let i = 0; i < view.length; i += 4) {
        view[i] = 128;
        view[i + 1] = 128;
        view[i + 2] = 128;
        view[i + 3] = 255;
      }
      const opts: image.InitializationOptions = {
        size: { width: width, height: height },
        pixelFormat: 3,
        editable: true,
        alphaType: 2
      };
      const pixelMap = await image.createPixelMap(buffer, opts);
      AppStorage.setOrCreate<PixelMap>(PB_TEST_PIXEL_MAP_KEY, pixelMap);
    } catch (e) {
      console.error('create test pixel map failed: ' + (e as Error).message);
    }
    this.ready = true;
  }

  @Builder
  pageMap(name: string) {
    if (name === PB_ROUTE_NAME) {
      PictureBeautification({ pathStack: this.pathStack })
    }
  }

  build() {
    if (this.runPb) {
      Stack({ alignContent: Alignment.TopStart }) {
        Navigation(this.pathStack) {
        }
        .navDestination(this.pageMap)
        .hideNavBar(true)
        .width('100%')
        .height('100%')

        Text('picture_beautification_test_host')
          .id(PB_HOST_ANCHOR_ID)
          .fontSize(1)
          .opacity(0.01)

        if (this.ready && !this.pushed) {
          Text('trigger')
            .fontSize(1)
            .opacity(0)
            .onAppear(() => {
              const param: BeautyParam = { uris: [''], barIndex: 1 };
              this.pathStack.pushPath({ name: PB_ROUTE_NAME, param: param });
              this.pushed = true;
            })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
    } else {
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
}
