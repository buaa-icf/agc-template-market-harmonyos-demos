import { BasicUserInfo, Feed } from 'commons';
import { FeedBasic } from '../../../../../../../../src/main/ets/pages/FeedListPage';

const HOST_ANCHOR_ID = 'feed_test_host_anchor';

function createCurrentUser(): BasicUserInfo {
  const user = new BasicUserInfo();
  user.uid = 7;
  user.nickName = 'Current User';
  return user;
}

function createLikedFeed(): Feed {
  const feed = new Feed();
  feed.feedId = 1;
  feed.uid = 7;
  feed.feedMsg = 'Instrument test feed';
  feed.resourceUrl = [];
  feed.comments = [];
  feed.likes = [createCurrentUser()];
  return feed;
}

@Entry
@Component
struct Index {
  private currentUser: BasicUserInfo = createCurrentUser();
  private feed: Feed = createLikedFeed();

  build() {
    Column() {
      Text('Feed test host')
        .id(HOST_ANCHOR_ID)
        .fontSize(1)
        .opacity(0.01)
      FeedBasic({ item: this.feed, currentUser: this.currentUser })
    }
    .width('100%')
    .height('100%')
  }
}
