import { BasicUserInfo, Constants, Feed } from 'commons';
import { FeedBasic } from '../../../../../../../../src/main/ets/pages/FeedListPage';

const HOST_ANCHOR_ID = 'feed_test_host_anchor';
const LIKED_SCENARIO_ID = 'feed_show_liked';
const UNLIKED_SCENARIO_ID = 'feed_show_unliked';
const HIDDEN_INTERACTION_SCENARIO_ID = 'feed_show_hidden_interaction';
const EMPTY_COLLECTIONS_SCENARIO_ID = 'feed_show_empty_collections';

function createCurrentUser(isVip: boolean): BasicUserInfo {
  const user = new BasicUserInfo();
  user.uid = 7;
  user.nickName = 'Current User';
  user.isVip = isVip ? Constants.YES : 0;
  return user;
}

function createFeed(liked: boolean): Feed {
  const feed = new Feed();
  feed.feedId = 1;
  feed.uid = 7;
  feed.feedMsg = 'Instrument test feed';
  feed.resourceUrl = [];
  feed.comments = [];
  if (liked) {
    feed.likes = [createCurrentUser(true)];
  } else {
    const otherUser = createCurrentUser(false);
    otherUser.uid = 8;
    feed.likes = [otherUser];
  }
  return feed;
}

function createFeedWithoutCollections(): Feed {
  const feed = new Feed();
  feed.feedId = 2;
  feed.uid = 7;
  feed.feedMsg = 'Feed without collections';
  feed.resourceUrl = [];
  feed.comments = null;
  feed.likes = null;
  return feed;
}

@Entry
@Component
struct Index {
  @State private scenario: string = 'liked';

  build() {
    Column({ space: 8 }) {
      Text('Feed test host')
        .id(HOST_ANCHOR_ID)
        .fontSize(1)
        .opacity(0.01)

      Row({ space: 8 }) {
        Button('Liked')
          .id(LIKED_SCENARIO_ID)
          .onClick(() => {
            this.scenario = 'liked';
          })
        Button('Unliked')
          .id(UNLIKED_SCENARIO_ID)
          .onClick(() => {
            this.scenario = 'unliked';
          })
        Button('Basic')
          .id(HIDDEN_INTERACTION_SCENARIO_ID)
          .onClick(() => {
            this.scenario = 'basic';
          })
      }

      Row() {
        Button('Empty Collections')
          .id(EMPTY_COLLECTIONS_SCENARIO_ID)
          .onClick(() => {
            this.scenario = 'empty';
          })
      }

      if (this.scenario === 'liked') {
        FeedBasic({ item: createFeed(true), currentUser: createCurrentUser(true) })
      } else if (this.scenario === 'unliked') {
        FeedBasic({ item: createFeed(false), currentUser: createCurrentUser(false) })
      } else if (this.scenario === 'basic') {
        Column() {
          Text('Basic feed scenario')
            .id('feed_basic_scenario_anchor')
            .fontSize(1)
            .opacity(0.01)
          FeedBasic({
            item: createFeed(false),
            currentUser: createCurrentUser(false),
            showInteraction: false,
            showUserInfo: false
          })
        }
      } else {
        Column() {
          Text('Empty collections scenario')
            .id('feed_empty_collections_anchor')
            .fontSize(1)
            .opacity(0.01)
          FeedBasic({
            item: createFeedWithoutCollections(),
            currentUser: createCurrentUser(false),
            showInteraction: false,
            showUserInfo: false
          })
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}
