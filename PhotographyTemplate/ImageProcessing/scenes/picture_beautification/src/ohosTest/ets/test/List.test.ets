import abilityTest from './Ability.test';
import carouseCutToolBarTest from './CarouseCutToolBar.test';
import PictureBeautificationTest from './PictureBeautification.test';
import stickerToolBarTest from './StickerToolBar.test';

export default function testsuite() {
  abilityTest();
  carouseCutToolBarTest();
  PictureBeautificationTest();
  stickerToolBarTest();
}
