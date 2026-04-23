import { CalenderView } from '../../../../../../../../src/main/ets/components/CalenderView';
import { DateElement } from '../../../../../../../../src/main/ets/types/DateElement';

const HOST_ANCHOR_ID: string = 'calender_view_test_host_anchor';
const SHOW_MONTH_ID: string = 'calender_view_show_month';
const SELECTED_DAY_ID: string = 'calender_view_selected_day';
const CHANGE_MONTH_COUNT_ID: string = 'calender_view_change_month_count';
const CHANGE_DAY_COUNT_ID: string = 'calender_view_change_day_count';
const GESTURE_AREA_ID: string = 'calender_view_gesture_area';

@Entry
@ComponentV2
struct Index {
  @Local showMonth: DateElement = new DateElement(2026, 5, -1);
  @Local selectedDay: DateElement = new DateElement(-1, -1, -1);
  @Local changeMonthCount: number = 0;
  @Local changeDayCount: number = 0;

  build() {
    Column({ space: 4 }) {
      Text('CalenderView UITest Host')
        .id(HOST_ANCHOR_ID)
        .fontSize(14);

      Text(`month:${this.showMonth.year}-${this.showMonth.month}`)
        .id(SHOW_MONTH_ID)
        .fontSize(14);

      Text(`day:${this.selectedDay.year}-${this.selectedDay.month}-${this.selectedDay.day}`)
        .id(SELECTED_DAY_ID)
        .fontSize(14);

      Text(`cm:${this.changeMonthCount}`)
        .id(CHANGE_MONTH_COUNT_ID)
        .fontSize(12);

      Text(`cd:${this.changeDayCount}`)
        .id(CHANGE_DAY_COUNT_ID)
        .fontSize(12);

      Column() {
        CalenderView({
          showMonth: this.showMonth,
          selectedDay: this.selectedDay,
          onChangeMonth: (m: DateElement) => {
            this.changeMonthCount += 1;
          },
          onChangeDay: (d: DateElement) => {
            this.changeDayCount += 1;
          }
        });
      }
      .id(GESTURE_AREA_ID)
      .width('100%');
    }
    .width('100%')
    .height('100%')
    .padding(8)
    .backgroundColor(Color.White);
  }
}
