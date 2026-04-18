import { CropModel, CropView } from '../../../../../../../../src/main/ets/pages/mine/AvatarUpload';

const HOST_ANCHOR_ID = 'crop_test_host_anchor';
const CROP_AREA_ID = 'crop_test_crop_area';
const SCALE_ID = 'crop_model_scale';
const OFFSET_X_ID = 'crop_model_offsetX';
const OFFSET_Y_ID = 'crop_model_offsetY';

interface CropScenario {
  imageWidth: number;
  imageHeight: number;
  componentWidth: number;
  componentHeight: number;
  frameWidth: number;
  frameRatio: number;
  scale: number;
  offsetX: number;
  offsetY: number;
}

@Entry
@ComponentV2
struct Index {
  @Local model: CropModel = new CropModel();

  private apply(s: CropScenario): void {
    this.model.panEnabled = false;
    this.model.zoomEnabled = false;
    this.model.imageWidth = s.imageWidth;
    this.model.imageHeight = s.imageHeight;
    this.model.componentWidth = s.componentWidth;
    this.model.componentHeight = s.componentHeight;
    this.model.frameWidth = s.frameWidth;
    this.model.frameRatio = s.frameRatio;
    this.model.scale = s.scale;
    this.model.offsetX = s.offsetX;
    this.model.offsetY = s.offsetY;
  }

  build() {
    Column() {
      Column({ space: 4 }) {
        Text('crop_test_host').id(HOST_ANCHOR_ID).fontSize(10)
        Row({ space: 8 }) {
          Text(`${this.model.scale}`).id(SCALE_ID).fontSize(10)
          Text(`${this.model.offsetX}`).id(OFFSET_X_ID).fontSize(10)
          Text(`${this.model.offsetY}`).id(OFFSET_Y_ID).fontSize(10)
        }
        Row({ space: 4 }) {
          Button('S1').id('btn_s1').fontSize(10).height(28).width(56)
            .onClick(() => this.apply({
              imageWidth: 1000, imageHeight: 1000,
              componentWidth: 1000, componentHeight: 1000,
              frameWidth: 1000, frameRatio: 1,
              scale: 1, offsetX: 0, offsetY: 0
            }))
          Button('S2').id('btn_s2').fontSize(10).height(28).width(56)
            .onClick(() => this.apply({
              imageWidth: 2000, imageHeight: 2000,
              componentWidth: 1000, componentHeight: 1000,
              frameWidth: 500, frameRatio: 1,
              scale: 1, offsetX: 500, offsetY: 0
            }))
          Button('S3').id('btn_s3').fontSize(10).height(28).width(56)
            .onClick(() => this.apply({
              imageWidth: 2000, imageHeight: 2000,
              componentWidth: 1000, componentHeight: 1000,
              frameWidth: 500, frameRatio: 1,
              scale: 1, offsetX: -500, offsetY: 0
            }))
          Button('S4').id('btn_s4').fontSize(10).height(28).width(56)
            .onClick(() => this.apply({
              imageWidth: 2000, imageHeight: 2000,
              componentWidth: 1000, componentHeight: 1000,
              frameWidth: 500, frameRatio: 1,
              scale: 1, offsetX: 0, offsetY: 500
            }))
        }
        Row({ space: 4 }) {
          Button('S5').id('btn_s5').fontSize(10).height(28).width(56)
            .onClick(() => this.apply({
              imageWidth: 2000, imageHeight: 2000,
              componentWidth: 1000, componentHeight: 1000,
              frameWidth: 500, frameRatio: 1,
              scale: 1, offsetX: 0, offsetY: -500
            }))
          Button('S6').id('btn_s6').fontSize(10).height(28).width(56)
            .onClick(() => this.apply({
              imageWidth: 1000, imageHeight: 1000,
              componentWidth: 1000, componentHeight: 1000,
              frameWidth: 500, frameRatio: 1,
              scale: 0.25, offsetX: 0, offsetY: 0
            }))
          Button('S7').id('btn_s7').fontSize(10).height(28).width(56)
            .onClick(() => this.apply({
              imageWidth: 1000, imageHeight: 1000,
              componentWidth: 1000, componentHeight: 1000,
              frameWidth: 1000, frameRatio: 2,
              scale: 1, offsetX: 0, offsetY: 0
            }))
          Button('S8').id('btn_s8').fontSize(10).height(28).width(56)
            .onClick(() => this.apply({
              imageWidth: 2000, imageHeight: 1000,
              componentWidth: 1000, componentHeight: 1000,
              frameWidth: 500, frameRatio: 1,
              scale: 1, offsetX: 0, offsetY: 100
            }))
        }
      }
      .padding(4)
      .backgroundColor('#EEEEEE')
      .width('100%')

      Stack() {
        CropView({ model: this.model })
      }
      .layoutWeight(1)
      .width('100%')
      .id(CROP_AREA_ID)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
