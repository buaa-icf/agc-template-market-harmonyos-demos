import { common } from '@kit.AbilityKit';
import { BookApi, BookInfo, GlobalContext } from 'common';
import { SearchViewModels } from '../../../../../../../../src/main/ets/viewModels/SearchViewModels';
import { SearchPage } from '../../../../../../../../src/main/ets/views/SearchPage';

@Entry
@ComponentV2
struct Index {
  private scenarioBook: BookInfo = {
    id: '11',
    name: '\u8bdb\u4ed9',
    author: '\u8427\u9f0e',
    coverUrl: $r('app.media.book_image_1'),
    rate: '9.0',
    description: 'SearchPage instrument test book',
    localPath: '',
    epubUrl: '',
    category: 'CategoryProbe',
    count: '10',
    popular: '20'
  };

  aboutToAppear(): void {
    const hostContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    GlobalContext.initContext(hostContext);
    BookApi.init('data.json');
    AppStorage.setOrCreate('windowTopHeight', 0);
    const searchViewModel: SearchViewModels = SearchViewModels.instance;
    searchViewModel.keyword = '\u8bdb\u4ed9';
    searchViewModel.historyInfo = ['\u8bdb\u4ed9', '\u4e0d\u5b58\u5728\u7684\u8bcd\u6761'];
    searchViewModel.hotInfo = ['\u5c0f\u7f8a\u8096\u6069', '\u65c5\u9014'];
  }

  build() {
    Stack() {
      SearchPage({ testScenario: 0, testBooks: [] })
      SearchPage({ testScenario: 1, testBooks: [this.scenarioBook] })
      SearchPage({ testScenario: 2, testBooks: [this.scenarioBook] })
      SearchPage({ testScenario: 3, testBooks: [] })
      SearchPage({ testScenario: 4, testBooks: [this.scenarioBook] })
    }
    .width('100%')
    .height('100%')
  }
}
