import { FormatUtil, RouterMap } from 'commonlib'
import { IProductItem } from 'network/src/main/ets/types/responseTypes/GetProductResp'
import { ProductSearchVM } from '../viewModels/ProductSearchVM'

@Builder
export function ProductSearchBuilder() {
  ProductSearch()
}

@ComponentV2
struct ProductSearch {
  vm: ProductSearchVM = ProductSearchVM.instance
  searchController: SearchController = new SearchController()

  build() {
    NavDestination() {
      Column() {
        Row() {
          Search({ value: this.vm.searchText, placeholder: '璇疯緭鍏ヤ骇鍝佸悕绉?浠ｇ爜', controller: this.searchController })
            .id('product_search_input')
            .width('100%')
            .height(40)
            .placeholderColor($r('sys.color.font_secondary'))
            .placeholderFont({ size: 16, weight: FontWeight.Regular })
            .textFont({ size: 16, weight: FontWeight.Regular })
            .fontColor($r('sys.color.font_primary'))
            .onSubmit((value: string) => {
              this.vm.search(value)
            })
        }
        .padding({ left: 16, right: 16 })

        Row() {
          Text(`鍏辨${this.vm.productList.length}浜у搧`)
            .id('product_search_count')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .margin({ top: 16, bottom: 8 })
        .padding({ left: 16, right: 16 })

        List() {
          ForEach(this.vm.productList, (product: IProductItem) => {
            ListItem() {
              Column() {
                Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                  Row() {
                    Text(product.name)
                      .id(`product_search_name_${product.id}`)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .fontColor($r('sys.color.font_primary'))
                  }
                  .width('75%')
                  .margin({ right: 8 })

                  Row() {
                    Text(product.annualizedRate + '%')
                      .id(`product_search_rate_${product.id}`)
                      .fontColor('#C15F2F')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                  }
                  .width('25%')
                  .justifyContent(FlexAlign.End)
                }
                .height(38)
                .margin({ bottom: 2 })

                Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                  Row() {
                    Text(product.number)
                      .id(`product_search_number_${product.id}`)
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width('75%')
                  .margin({ right: 8 })

                  Row() {
                    Text(product.annualizedCycle)
                      .id(`product_search_cycle_${product.id}`)
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width('25%')
                  .justifyContent(FlexAlign.End)
                }
              }
              .padding({
                left: 16,
                right: 16,
                top: 12,
                bottom: 8
              })
              .borderWidth({ bottom: 1 })
              .borderColor('#F1F3F5')
            }
            .id(`product_search_item_${product.id}`)
            .backgroundColor(Color.White)
            .onClick(() => {
              FormatUtil.jumpToNext(RouterMap.PRODUCT_INFO, product.id)
            })
          }, (item: IProductItem) => item.id.toString())
        }
        .id('product_search_list')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .id('product_search_root')
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('鎼滅储')
    .onShown(() => {
      this.vm.init()
    })
  }
}
