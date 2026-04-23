import { scanPointConfirmBuilder, photoPointConfirmBuilder, PointConfirmParam } from '../../../../../../../../src/main/ets/components/SubmitPointConfirm.ets';

const TEST_HOST_ROOT_ID: string = 'submit_point_confirm_test_host_root';
const SCAN_SECTION_ID: string = 'submit_point_confirm_scan_section';
const PHOTO_SECTION_ID: string = 'submit_point_confirm_photo_section';
const SCAN_CLOSE_STATUS_ID: string = 'submit_point_confirm_scan_close_status';
const SCAN_CONFIRM_STATUS_ID: string = 'submit_point_confirm_scan_confirm_status';
const PHOTO_CLOSE_STATUS_ID: string = 'submit_point_confirm_photo_close_status';
const PHOTO_CONFIRM_STATUS_ID: string = 'submit_point_confirm_photo_confirm_status';

@Entry
@Component
struct Index {
  @State private scanClosed: string = 'false';
  @State private scanConfirmed: string = 'false';
  @State private photoClosed: string = 'false';
  @State private photoConfirmed: string = 'false';

  private readonly scanParam: PointConfirmParam = {
    type: 1,
    content: 'scan-test-content',
    close: () => {
      this.scanClosed = 'true';
    },
    confirm: () => {
      this.scanConfirmed = 'true';
    }
  };

  private readonly photoParam: PointConfirmParam = {
    type: 2,
    content: 'photo-test-content',
    close: () => {
      this.photoClosed = 'true';
    },
    confirm: () => {
      this.photoConfirmed = 'true';
    }
  };

  @Builder
  private scanSection() {
    Column({ space: 8 }) {
      scanPointConfirmBuilder(this.scanParam);
      Text(this.scanClosed)
        .id(SCAN_CLOSE_STATUS_ID);
      Text(this.scanConfirmed)
        .id(SCAN_CONFIRM_STATUS_ID);
    }
    .id(SCAN_SECTION_ID)
    .width('100%');
  }

  @Builder
  private photoSection() {
    Column({ space: 8 }) {
      photoPointConfirmBuilder(this.photoParam);
      Text(this.photoClosed)
        .id(PHOTO_CLOSE_STATUS_ID);
      Text(this.photoConfirmed)
        .id(PHOTO_CONFIRM_STATUS_ID);
    }
    .id(PHOTO_SECTION_ID)
    .width('100%');
  }

  build() {
    Scroll() {
      Column({ space: 24 }) {
        this.scanSection();
        this.photoSection();
      }
      .id(TEST_HOST_ROOT_ID)
      .width('100%')
      .padding({ top: 24, bottom: 24 });
    }
    .width('100%')
    .height('100%');
  }
}
