import { homePageBuilder } from '../../../../../../../../src/main/ets/pages/HomePage';
import { City, DataStorage } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';

const CLEAR_DEPARTURE_ID: string = 'home_test_clear_departure';
const RESTORE_DEPARTURE_ID: string = 'home_test_restore_departure';
const CLEAR_DESTINATION_ID: string = 'home_test_clear_destination';
const RESTORE_DESTINATION_ID: string = 'home_test_restore_destination';

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

  private setDestinationCity(cityName: string): void {
    const city = new City();
    city.cityName = cityName;
    city.cityId = cityName;
    city.cityCode = cityName;
    this.dataStorage.destinationCity = city;
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
      Button('Clear destination city')
        .id(CLEAR_DESTINATION_ID)
        .onClick(() => {
          this.setDestinationCity('');
        })
      Button('Restore destination city')
        .id(RESTORE_DESTINATION_ID)
        .onClick(() => {
          this.setDestinationCity('Beijing');
        })
      homePageBuilder()
    }
    .width('100%')
    .height('100%')
  }
}
