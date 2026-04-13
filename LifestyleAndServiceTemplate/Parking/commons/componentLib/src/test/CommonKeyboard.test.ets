import { describe, it, expect } from '@ohos/hypium';
import { CommonKeyboard } from '../main/ets/components/CommonKeyboard';

function createKeyboardHost(): CommonKeyboard {
  class CommonKeyboardStorage extends LocalStorage {
    onChange: (_carNumber: string[], _isComplete: boolean) => void = () => {
    };
  }
  const keyboard = new CommonKeyboard(undefined, new CommonKeyboardStorage());
  keyboard.commonKeys = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'O', 'P', '港'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', '澳'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '学', '警', '删'],
  ];
  keyboard.keyBordTotal = [[], [], [], []];
  return keyboard;
}

function isKeyDisabled(host: CommonKeyboard, targetKey: string): boolean {
  for (let i = 0; i < host.keyBordTotal.length; i++) {
    for (let j = 0; j < host.keyBordTotal[i].length; j++) {
      if (host.keyBordTotal[i][j].key === targetKey) {
        return host.keyBordTotal[i][j].disable;
      }
    }
  }
  throw new Error(`Missing keyboard item for key: ${targetKey}`);
}

function dumpDisableStates(host: CommonKeyboard): string {
  const states: string[] = [];
  host.keyBordTotal.forEach((row) => {
    row.forEach((item) => {
      states.push(`${item.key}:${item.disable}`);
    });
  });
  return states.join(',');
}

export default function CommonKeyboardTest() {
  describe('CommonKeyboardTest', () => {
    it('disables number and special plate keys when the second position is focused', 0, () => {
      const keyboard = createKeyboardHost();

      keyboard.intDisableKey(1);

      ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '港', '澳', '学', '警'].forEach((key: string) => {
        expect(isKeyDisabled(keyboard, key)).assertTrue();
      });
      ['Q', 'O', 'A', '删'].forEach((key: string) => {
        expect(isKeyDisabled(keyboard, key)).assertFalse();
      });
    });

    it('uses the shared forbidden-key set for positions 3 to 6 and the new energy suffix position', 0, () => {
      [2, 3, 4, 5, 7].forEach((inputIndex: number) => {
        const keyboard = createKeyboardHost();

        keyboard.intDisableKey(inputIndex);

        ['O', '港', '澳', '学', '警'].forEach((key: string) => {
          expect(isKeyDisabled(keyboard, key)).assertTrue();
        });
        ['Q', '1', '删'].forEach((key: string) => {
          expect(isKeyDisabled(keyboard, key)).assertFalse();
        });
      });
    });

    it('only disables the letter O when the seventh position is focused', 0, () => {
      const keyboard = createKeyboardHost();

      keyboard.intDisableKey(6);

      expect(isKeyDisabled(keyboard, 'O')).assertTrue();
      ['港', '澳', '学', '警', '删', '1'].forEach((key: string) => {
        expect(isKeyDisabled(keyboard, key)).assertFalse();
      });
    });

    it('keeps the current keyboard state unchanged for positions without restrictions', 0, () => {
      const keyboard = createKeyboardHost();

      keyboard.intDisableKey(6);
      const previousState = dumpDisableStates(keyboard);

      keyboard.intDisableKey(0);

      expect(dumpDisableStates(keyboard)).assertEqual(previousState);
    });
  });
}
