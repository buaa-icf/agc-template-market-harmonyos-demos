export class PointConfirmParam {
  type: number = 0;
  content: string = '';
  close: () => void = () => {
  };
  confirm: () => void = () => {
  };
}

@Builder
export function scanPointConfirmBuilder(param: PointConfirmParam) {
  Column() {
    Column() {
      Text('订单条形码').id('scan_point_confirm_title').fontSize(20).fontWeight(FontWeight.Medium).height(56)
      Text(param.content).id('scan_point_confirm_content').fontSize(14)

      Row({ space: 16 }) {
        Button('鍙栨秷').id('scan_point_confirm_cancel_button')
          .height(40)
          .layoutWeight(1)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_tertiary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            param.close();
          })
        Button('鎻愪氦').id('scan_point_confirm_submit_button')
          .height(40)
          .layoutWeight(1)
          .fontSize($r('sys.float.Body_L'))
          .backgroundColor($r('app.color.app_theme'))
          .onClick(() => {
            param.confirm();
          })
      }
      .id('scan_point_confirm_action_row')
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        top: 8,
        bottom: 16,
        left: 12,
        right: 12
      })
    }
    .padding({ left: 24, right: 24 })
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(32)
  }
  .width('100%')
  .padding({ left: 16, right: 16 })

}

@Builder
export function photoPointConfirmBuilder(param: PointConfirmParam) {
  Column() {
    Column({ space: 24 }) {
      Text('提交审核').id('photo_point_confirm_title').fontSize(20).fontWeight(500)
      Image(param.content).id('photo_point_confirm_image').width('100%').constraintSize({ maxHeight: '60%' }).borderRadius(16)

      Row({ space: 16 }) {
        Button('鍙栨秷').id('photo_point_confirm_cancel_button')
          .height(40)
          .layoutWeight(1)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_tertiary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            param.close();
          })
        Button('鎻愪氦').id('photo_point_confirm_submit_button')
          .height(40)
          .layoutWeight(1)
          .fontSize($r('sys.float.Body_L'))
          .backgroundColor($r('app.color.app_theme'))
          .onClick(() => {
            param.confirm();
          })
      }
      .id('photo_point_confirm_action_row')
      .width('100%')
    }
    .padding({
      left: 12,
      right: 12,
      top: 24,
      bottom: 16
    })
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(32)
  }
  .width('100%')
  .padding({ left: 16, right: 16 })

}
