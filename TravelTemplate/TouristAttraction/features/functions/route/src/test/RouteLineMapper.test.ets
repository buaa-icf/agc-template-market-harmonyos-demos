import { describe, expect, it } from '@ohos/hypium';
import { AttractionListItem, GetRouteLineDetailResp } from 'network';
import { mapperRouteLineDetail } from '../main/ets/mapper/Index';

export default function RouteLineMapperTest() {
  describe('RouteLineMapperTest', () => {
    it('maps route properties and every nested attraction into view models', 0, () => {
      const attraction: AttractionListItem = {
        attractionId: 1,
        labels: ['museum'],
        detailImages: ['spot.png'],
        name: 'Museum',
        banner: 'banner.png',
        icon: 'icon.png',
        isHot: 1,
        latitude: 31.97,
        longitude: 118.75,
        audio: 'audio.mp3',
        location: 'old town'
      };
      const response: GetRouteLineDetailResp = {
        routeId: 1, routeName: 'Old Town Walk', routeDistance: 3, duration: 2,
        routeBanner: 'route.png', labels: ['history'], brief: 'A short route', introduction: 'Full route guide',
        attractions: [attraction]
      };

      const route = mapperRouteLineDetail(response);

      expect(route.routeId).assertEqual(1);
      expect(route.routeName).assertEqual('Old Town Walk');
      expect(route.attractions.length).assertEqual(1);
      expect(route.attractions[0].attractionId).assertEqual(1);
      expect(route.attractions[0].detailImages[0]).assertEqual('spot.png');
    });
  });
}
