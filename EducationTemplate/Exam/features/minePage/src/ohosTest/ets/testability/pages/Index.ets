import { AppStorageV2 } from '@kit.ArkUI';
import { AuthenticationPage } from '../../../../main/ets/views/AuthenticationPage';
import { CollectionPage } from '../../../../main/ets/views/CollectionPage';
import { CoursePage } from '../../../../main/ets/views/CoursePage';
import { OrderInfo, OrderState, SampleCollectInfo, SampleOrderInfo } from 'commonlib';

const HOST_ANCHOR_ID: string = 'mine_page_collection_instrument_host_anchor';
const ABOUT_TO_DISAPPEAR_MARKER_ID: string = 'collection_about_to_disappear_marker';
const ABOUT_TO_DISAPPEAR_TRIGGER_ID: string = 'collection_about_to_disappear_trigger';
const SWITCH_TO_EMPTY_TRIGGER_ID: string = 'collection_switch_to_empty_trigger';
const SWITCH_TO_FILLED_TRIGGER_ID: string = 'collection_switch_to_filled_trigger';
const SHOW_COLLECTION_PAGE_TRIGGER_ID: string = 'collection_show_page_trigger';
const RESET_COLLECTION_PAGE_TRIGGER_ID: string = 'collection_reset_to_filled_trigger';
const COLLECTION_HOST_READY_FILLED_MARKER_ID: string = 'collection_host_ready_filled_marker';
const COURSE_HOST_ANCHOR_ID: string = 'mine_page_course_instrument_host_anchor';
const SHOW_COURSE_PAGE_TRIGGER_ID: string = 'course_show_page_trigger';
const SHOW_AUTHENTICATION_PAGE_TRIGGER_ID: string = 'authentication_show_page_trigger';
const SWITCH_COURSE_TO_FILLED_TRIGGER_ID: string = 'course_switch_to_filled_trigger';
const SWITCH_COURSE_TO_EMPTY_TRIGGER_ID: string = 'course_switch_to_empty_trigger';
const RESET_COURSE_PAGE_TRIGGER_ID: string = 'course_reset_to_filled_trigger';
const COURSE_HOST_READY_FILLED_MARKER_ID: string = 'course_host_ready_filled_marker';
const AUTHENTICATION_HOST_READY_MARKER_ID: string = 'authentication_host_ready_marker';

@Entry
@ComponentV2
struct Index {
  @Local private showLifecycleTarget: boolean = true;
  @Local private showCoursePage: boolean = false;
  @Local private showAuthenticationPage: boolean = false;
  @Local private aboutToDisappearTriggered: boolean = false;
  @Local private collectionData: SampleCollectInfo = AppStorageV2.connect(SampleCollectInfo, () => new SampleCollectInfo())!;
  @Local private courseData: SampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;

  aboutToAppear(): void {
    this.collectionData.orderInfos = [this.createOrderInfo()];
    this.courseData.orderInfos = [this.createCourseOrderInfo()];
  }

