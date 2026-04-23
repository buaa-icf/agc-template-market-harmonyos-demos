import { jumpDetailPage } from '@agctemplate/detail';
import { getString } from '@agctemplate/resources';
import { MyWatchRecordData, MyWatchRecordRes, RequestAPI } from '@agctemplate/server';
import { appRouter, container } from '@agctemplate/utils';
import { NavDestinationModifier } from '@agctemplate/widgets'
import { VideoSeries } from '../component/VideoSeries';

@ComponentV2
export struct WatchRecordsPage {
  @Local myWatchRecordRes: MyWatchRecordRes = new MyWatchRecordRes();
  navDestinationModifier: NavDestinationModifier = new NavDestinationModifier();

  aboutToAppear(): void {
    container.resolve(RequestAPI).getMyWatchRecord({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.myWatchRecordRes = new MyWatchRecordRes(res.getBody());
    })
  }

  build() {
    NavDestination() {
      Column() {
        List() {
          Repeat<MyWatchRecordData>(this.myWatchRecordRes.myWatchRecord)
            .each((ri: RepeatItem<MyWatchRecordData>) => {
              ListItem() {
                VideoSeries({
                  title: ri.item.name,
                  currentEpisode: ri.item.currentWatch + 1,
                  episodesDes: ri.item.name,
                  cover: ri.item.coverUrl,
                  onContinueWatch: () => {
                    jumpDetailPage(ri.item, ri.item.currentWatch)
                  }
                })
              }
              .id(`watch_records_series_item_${ri.item.id}`)
            })
            .key((item: MyWatchRecordData, index: number): string => item.id)
            .virtualScroll({
              totalCount: this.myWatchRecordRes.myWatchRecord.length
            })
        }
        .id('watch_records_series_list')
        .scrollBar(BarState.Off)
        .cachedCount(4)
      }
      .id('watch_records_root_column')
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .id('watch_records_nav_destination')
    .onBackPressed(() => {
      appRouter.back(true)
      return true
    })
    .hideTitleBar(false)
    .title(this.title())
    .backgroundColor($r('sys.color.background_primary'))
    .attributeModifier(this.navDestinationModifier)
    .height('100%')
  }

  @Builder
  title() {
    Text(getString('app.string.my_record'))
      .id('watch_records_title_text')
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .height(27)
      .margin({ top: 15, left: 8 })
  }

}

@Builder
export function WatchRecordsPageBuilder() {
  WatchRecordsPage()
}
