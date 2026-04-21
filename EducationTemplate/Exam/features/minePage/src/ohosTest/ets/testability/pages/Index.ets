import { AppStorageV2 } from '@kit.ArkUI';
import { CollectionPage } from '../../../../main/ets/views/CollectionPage';
import { OrderInfo, OrderState, SampleCollectInfo } from 'commonlib';

const HOST_ANCHOR_ID: string = 'mine_page_collection_instrument_host_anchor';
const ABOUT_TO_DISAPPEAR_MARKER_ID: string = 'collection_about_to_disappear_marker';
const ABOUT_TO_DISAPPEAR_TRIGGER_ID: string = 'collection_about_to_disappear_trigger';
const SWITCH_TO_EMPTY_TRIGGER_ID: string = 'collection_switch_to_empty_trigger';
const SWITCH_TO_FILLED_TRIGGER_ID: string = 'collection_switch_to_filled_trigger';
const SHOW_COLLECTION_PAGE_TRIGGER_ID: string = 'collection_show_page_trigger';
const RESET_COLLECTION_PAGE_TRIGGER_ID: string = 'collection_reset_to_filled_trigger';
const COLLECTION_HOST_READY_FILLED_MARKER_ID: string = 'collection_host_ready_filled_marker';

@Entry
@ComponentV2
struct Index {
  @Local private showLifecycleTarget: boolean = true;
  @Local private aboutToDisappearTriggered: boolean = false;
  @Local private collectionData: SampleCollectInfo = AppStorageV2.connect(SampleCollectInfo, () => new SampleCollectInfo())!;

  aboutToAppear(): void {
    this.collectionData.orderInfos = [this.createOrderInfo()];
  }

  build() {
    Column({ space: 12 }) {
      Text('minePage Collection Instrument Host')
        .id(HOST_ANCHOR_ID)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)

      Column({ space: 8 }) {
        Button('Reset')
          .id(RESET_COLLECTION_PAGE_TRIGGER_ID)
          .onClick(() => {
            this.aboutToDisappearTriggered = false;
            this.showLifecycleTarget = true;
            this.collectionData.orderInfos = [this.createOrderInfo()];
          })
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
            .id(SHOW_COLLECTION_PAGE_TRIGGER_ID)
            .onClick(() => {
              this.aboutToDisappearTriggered = false;
              this.showLifecycleTarget = true;
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

      Column() {
        if (this.showLifecycleTarget) {
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
}
