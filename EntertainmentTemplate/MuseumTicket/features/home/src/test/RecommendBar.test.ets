import { afterEach, beforeEach, describe, expect, it } from '@ohos/hypium';
import { RouterModule } from 'commonlib';
import { RecommendBar } from '../main/ets/component/RecommendBar';
import { RecommendListItem } from '../main/ets/types/Index';
import { HomePageVM } from '../main/ets/viewModels/HomePageVM';

@ComponentV2
struct RecommendBarTestHost {
  build() {
    RecommendBar();
  }
}

class RecommendBarTestHostRef extends RecommendBarTestHost {
  initialRender: () => void = () => {};
  aboutToBeDeleted?: () => void;
}

function cloneRecommendItem(item: RecommendListItem): RecommendListItem {
  return {
    id: item.id,
    img: item.img,
    name: item.name,
    detail: item.detail,
    price: item.price,
  };
}

export default function RecommendBarTest() {
  describe('RecommendBarTest', () => {
    const vm = HomePageVM.instance;
    let recommendListSnapshot: RecommendListItem[] = [];
    let host: RecommendBarTestHostRef | undefined;

    beforeEach(() => {
      RouterModule.clear();
      recommendListSnapshot = vm.recommendList.map(cloneRecommendItem);
      vm.recommendList = [
        {
          id: 'rec-1',
          img: 'resource://recommend_1',
          name: 'Echoes of Civilisation',
          detail: 'Guided artefact tour and themed experience',
          price: 68,
        },
        {
          id: 'rec-2',
          img: 'resource://recommend_2',
          name: 'Silk Road Journey',
          detail: 'Immersive exhibition route recommendation',
          price: 88,
        },
      ];
    });

    afterEach(() => {
      host?.aboutToBeDeleted?.();
      host = undefined;
      vm.recommendList = recommendListSnapshot.map(cloneRecommendItem);
      RouterModule.clear();
    });

    it('renders RecommendBar with populated recommend data from the shared HomePageVM', 0, () => {
      host = new RecommendBarTestHostRef();
      host.initialRender();

      const recommendBar = new RecommendBar();

      expect(recommendBar.vm).assertEqual(vm);
      expect(recommendBar.vm.recommendList.length).assertEqual(2);
      expect(recommendBar.vm.recommendList[0].id).assertEqual('rec-1');
      expect(recommendBar.vm.recommendList[1].name).assertEqual('Silk Road Journey');
      expect(RouterModule.size()).assertEqual(0);
    });

    it('renders RecommendBar safely when the shared recommend list is empty', 0, () => {
      vm.recommendList = [];

      host = new RecommendBarTestHostRef();
      host.initialRender();

      const recommendBar = new RecommendBar();

      expect(recommendBar.vm).assertEqual(vm);
      expect(recommendBar.vm.recommendList.length).assertEqual(0);
      expect(RouterModule.size()).assertEqual(0);
    });
  });
}
