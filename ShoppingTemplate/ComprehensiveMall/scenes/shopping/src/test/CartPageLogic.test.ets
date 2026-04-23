import { describe, beforeAll, beforeEach, afterEach, it, expect, MockKit, when } from '@ohos/hypium';
import { iData, CartCardDto, CartDto } from 'lib_foundation';
import { client } from 'lib_network';
import { CartPageLogic, CartStatus } from '../main/ets/logic/CartPageLogic';

function buildCartCardDto(skuCode: string, count: number = 1, price: number = 100): CartCardDto {
  return {
    productId: `p-${skuCode}`,
    skuCode: skuCode,
    skuDesc: `desc-${skuCode}`,
    stock: 10,
    count: count,
    banner: `http://img.example.com/${skuCode}.png`,
    title: `title-${skuCode}`,
    serviceDesc: `svc-${skuCode}`,
    price: price,
    isSelected: false
  };
}

function buildCartDto(version: string, total: number, cards: CartCardDto[]): CartDto {
  return { version, total, cards };
}

function flush(ticks: number = 8): Promise<void> {
  let p: Promise<void> = Promise.resolve();
  for (let i = 0; i < ticks; i++) {
    p = p.then(() => undefined);
  }
  return p;
}

export default function cartPageLogicTest() {
  describe('CartPageLogicTest', () => {

    let mockKit: MockKit;
    let originalIsLogin: boolean = false;
    let originalCartVersion: string = '';

    beforeAll(() => {
      const warmup: MockKit = new MockKit();
      warmup.mockFunc(client.cart, client.cart.getCartData);
      warmup.mockFunc(client.cart, client.cart.deleteSkuFromCart);
    });

    beforeEach(() => {
      mockKit = new MockKit();
      originalIsLogin = iData.global.isLogin;
      originalCartVersion = iData.global.cartVersion;
      iData.global.isLogin = true;
      iData.global.cartVersion = 'stable-version';
    });

    afterEach(() => {
      mockKit.clearAll();
      iData.global.isLogin = originalIsLogin;
      iData.global.cartVersion = originalCartVersion;
    });

    it('update_buildsCartCardVMsFromCartDto', 0, async () => {
      const dto: CartDto = buildCartDto('v-new', 3, [
        buildCartCardDto('sku-a'),
        buildCartCardDto('sku-b', 2, 50)
      ]);
      const cartMock = mockKit.mockFunc(client.cart, client.cart.getCartData);
      when(cartMock)().afterReturn(Promise.resolve(dto));

      const logic: CartPageLogic = new CartPageLogic();
      logic.refresh(true);
      await flush(8);

      expect(logic.cartCards.length).assertEqual(2);
      expect(logic.cartCards[0].skuCode).assertEqual('sku-a');
      expect(logic.cartCards[0].productId).assertEqual('p-sku-a');
      expect(logic.cartCards[0].title).assertEqual('title-sku-a');
      expect(logic.cartCards[0].isSelected).assertFalse();
      expect(logic.cartCards[1].skuCode).assertEqual('sku-b');
      expect(logic.cartCards[1].count).assertEqual(2);
      expect(logic.cartCards[1].price).assertEqual(50);
      expect(logic.status).assertEqual(CartStatus.NOT_EMPTY);
      expect(iData.global.cartVersion).assertEqual('v-new');
      expect(iData.global.cartTotal).assertEqual(3);
    });

    it('update_marksSelectedSkuWhenCheckBoxChangedBefore', 0, async () => {
      const dto: CartDto = buildCartDto('v-select', 1, [
        buildCartCardDto('sku-x'),
        buildCartCardDto('sku-y')
      ]);
      const cartMock = mockKit.mockFunc(client.cart, client.cart.getCartData);
      when(cartMock)().afterReturn(Promise.resolve(dto));

      const logic: CartPageLogic = new CartPageLogic();
      logic.onCheckBoxChange(['sku-y']);
      logic.refresh(true);
      await flush(8);

      expect(logic.cartCards.length).assertEqual(2);
      expect(logic.cartCards[0].isSelected).assertFalse();
      expect(logic.cartCards[1].isSelected).assertTrue();
      expect(logic.totalPrice).assertEqual(100);
    });

    it('update_setsEmptyStatusWhenNoCards', 0, async () => {
      const dto: CartDto = buildCartDto('v-empty', 0, []);
      const cartMock = mockKit.mockFunc(client.cart, client.cart.getCartData);
      when(cartMock)().afterReturn(Promise.resolve(dto));

      const logic: CartPageLogic = new CartPageLogic();
      logic.refresh(true);
      await flush(8);

      expect(logic.cartCards.length).assertEqual(0);
      expect(logic.status).assertEqual(CartStatus.EMPTY);
      expect(logic.isEditingMode).assertFalse();
    });

    it('onSkuDelete_buildsCartCardVMsFromResponse', 0, async () => {
      const initialDto: CartDto = buildCartDto('v-init', 2, [
        buildCartCardDto('sku-a'),
        buildCartCardDto('sku-b')
      ]);
      const cartMock = mockKit.mockFunc(client.cart, client.cart.getCartData);
      when(cartMock)().afterReturn(Promise.resolve(initialDto));

      const afterDeleteDto: CartDto = buildCartDto('v-after', 1, [
        buildCartCardDto('sku-b', 3, 20)
      ]);
      const deleteMock = mockKit.mockFunc(client.cart, client.cart.deleteSkuFromCart);
      when(deleteMock)(['sku-a']).afterReturn(Promise.resolve(afterDeleteDto));

      const logic: CartPageLogic = new CartPageLogic();
      logic.refresh(true);
      await flush(8);

      logic.onSkuDelete(['sku-a']);
      await flush(8);

      expect(logic.cartCards.length).assertEqual(1);
      expect(logic.cartCards[0].skuCode).assertEqual('sku-b');
      expect(logic.cartCards[0].count).assertEqual(3);
      expect(logic.cartCards[0].price).assertEqual(20);
      expect(logic.status).assertEqual(CartStatus.NOT_EMPTY);
      expect(iData.global.cartVersion).assertEqual('v-after');
      expect(iData.global.cartTotal).assertEqual(1);
    });

    it('onSkuDelete_marksIsSelectedWhenSkuStillSelected', 0, async () => {
      const initialDto: CartDto = buildCartDto('v-init', 2, [
        buildCartCardDto('sku-a'),
        buildCartCardDto('sku-b')
      ]);
      const cartMock = mockKit.mockFunc(client.cart, client.cart.getCartData);
      when(cartMock)().afterReturn(Promise.resolve(initialDto));

      const afterDeleteDto: CartDto = buildCartDto('v-after', 1, [
        buildCartCardDto('sku-b')
      ]);
      const deleteMock = mockKit.mockFunc(client.cart, client.cart.deleteSkuFromCart);
      when(deleteMock)(['sku-a']).afterReturn(Promise.resolve(afterDeleteDto));

      const logic: CartPageLogic = new CartPageLogic();
      logic.refresh(true);
      await flush(8);

      logic.onCheckBoxChange(['sku-b']);
      logic.onSkuDelete(['sku-a']);
      await flush(8);

      expect(logic.cartCards.length).assertEqual(1);
      expect(logic.cartCards[0].isSelected).assertTrue();
    });

    it('onSkuDelete_setsEmptyStatusAndExitsEditMode', 0, async () => {
      const initialDto: CartDto = buildCartDto('v-init', 1, [
        buildCartCardDto('sku-a')
      ]);
      const cartMock = mockKit.mockFunc(client.cart, client.cart.getCartData);
      when(cartMock)().afterReturn(Promise.resolve(initialDto));

      const afterDeleteDto: CartDto = buildCartDto('v-empty', 0, []);
      const deleteMock = mockKit.mockFunc(client.cart, client.cart.deleteSkuFromCart);
      when(deleteMock)(['sku-a']).afterReturn(Promise.resolve(afterDeleteDto));

      const logic: CartPageLogic = new CartPageLogic();
      logic.refresh(true);
      await flush(8);

      logic.isEditingMode = true;
      logic.onSkuDelete(['sku-a']);
      await flush(8);

      expect(logic.cartCards.length).assertEqual(0);
      expect(logic.status).assertEqual(CartStatus.EMPTY);
      expect(logic.isEditingMode).assertFalse();
    });

    it('onSkuDelete_deletesAllSelectedWhenSkuCodesEmpty', 0, async () => {
      const initialDto: CartDto = buildCartDto('v-init', 2, [
        buildCartCardDto('sku-a'),
        buildCartCardDto('sku-b')
      ]);
      const cartMock = mockKit.mockFunc(client.cart, client.cart.getCartData);
      when(cartMock)().afterReturn(Promise.resolve(initialDto));

      const afterDeleteDto: CartDto = buildCartDto('v-after', 1, [
        buildCartCardDto('sku-b')
      ]);
      let capturedSkuCodes: string[] = [];
      const deleteMock = mockKit.mockFunc(client.cart, client.cart.deleteSkuFromCart);
      when(deleteMock)(['sku-a']).afterAction((skuCodes: string[]): Promise<CartDto> => {
        capturedSkuCodes = skuCodes;
        return Promise.resolve(afterDeleteDto);
      });

      const logic: CartPageLogic = new CartPageLogic();
      logic.refresh(true);
      await flush(8);

      logic.onCheckBoxChange(['sku-a']);
      logic.onSkuDelete([]);
      await flush(8);

      expect(capturedSkuCodes.length).assertEqual(1);
      expect(capturedSkuCodes[0]).assertEqual('sku-a');
      expect(logic.cartCards.length).assertEqual(1);
      expect(logic.cartCards[0].skuCode).assertEqual('sku-b');
    });
  });
}
