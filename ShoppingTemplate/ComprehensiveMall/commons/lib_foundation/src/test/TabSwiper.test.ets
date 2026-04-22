import { afterEach, beforeEach, describe, expect, it } from '@ohos/hypium';

import { ComponentEntry, ComponentEntryProxy } from '../main/ets/types/ComponentEntry';
import { Any } from '../main/ets/types/CustomType';
import { TabSwiper } from '../main/ets/featurecomponents/tabswiper/TabSwiper';
import {
  TabLayoutMode,
  TabSwiperRenderUnit,
  TabSwiperViewData,
} from '../main/ets/featurecomponents/tabswiper/model/TabSwiperTypes';

class ChangeIndexCall {
  public index: number;
  public useAnimation: boolean;

  constructor(index: number, useAnimation: boolean) {
    this.index = index;
    this.useAnimation = useAnimation;
  }
}

class OnChangeCall {
  public index: number;
  public id: string;

  constructor(index: number, id: string) {
    this.index = index;
    this.id = id;
  }
}

class MonitorValue {
  public now: Object;

  constructor(now: Object) {
    this.now = now;
  }
}

class MonitorEntry {
  public key: string;
  public monitorValue: MonitorValue;

  constructor(key: string, monitorValue: MonitorValue) {
    this.key = key;
    this.monitorValue = monitorValue;
  }
}

@Builder
function emptyBuilder() {
  Column() {
  }
}

const EMPTY_WRAPPED_BUILDER: WrappedBuilder<Any[]> = wrapBuilder(emptyBuilder);

class FakeMonitor implements IMonitor {
  public dirty: string[] = [];
  private entries: MonitorEntry[] = [];

  add(key: string, now: Object): FakeMonitor {
    this.dirty.push(key);
    this.entries.push(new MonitorEntry(key, new MonitorValue(now)));
    return this;
  }

  addEmpty(key: string): FakeMonitor {
    this.dirty.push(key);
    return this;
  }

  value<T extends ESObject>(key: string): IMonitorValue<T> | undefined {
    for (let i: number = 0; i < this.entries.length; i++) {
      if (this.entries[i].key === key) {
        return this.entries[i].monitorValue as Object as IMonitorValue<T>;
      }
    }
    return undefined;
  }
}

class FakeComponentEntry extends ComponentEntry<Any[]> {
  constructor() {
    super(EMPTY_WRAPPED_BUILDER, [] as Any[]);
  }
}

class FakeRenderUnit implements TabSwiperRenderUnit {
  public id: string;
  public tab: ComponentEntryProxy;
  public tabContent: ComponentEntryProxy;

  constructor(id: string) {
    this.id = id;
    this.tab = new FakeComponentEntry();
    this.tabContent = new FakeComponentEntry();
  }
}

class TabSwiperParams {
  public viewData: TabSwiperViewData;

  constructor(viewData: TabSwiperViewData) {
    this.viewData = viewData;
  }
}

@ComponentV2
struct TabSwiperTestHost {
  @Local viewData: TabSwiperViewData = [];

  build() {
    TabSwiper({
      viewData: this.viewData,
    });
  }
}

class TabSwiperTestHostRef extends TabSwiperTestHost {
  initialRender: () => void = (): void => {
  };
  aboutToBeDeleted?: () => void;
}

class TabSwiperHarness {
  public host: TabSwiperTestHostRef;
  public swiper: TabSwiper;
  public changeIndexCalls: ChangeIndexCall[] = [];
  public onChangeCalls: OnChangeCall[] = [];
  private layoutCalls: number = 0;

  constructor(viewData: TabSwiperViewData) {
    this.host = new TabSwiperTestHostRef();
    this.host.viewData = viewData;
    this.host.initialRender();
    const tabSwiperConstructor: ESObject = TabSwiper as Object as ESObject;
    this.swiper = new tabSwiperConstructor(undefined, new TabSwiperParams(viewData)) as Object as TabSwiper;
    const swiperObject: ESObject = this.swiper as ESObject;
    (swiperObject['swiperController'] as ESObject).changeIndex = (
      index: number,
      useAnimation: boolean
    ): void => {
      this.changeIndexCalls.push(new ChangeIndexCall(index, useAnimation));
    };
    this.swiper.onChange = (index: number, id: string): void => {
      this.onChangeCalls.push(new OnChangeCall(index, id));
    };
    (swiperObject['trackNodeController'] as ESObject).layout = (): void => {
      this.layoutCalls++;
    };
  }

  getLayoutCalls(): number {
    return this.layoutCalls;
  }
}

function createViewData(ids: string[]): TabSwiperViewData {
  const viewData: TabSwiperViewData = [];
  for (let i: number = 0; i < ids.length; i++) {
    viewData.push(new FakeRenderUnit(ids[i]));
  }
  return viewData;
}

