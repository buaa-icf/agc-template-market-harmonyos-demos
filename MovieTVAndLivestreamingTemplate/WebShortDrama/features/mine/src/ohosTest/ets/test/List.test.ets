import abilityTest from './Ability.test';
import myFavoritesPageUiTest from './MyFavoritesPage.test';
import watchRecordsPageUiTest from './WatchRecordsPage.test';

export default function testsuite() {
  abilityTest();
  myFavoritesPageUiTest();
  watchRecordsPageUiTest();
}