  build() {
    Column({ space: 12 }) {
      Text('minePage Collection Instrument Host')
        .id(HOST_ANCHOR_ID)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)

      Text('minePage Course Instrument Host')
        .id(COURSE_HOST_ANCHOR_ID)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)

      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Button('ShowCollection')
            .id(SHOW_COLLECTION_PAGE_TRIGGER_ID)
            .onClick(() => {
              this.showCoursePage = false;
              this.showAuthenticationPage = false;
              this.aboutToDisappearTriggered = false;
              this.showLifecycleTarget = true;
            })
            .layoutWeight(1)
          Button('ShowCourse')
            .id(SHOW_COURSE_PAGE_TRIGGER_ID)
            .onClick(() => {
              this.showAuthenticationPage = false;
              this.showCoursePage = true;
            })
            .layoutWeight(1)
          Button('ShowAuthentication')
            .id(SHOW_AUTHENTICATION_PAGE_TRIGGER_ID)
            .onClick(() => {
              this.showAuthenticationPage = true;
              this.showCoursePage = false;
              this.showLifecycleTarget = false;
            })
            .layoutWeight(1)
        }
        .width('100%')

        Row({ space: 8 }) {
          Button('Reset')
            .id(RESET_COLLECTION_PAGE_TRIGGER_ID)
            .onClick(() => {
              this.aboutToDisappearTriggered = false;
              this.showLifecycleTarget = true;
              this.showCoursePage = false;
              this.showAuthenticationPage = false;
              this.collectionData.orderInfos = [this.createOrderInfo()];
            })
            .layoutWeight(1)
          Button('CourseReset')
            .id(RESET_COURSE_PAGE_TRIGGER_ID)
            .onClick(() => {
              this.courseData.orderInfos = [this.createCourseOrderInfo()];
              this.showCoursePage = true;
              this.showAuthenticationPage = false;
            })
            .layoutWeight(1)
        }
        .width('100%')

        Row({ space: 8 }) {
          Button('Filled')
            .id(SWITCH_TO_FILLED_TRIGGER_ID)
            .onClick(() => {
              this.collectionData.orderInfos = [this.createOrderInfo()];
            })
          Button('Empty')
            .id(SWITCH_TO_EMPTY_TRIGGER_ID)
            .onClick(() => {
              this.collectionData.orderInfos = [];
            })
          Button('Hide')
            .id(ABOUT_TO_DISAPPEAR_TRIGGER_ID)
            .onClick(() => {
              this.showLifecycleTarget = false;
            })
          Button('Show')
            .id('collection_show_lifecycle_trigger')
            .onClick(() => {
              this.aboutToDisappearTriggered = false;
              this.showLifecycleTarget = true;
            })
        }
        Row({ space: 8 }) {
          Button('CourseFilled')
            .id(SWITCH_COURSE_TO_FILLED_TRIGGER_ID)
            .onClick(() => {
              this.courseData.orderInfos = [this.createCourseOrderInfo()];
            })
          Button('CourseEmpty')
            .id(SWITCH_COURSE_TO_EMPTY_TRIGGER_ID)
            .onClick(() => {
              this.courseData.orderInfos = [];
            })
        }
      }

      if (this.aboutToDisappearTriggered) {
        Text('aboutToDisappear triggered')
          .id(ABOUT_TO_DISAPPEAR_MARKER_ID)
      }
      if (this.showLifecycleTarget && this.collectionData.orderInfos.length > 0) {
        Text('collection host filled ready')
          .id(COLLECTION_HOST_READY_FILLED_MARKER_ID)
      }
      if (this.showCoursePage && this.courseData.orderInfos.length > 0) {
        Text('course host filled ready')
          .id(COURSE_HOST_READY_FILLED_MARKER_ID)
      }
      if (this.showAuthenticationPage) {
        Text('authentication host ready')
          .id(AUTHENTICATION_HOST_READY_MARKER_ID)
      }

      Column() {
        if (this.showAuthenticationPage) {
          AuthenticationPage()
        } else if (this.showCoursePage) {
          CoursePage()
        } else if (this.showLifecycleTarget) {
          CollectionPage({
            onDisappearEvent: () => {
              this.aboutToDisappearTriggered = true;
            }
          })
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16);
  }

  private createOrderInfo(): OrderInfo {
    const orderInfo = new OrderInfo(
      'instrument-order-id',
      true,
      OrderState.Paid,
      'instrument-order-no',
      'Collection Instrument Course',
      false
    );
    orderInfo.price = '199';
    orderInfo.buyNumbers = 88;
    return orderInfo;
  }

  private createCourseOrderInfo(): OrderInfo {
    const orderInfo = new OrderInfo(
      'instrument-course-id',
      true,
      OrderState.Paid,
      'instrument-course-order-no',
      'Course Instrument Class',
      false
    );
    orderInfo.price = '299';
    orderInfo.buyNumbers = 36;
    return orderInfo;
  }
}
