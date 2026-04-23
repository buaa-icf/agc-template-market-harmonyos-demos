import { RouterModule, RouterMap } from 'commonlib';
import { RecommendListItem } from '../types/Index';
import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct RecommendBar {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Column() {
      Text('推荐展览')
        .id('recommend_bar_title')
        .width('100%')
        .fontWeight(500)
        .fontColor($r('sys.color.ohos_id_color_text_primary'));
      ForEach(this.vm.recommendList, (item: RecommendListItem, index) => {
        Column() {
          Image(item.img)
            .id(`recommend_bar_image_${item.id}`)
            .height(166)
            .width('100%');
          Column() {
            Text(item.name)
              .id(`recommend_bar_name_${item.id}`)
              .fontWeight(500)
              .fontColor($r('sys.color.ohos_id_color_text_primary'));
            Text(item.detail)
              .id(`recommend_bar_detail_${item.id}`)
              .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .margin({ top: 10 });
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              Row() {
                Text('¥')
                  .fontSize($r('sys.float.ohos_id_text_size_caption'))
                  .fontColor($r('app.color.font_color_red'))
                  .margin({ top: 4 });
                Text(item.price.toString())
                  .id(`recommend_bar_price_${item.id}`)
                  .fontColor($r('app.color.font_color_red'))
                  .fontWeight(500)
                  .fontSize(20);
              };

              Button('预约')
                .id(`recommend_bar_book_${item.id}`)
                .borderRadius(14)
                .width(72)
                .height(28)
                .backgroundColor($r('sys.color.ohos_id_color_palette_aux3'))
                .fontColor($r('app.color.font_color_green'));
            };
          }.padding(10).alignItems(HorizontalAlign.Start);

        }
        .id(`recommend_bar_item_${item.id}`)
        .height(256)
        .backgroundColor($r('sys.color.ohos_id_color_background'))
        .borderRadius(8)
        .clip(true)
        .margin({ top: 10 })
        .onClick(() => {
          RouterModule.push({ url: RouterMap.PERFORMANCE_DETAIL, param: { id: item.id } });
        });
      }, (item: RecommendListItem, index) => item.id);
    }.margin({ bottom: 20 });
  }
}
