import { homePageBuilder } from '../../../../../../../../src/main/ets/pages/HomePage';
import { City, DataStorage } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';

const CLEAR_DEPARTURE_ID: string = 'home_test_clear_departure';
const RESTORE_DEPARTURE_ID: string = 'home_test_restore_departure';

@Entry
@ComponentV2
struct Index {
  @Local dataStorage: DataStorage = AppStorageV2.connect(DataStorage, 'DataStorage', () => new DataStorage())!;

  private setDepartureCity(cityName: string): void {
    const city = new City();
    city.cityName = cityName;
    city.cityId = cityName;
    city.cityCode = cityName;
    this.dataStorage.departureCity = city;
  }

  build() {
    Column() {
      Text('Home test host')
        .id('home_test_host_anchor')
      Button('Clear departure city')
        .id(CLEAR_DEPARTURE_ID)
        .onClick(() => {
          this.setDepartureCity('');
        })
      Button('Restore departure city')
        .id(RESTORE_DEPARTURE_ID)
        .onClick(() => {
          this.setDepartureCity('上海');
        })
      homePageBuilder()
    }
    .width('100%')
    .height('100%')
  }
}
