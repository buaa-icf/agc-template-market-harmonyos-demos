import { container } from '@agctemplate/utils';
import { BaseResponse } from '@agctemplate/utils';
import { MyFollowDramaRes, MyWatchRecordRes, RequestAPI } from '@agctemplate/server';
import { MyFavoritesPageBuilder } from '../../../../main/ets/pages/MyFavoritesPage';
import { WatchRecordsPageBuilder } from '../../../../main/ets/pages/WatchRecordsPage';

enum MineTestPage {
  Favorites = 'favorites',
  WatchRecords = 'watchRecords'
}

class MineRequestAPITestDouble extends RequestAPI {
  getMyFollowDrama(): Promise<BaseResponse<MyFollowDramaRes>> {
    const response: MyFollowDramaRes = new MyFollowDramaRes({
      ret: {
        code: '0',
        msg: 'ok'
      },
      myFollowDramas: [
        {
          id: 'test_fav_001',
          coverUrl: '',
          promotionalUrl: '',
          name: 'UI Test Favorite Drama',
          description: 'UI test description',
          totalCount: 12,
          curIndex: 1,
          currentWatch: 1,
          latestUpdate: 8,
          category: 'test',
          popular: '100',
          actorInfo: [],
          episodeList: [],
          isFavorite: true,
          favoriteCount: 1
        }
      ],
      total: 1
    } as MyFollowDramaRes);
    return Promise.resolve(new BaseResponse<MyFollowDramaRes>(response));
  }

  getMyWatchRecord(): Promise<BaseResponse<MyWatchRecordRes>> {
    const response: MyWatchRecordRes = new MyWatchRecordRes({
      ret: {
        code: '0',
        msg: 'ok'
      },
      myWatchRecord: [
        {
          id: 'test_watch_001',
          coverUrl: '',
          promotionalUrl: '',
          name: 'UI Test Watch Drama',
          description: 'UI watch test description',
          totalCount: 20,
          curIndex: 2,
          currentWatch: 2,
          latestUpdate: 10,
          category: 'test',
          popular: '200',
          actorInfo: [],
          episodeList: [],
          isFavorite: true,
          favoriteCount: 2
        }
      ],
      total: 1
    } as MyWatchRecordRes);
    return Promise.resolve(new BaseResponse<MyWatchRecordRes>(response));
  }
}

@Entry
@Component
struct Index {
  @State selectedPage: MineTestPage = MineTestPage.Favorites;

  aboutToAppear(): void {
    container.register(RequestAPI, {
      value: new MineRequestAPITestDouble()
    });
  }

  build() {
    Column() {
      Row() {
        Button('Favorites')
          .id('mine_test_switch_favorites')
          .onClick(() => {
            this.selectedPage = MineTestPage.Favorites;
          })
        Button('WatchRecords')
          .id('mine_test_switch_watch_records')
          .onClick(() => {
            this.selectedPage = MineTestPage.WatchRecords;
          })
      }
      .id('mine_test_switch_row')
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: 8, bottom: 8 })

      Column() {
        if (this.selectedPage === MineTestPage.Favorites) {
          MyFavoritesPageBuilder();
        } else {
          WatchRecordsPageBuilder();
        }
      }
      .layoutWeight(1)
      .width('100%')
    }
    .id('mine_test_host')
    .width('100%')
    .height('100%');
  }
}
