import { describe, expect, it } from '@ohos/hypium';
import { mapperRouteLineDetail } from '../main/ets/mapper/Index';

export default function RouteLineMapperTest() {
  describe('RouteLineMapperTest', () => {
    it('maps route properties and every nested attraction into view models', 0, () => {
      const response = {
        routeId: 'route-1', routeName: 'Old Town Walk', routeDistance: '3km', duration: '2h',
        routeBanner: 'route.png', labels: ['history'], brief: 'A short route', introduction: 'Full route guide',
        attractions: [{ attractionId: 'spot-1', labels: ['museum'], detailImages: ['spot.png'], name: 'Museum', banner: 'banner.png' }]
      } as never;

      const route = mapperRouteLineDetail(response);

      expect(route.routeId).assertEqual('route-1');
      expect(route.routeName).assertEqual('Old Town Walk');
      expect(route.attractions.length).assertEqual(1);
      expect(route.attractions[0].attractionId).assertEqual('spot-1');
      expect(route.attractions[0].detailImages[0]).assertEqual('spot.png');
    });
  });
}
