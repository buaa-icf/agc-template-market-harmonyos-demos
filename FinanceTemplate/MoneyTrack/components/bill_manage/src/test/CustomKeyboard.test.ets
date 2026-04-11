import { describe, beforeEach, it, expect } from '@ohos/hypium';
import { CustomKeyboard } from '../main/ets/components/CustomKeyboard';
import {
  CustomKeyboardButtonType,
  CustomKeyboardDisplayType,
} from '../main/ets/commons/Enums';
import { CustomKeyboardItem } from '../main/ets/commons/Types';

class TestKeyboardButton implements CustomKeyboardItem {
  display: CustomKeyboardDisplayType = CustomKeyboardDisplayType.TEXT;
  type: CustomKeyboardButtonType;
  text: string;
  icon?: ResourceStr = undefined;
  bgColor?: ResourceColor = undefined;
  fontColor?: ResourceColor = undefined;

  constructor(type: CustomKeyboardButtonType, text: string) {
    this.type = type;
    this.text = text;
  }
}

class ConfirmRecorder {
  amountText: string = '';
  note: string = '';
  dateIso: string = '';

  record(amountArr: string[], note: string, date: Date): void {
    this.amountText = amountArr.join('|');
    this.note = note;
    this.dateIso = date.toISOString();
  }
}

class TestKeyboardParams {
  amountArr: string[];
  handleConfirm: (amountArr: string[], note: string, date: Date) => void;

  constructor() {
    this.amountArr = ['12'];
    this.handleConfirm = (_amountArr: string[], _note: string, _date: Date): void => {
    };
  }
}

function createKeyboard(): CustomKeyboard {
  let keyboard = new CustomKeyboard(
    undefined,
    new TestKeyboardParams() as Object as LocalStorage,
  );
  keyboard.note = 'lunch';
  keyboard.date = new Date('2024-01-02T00:00:00.000Z');
  keyboard.selectedDate = new Date('2024-01-02T00:00:00.000Z');
  keyboard.showDateDialog = false;
  return keyboard;
}

function amountTextOf(keyboard: CustomKeyboard): string {
  return keyboard.amountArr.join('|');
}

function resetAmountArr(keyboard: CustomKeyboard, values: string[]): void {
  keyboard.amountArr.splice(0, keyboard.amountArr.length);
  let index = 0;
  while (index < values.length) {
    keyboard.amountArr.push(values[index]);
    index += 1;
  }
}

export default function CustomKeyboardTest() {
  describe('CustomKeyboardTest', () => {
    let keyboard: CustomKeyboard;

    beforeEach(() => {
      keyboard = createKeyboard();
    });

    it('appends number text through handleClick', 0, () => {
      resetAmountArr(keyboard, ['88', '+', '12']);

      keyboard.handleClick(new TestKeyboardButton(CustomKeyboardButtonType.NUMBER, '3'));

      expect(amountTextOf(keyboard)).assertEqual('88|+|123');
    });

    it('opens date dialog when calendar button is clicked', 0, () => {
      keyboard.handleClick(new TestKeyboardButton(CustomKeyboardButtonType.CALENDAR, 'date'));

      expect(keyboard.showDateDialog).assertEqual(true);
    });

    it('appends subtraction symbol after a numeric segment', 0, () => {
      keyboard.handleClick(new TestKeyboardButton(CustomKeyboardButtonType.SUBTRACTION, '-'));

      expect(amountTextOf(keyboard)).assertEqual('12|-');
    });

    it('ignores subtraction when the current segment is not numeric', 0, () => {
      resetAmountArr(keyboard, ['12', '+']);

      keyboard.handleClick(new TestKeyboardButton(CustomKeyboardButtonType.SUBTRACTION, '-'));

      expect(amountTextOf(keyboard)).assertEqual('12|+');
    });

    it('appends addition symbol after a numeric segment', 0, () => {
      keyboard.handleClick(new TestKeyboardButton(CustomKeyboardButtonType.ADDITION, '+'));

      expect(amountTextOf(keyboard)).assertEqual('12|+');
    });

    it('adds a decimal point only once for the current segment', 0, () => {
      keyboard.handleClick(new TestKeyboardButton(CustomKeyboardButtonType.POINT, '.'));

      expect(amountTextOf(keyboard)).assertEqual('12.');

      keyboard.handleClick(new TestKeyboardButton(CustomKeyboardButtonType.POINT, '.'));

      expect(amountTextOf(keyboard)).assertEqual('12.');
    });

    it('deletes the last character when the current segment length is greater than one', 0, () => {
      resetAmountArr(keyboard, ['123']);

      keyboard.handleClick(new TestKeyboardButton(CustomKeyboardButtonType.DELETE, 'delete'));

      expect(amountTextOf(keyboard)).assertEqual('12');
    });

    it('removes the current segment when delete is clicked on a single character', 0, () => {
      resetAmountArr(keyboard, ['12', '+', '3']);

      keyboard.handleClick(new TestKeyboardButton(CustomKeyboardButtonType.DELETE, 'delete'));

      expect(amountTextOf(keyboard)).assertEqual('12|+');
    });

    it('passes amount, note, and date to handleConfirm on confirm', 0, () => {
      let recorder = new ConfirmRecorder();
      resetAmountArr(keyboard, ['88', '+', '12']);
      keyboard.note = 'dinner';
      keyboard.date = new Date('2024-03-04T00:00:00.000Z');
      keyboard.handleConfirm = (amountArr: string[], note: string, date: Date): void => {
        recorder.record(amountArr, note, date);
      };

      keyboard.handleClick(new TestKeyboardButton(CustomKeyboardButtonType.CONFIRM, 'confirm'));

      expect(recorder.amountText).assertEqual('88|+|12');
      expect(recorder.note).assertEqual('dinner');
      expect(recorder.dateIso).assertEqual('2024-03-04T00:00:00.000Z');
    });

    it('keeps state unchanged for unsupported button types', 0, () => {
      let beforeAmount = amountTextOf(keyboard);

      keyboard.handleClick(new TestKeyboardButton(99 as CustomKeyboardButtonType, 'unknown'));

      expect(amountTextOf(keyboard)).assertEqual(beforeAmount);
      expect(keyboard.showDateDialog).assertEqual(false);
    });
  });
}