export default function TabSwiperTest() {
  describe('TabSwiperTest', () => {
    let harness: TabSwiperHarness;

    beforeEach(() => {
      harness = new TabSwiperHarness(createViewData(['tab-a', 'tab-b', 'tab-c']));
    });

    afterEach(() => {
      harness.host.aboutToBeDeleted?.();
    });

    it('updates context viewData when viewData changes', 0, () => {
      const nextViewData: TabSwiperViewData = createViewData(['tab-x', 'tab-y']);
      const monitor: FakeMonitor = new FakeMonitor().add('viewData', nextViewData as Object);

      harness.swiper.onTabSwiperAttributeChange(monitor);

      const swiperObject: ESObject = harness.swiper as ESObject;
      const attr: ESObject = (swiperObject['ctx'] as ESObject)['attr'] as ESObject;
      const contextViewData: TabSwiperViewData = attr['viewData'] as TabSwiperViewData;
      expect(contextViewData.length).assertEqual(2);
      expect(contextViewData[0].id).assertEqual('tab-x');
      expect(contextViewData[1].id).assertEqual('tab-y');
    });

    it('keeps the current tab when viewData length changes but the current id still exists', 0, () => {
      const currentViewData: TabSwiperViewData = createViewData(['tab-a', 'tab-b', 'tab-c']);
      const monitor: FakeMonitor = new FakeMonitor();
      monitor.add('viewData', currentViewData as Object);
      monitor.add('viewData.length', currentViewData.length as Object);

      harness.swiper.onTabSwiperAttributeChange(monitor);

      const swiperObject: ESObject = harness.swiper as ESObject;
      expect(swiperObject['swiperIndex'] as number).assertEqual(0);
      expect(swiperObject['dataId'] as string).assertEqual('tab-a');
      expect(harness.changeIndexCalls.length).assertEqual(0);
      expect(harness.onChangeCalls.length).assertEqual(0);
    });

    it('falls back to the last item and notifies when the current id disappears after shrink', 0, () => {
      const nextViewData: TabSwiperViewData = createViewData(['tab-x', 'tab-y']);
      const swiperObject: ESObject = harness.swiper as ESObject;
      swiperObject['swiperIndex'] = 2;
      swiperObject['dataId'] = 'tab-c';
      const monitor: FakeMonitor = new FakeMonitor();
      monitor.add('viewData', nextViewData as Object);
      monitor.add('viewData.length', nextViewData.length as Object);

      harness.swiper.onTabSwiperAttributeChange(monitor);

      expect(swiperObject['swiperIndex'] as number).assertEqual(1);
      expect(swiperObject['dataId'] as string).assertEqual('tab-y');
      expect(harness.changeIndexCalls.length).assertEqual(1);
      expect(harness.changeIndexCalls[0].index).assertEqual(1);
      expect(harness.changeIndexCalls[0].useAnimation).assertEqual(false);
      expect(harness.onChangeCalls.length).assertEqual(1);
      expect(harness.onChangeCalls[0].index).assertEqual(1);
      expect(harness.onChangeCalls[0].id).assertEqual('tab-y');
    });

    it('updates layout-sensitive attributes and triggers layout for each matching key', 0, () => {
      const monitor: FakeMonitor = new FakeMonitor();
      monitor.add('tabSpacingBase', 24 as Object);
      monitor.add('tabLayoutMode', 'Center' as Object);
      monitor.add('tabsContainerMinHeight', 56 as Object);

      harness.swiper.onTabSwiperAttributeChange(monitor);

      const swiperObject: ESObject = harness.swiper as ESObject;
      const attr: ESObject = (swiperObject['ctx'] as ESObject)['attr'] as ESObject;
      expect(attr['tabSpacingBase'] as number).assertEqual(24);
      expect(attr['tabLayoutMode'] as TabLayoutMode).assertEqual('Center');
      expect(attr['tabsContainerMinHeight'] as number).assertEqual(56);
      expect(harness.getLayoutCalls()).assertEqual(3);
    });

    it('updates non-layout attributes and ignores dirty keys without monitor values', 0, () => {
      const monitor: FakeMonitor = new FakeMonitor();
      monitor.add('trackWidth', '88%' as Object);
      monitor.add('indicatorColor', Color.Red as Object);
      monitor.addEmpty('indicatorWidth');

      harness.swiper.onTabSwiperAttributeChange(monitor);

      const swiperObject: ESObject = harness.swiper as ESObject;
      const attr: ESObject = (swiperObject['ctx'] as ESObject)['attr'] as ESObject;
      expect(attr['trackWidth'] as string).assertEqual('88%');
      expect(attr['indicatorColor'] as ResourceColor).assertEqual(Color.Red);
      expect(attr['indicatorWidth'] as number).assertEqual(0);
      expect(harness.getLayoutCalls()).assertEqual(0);
    });
  });
}
