import { DateElement } from '@ohos_agcit/office_attendance_component_lib';
import { Constants } from '../../../../../../../../src/main/ets/constants/Constants';
import { ScheduleForm } from '../../../../../../../../src/main/ets/schedule/components/ScheduleForm';
import { ScheduleInfo } from '../../../../../../../../src/main/ets/types/Types';

const HOST_ANCHOR_ID = 'schedule_form_test_host_anchor';

@Entry
@ComponentV2
struct Index {
  @Provider() schedule: ScheduleInfo = {
    title: '',
    location: '会议室A',
    isAllDay: false,
    recurrenceRule: Constants.NO_REPEAT,
    reminderTime: [Constants.REMINDER_MINUTES_30],
    startTime: '2026-03-02 09:30',
    endTime: '2026-03-02 10:30',
    desc: ''
  };
  @Provider() selectedDay: DateElement | undefined = new DateElement(2026, 2, 2);

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      ScheduleForm({
        titleResID: 'app.string.new_schedule'
      })

      Column({ space: 2 }) {
        Text('schedule_form_test_host')
          .id(HOST_ANCHOR_ID)
      }
      .alignItems(HorizontalAlign.Start)
      .padding(4)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
