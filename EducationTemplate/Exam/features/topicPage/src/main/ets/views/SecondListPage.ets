/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { RouterModule } from 'router_module';
import { SelectCategory, ThirdParam, ThirdItemModel } from 'select_category'
import { SecondParam } from 'base_select'
import { TopTabsBuilder } from 'commonlib';

@ComponentV2
export struct SecondListPage {
  @Local secondParamObj: SecondParam | undefined = undefined;

  aboutToAppear(): void {
    this.secondParamObj = RouterModule.getNavParam({ url: 'SecondListPage' }) as SecondParam
  }

  build() {
    Column() {
      // 标题组件
      TopTabsBuilder({ showBackButton: true, bgColor: $r('sys.color.background_primary') })
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      Divider().color($r('sys.color.comp_divider'))
      // 次级分类组件
      SelectCategory({
        secondParamObj: this.secondParamObj,
        currentColor: '#4B5CC4',
        contentIcon: $r('app.media.icon_right'),
        goPage: (val: string) => {
          // 点击的标题名称
          console.log(val)
        },
        goThird: (val: ThirdItemModel) => {
          // 跳转三级列表页
          let list: string[] = []
          if (this.secondParamObj) {
            this.secondParamObj.list.forEach((item: string) => {
              list.push(item)
            })
            list.push(val.title)
            let thirdParamObj: ThirdParam = new ThirdParam(list, val)
            RouterModule.push({ url: 'ThirdListPage', param: thirdParamObj })
          }
        }
      })
    }
    .height('100%')
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}

@Builder
export function SecondListPageBuilder() {
  SecondListPage()
}
