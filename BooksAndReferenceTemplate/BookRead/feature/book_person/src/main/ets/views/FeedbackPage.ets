import { Constants, FeedbackItem, FeedbackItemType, ReturnButton,FeedbackRecord, TCInvoke, TCRouter,
  NavHeaderBar } from 'common';
import { image } from '@kit.ImageKit';
import { fileSelect } from '../comp/FileSelect';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct FeedbackPage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local pixelMap: Array<image.PixelMap> = []
  private maxPhotoNum: number = 4
  private maxIssueCharNum: number = 100
  private maxPhoneCharNum: number = 11
  text: ResourceStr | undefined;
  @Local issueCharNum: number = 0
  @Local phoneCharNum: number = 0
  // @Local item:FeedbackItemType= {description:'',stageImageUris:[],phone:''}
  @Local feedbackItem: FeedbackItem = new FeedbackItem('', [], '')
  @Local feedbackRecord:FeedbackRecord =
    AppStorageV2.connect(FeedbackRecord, 'feedbackRecord', () => new FeedbackRecord())!
  @Local stageImageUris: Array<string> = [];
  private imageUris: Array<string> = [];


  build() {
    NavDestination(){
      Stack({ alignContent: Alignment.TopStart }) {
        Column() {
          NavHeaderBar({
            title: '意见反馈',
            hasBackButton: true,
            hasBgColor: true,
            isMainPage: false,
          })
          Column({space:12}){
            Scroll() {
              Column({ space: 12 }) {
                Row(){
                  Text('问题描述')
                    .fontSize(14)
                    .fontWeight(FontWeight.Regular)
                    .textAlign(TextAlign.Start)
                  Text(`${this.issueCharNum}/${this.maxIssueCharNum}`)
                    .id('feedback_page_issue_count')
                    .fontSize(14)
                    .fontWeight(FontWeight.Regular)
                    .fontColor('#99000000')
                    .textAlign(TextAlign.End)
                }
                .width(Constants.FULL_SIZE)
                .height(20)
                .justifyContent(FlexAlign.SpaceBetween)
                TextArea({ placeholder: '请输入问题描述'})
                  .id('feedback_page_issue_input')
                  .placeholderFont({ size: $r('sys.float.Body_S'), weight:'regular'})
                  .width('100%')
                  .height(122)
                  .backgroundColor($r('sys.color.background_primary'))
                  .maxLength(100)
                  .onChange((value: string) => {
                    this.feedbackItem.description = value
                    this.issueCharNum = value.length
                  })

                Row(){
                  Text('问题截图（选填）')
                    .fontSize(14)
                    .fontWeight(FontWeight.Regular)
                    .textAlign(TextAlign.Start)
                  Text(`${this.feedbackItem.stageImageUris.length}/${this.maxPhotoNum}`)
                    .id('feedback_page_screenshot_count')
                    .fontSize(14)
                    .fontWeight(FontWeight.Regular)
                    .fontColor('#99000000')
                    .textAlign(TextAlign.End)
                }
                .width(Constants.FULL_SIZE)
                .height(20)
                .justifyContent(FlexAlign.SpaceBetween)
                Row(){
                  Scroll() {
                    Flex({ wrap: FlexWrap.Wrap }) {
                      ForEach(this.stageImageUris, (item: string, index: number) => {
                        Stack({ alignContent: Alignment.TopEnd }) {
                          Image(item ? item : $r('app.media.ic_search'))
                            .width(80)
                            .height(80)
                            .objectFit(ImageFit.Cover)
                            .borderRadius(5)
                            .margin(5)
                          Image($r('app.media.ic_public_close'))
                            .width(20)
                            .height(20)
                            .margin({ right: 5, top: 5 })
                            .onClick(() => {
                              this.stageImageUris.splice(index, 1)
                              this.imageUris.splice(index, 1)
                            })
                        }
                      }, (item: string) => `item+${new Date().toString()}`)
                      if (this.stageImageUris.length < 4) {
                        Row(){
                          Image($r('app.media.ic_public_plus')).size({height:22,width:22})
                        }
                        .height(80).width(80).backgroundColor($r('sys.color.background_secondary'))
                        .margin({left:12})
                        .justifyContent(FlexAlign.Center)
                        .onClick(() => {
                          this.selectImage()
                        })
                      }
                    }
                  }
                }
                .width('100%')
                .height(104)
                .backgroundColor($r('sys.color.background_primary')).borderRadius(16)
                .justifyContent(FlexAlign.Center)

                Row(){
                  Text('联系方式（选填）')
                    .fontSize(14)
                    .fontWeight(FontWeight.Regular)
                    .textAlign(TextAlign.Start)
                  Text(`${this.phoneCharNum}/${this.maxPhoneCharNum}`)
                    .id('feedback_page_phone_count')
                    .fontSize(14)
                    .fontWeight(FontWeight.Regular)
                    .fontColor('#99000000')
                    .textAlign(TextAlign.End)
                }
                .width(Constants.FULL_SIZE)
                .height(20)
                .justifyContent(FlexAlign.SpaceBetween)

                TextInput({ placeholder: '请填写联系手机',text: this.text })
                  .id('feedback_page_phone_input')
                  .backgroundColor($r('sys.color.comp_background_primary'))
                  .type(InputType.Number)
                  .maxLength(this.maxPhoneCharNum)
                  .borderRadius(12)
                  .placeholderFont({size:$r('sys.float.Body_S'),weight:FontWeight.Regular})
                  .onChange((value: string) => {
                    this.feedbackItem.phone = value
                    this.phoneCharNum = value.length
                  })
              }
              .width(Constants.FULL_SIZE)
              .alignItems(HorizontalAlign.Start)
            }
            .id('feedback_page_form_scroll')
            .layoutWeight(1)
            .scrollBar(BarState.Off)

            Button('提交')
              .id('feedback_page_submit')
              .borderRadius(20)
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor('#E84026')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .width(304)
              .height(40)
              .padding({ top: 12, bottom: 12 })
              .onClick(async ()=>{
                this.feedbackRecord.feedbackList = [...this.feedbackRecord.feedbackList, this.feedbackItem]
                TCRouter.pop()
              })
          }
          .id('feedback_page_root')
          .layoutWeight(1)
          .width(Constants.FULL_SIZE)
          .backgroundColor($r('sys.color.background_secondary'))
          .padding({
            left:16,
            right:16,
            top:16
          })
        }
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))

  }

  @Builder
  titleView(title: string, maxCharNum: number, currentCharNum: number){
    Row(){
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Start)
      Text(`${currentCharNum}/${maxCharNum}`)
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .fontColor('#99000000')
        .textAlign(TextAlign.End)
    }
    .width(Constants.FULL_SIZE)
    .height(20)
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(async ()=>{
      console.log(`${currentCharNum}${title}${this.issueCharNum}`)
    })
  }

  async selectImage() {
    const uris = await fileSelect(this.imageUris)
    this.stageImageUris = uris
    this.imageUris = uris
    this.feedbackItem.stageImageUris = this.stageImageUris
  }
}
