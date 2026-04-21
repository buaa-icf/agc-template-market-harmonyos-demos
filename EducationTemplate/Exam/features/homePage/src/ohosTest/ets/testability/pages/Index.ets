import { AuthenticationPageBuilder } from '../../../../main/ets/pages/AuthenticationPage';

const HOME_PAGE_HOST_ANCHOR_ID: string = 'home_page_instrument_host_anchor';
const AUTH_PAGE_MOUNT_ID: string = 'authentication_page_mount';

@Entry
@ComponentV2
struct Index {
  build() {
    Column({ space: 12 }) {
      Text('homePage Authentication Instrument Host')
        .id(HOME_PAGE_HOST_ANCHOR_ID)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)

      Column() {
        AuthenticationPageBuilder();
      }
      .id(AUTH_PAGE_MOUNT_ID)
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(16);
  }
}
