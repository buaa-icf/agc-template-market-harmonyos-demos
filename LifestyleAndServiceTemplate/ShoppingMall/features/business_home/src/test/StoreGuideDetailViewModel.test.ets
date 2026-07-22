import { afterEach, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { GuideRouter, RouterMap, RouterUtil, StoreGuide } from 'lib_common';
import { StoreGuideDetailViewModel } from '../main/ets/viewmodel/StoreGuideDetailViewModel';

function createGuideRouter(): GuideRouter {
  return {
    guide: new StoreGuide('guide-1', 'logo.png', 'Coffee House', 'cover.png', 'L2-08', 'L2', 'Coffee',
      '13800000000', 'Fresh coffee and pastries')
  };
}

export default function StoreGuideDetailViewModelTest() {
  describe('StoreGuideDetailViewModelTest', () => {
    let mockKit: MockKit;

    beforeEach(() => {
      mockKit = new MockKit();
    });

    afterEach(() => {
      mockKit.clear(RouterUtil);
    });

    it('copies the last store guide route parameter into observable state', 0, () => {
      const getParamByName = mockKit.mockFunc(RouterUtil, RouterUtil.getParamByName);
      const first = createGuideRouter();
      const last = createGuideRouter();
      last.guide.name = 'Last Guide';
      when(getParamByName)(RouterMap.STORE_GUIDE_DETAIL_PAGE).afterReturn([first, last]);
      const viewModel = new StoreGuideDetailViewModel();

      viewModel.getParams();

      expect(viewModel.storeGuide.id).assertEqual('guide-1');
      expect(viewModel.storeGuide.name).assertEqual('Last Guide');
      expect(viewModel.storeGuide.introduce).assertEqual('Fresh coffee and pastries');
    });

    it('keeps default guide data when no route parameter is available', 0, () => {
      const getParamByName = mockKit.mockFunc(RouterUtil, RouterUtil.getParamByName);
      when(getParamByName)(RouterMap.STORE_GUIDE_DETAIL_PAGE).afterReturn([]);
      const viewModel = new StoreGuideDetailViewModel();

      viewModel.getParams();

      expect(viewModel.storeGuide.id).assertEqual('');
      expect(viewModel.storeGuide.name).assertEqual('');
    });
  });
}
