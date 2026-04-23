import { jumpDetailPage } from '@agctemplate/detail'
import { getString } from '@agctemplate/resources'
import { MyFollowDramaData, MyFollowDramaRes, RequestAPI } from '@agctemplate/server'
import { appRouter, container } from '@agctemplate/utils'
import { NavDestinationModifier } from '@agctemplate/widgets'
import { VideoSeries } from '../component/VideoSeries'

@ComponentV2
export struct MyFavoritesPage {
  @Local myFollowDramaRes: MyFollowDramaRes = new MyFollowDramaRes();
  navDestinationModifier: NavDestinationModifier = new NavDestinationModifier();

  aboutToAppear(): void {
    container.resolve(RequestAPI).getMyFollowDrama({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.myFollowDramaRes = new MyFollowDramaRes(res.getBody());
    })
  }

  build() {
    NavDestination() {
      Column() {
        List() {
          Repeat<MyFollowDramaData>(this.myFollowDramaRes.myFollowDramas)
            .each((ri: RepeatItem<MyFollowDramaData>) => { // 默认模板
              ListItem() {
                VideoSeries({
                  title: ri.item.name,
                  currentEpisode: ri.item.currentWatch + 1,
                  episodesDes: ri.item.description,
                  cover: ri.item.coverUrl,
                  onContinueWatch: () => {
                    jumpDetailPage(ri.item, ri.item.currentWatch)
                  }
                })
              }.onClick(() => {
                jumpDetailPage(ri.item, ri.item.currentWatch)
              })
              .id(`my_favorites_series_item_${ri.item.id}`)
            })
            .key((item: MyFollowDramaData, index: number): string => item.id)// 键值生成函数
            .virtualScroll({
              totalCount: this.myFollowDramaRes.myFollowDramas.length
            }) // 打开virtualScroll模式，totalCount为期望加载的数据长度
        }
        .id('my_favorites_series_list')
        .scrollBar(BarState.Off)
        .cachedCount(4) // 容器组件的预加载区域大小
      }
      .id('my_favorites_root_column')
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .id('my_favorites_nav_destination')
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
    Text(getString('app.string.my_favor'))
      .id('my_favorites_title_text')
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .height(27)
      .margin({ top: 15, left: 8 })
  }

}

@Builder
export function MyFavoritesPageBuilder() {
  MyFavoritesPage()
}
