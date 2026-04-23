import { afterEach, describe, expect, it } from '@ohos/hypium'
import { MyPosition } from 'common'
import { PictureBeautification } from '../main/ets/pages/PictureBeautification'

class TestArea {
  width: number = 0
  height: number = 0
}

class TestTouch {
  x: number = 0
  y: number = 0
}

class TestNavPathStack {
}

class PictureBeautificationParams extends LocalStorage {
  pathStack: NavPathStack = new TestNavPathStack() as NavPathStack
}

interface ComponentLifecycleLike {
  aboutToBeDeleted?: () => void
}

const createdPages: PictureBeautification[] = []

function buildRect(x: number, y: number, width: number, height: number): MyPosition {
  return {
    x,
    y,
    width,
    height
  }
}

function buildArea(width: number, height: number): Area {
  const area = new TestArea()
  area.width = width
  area.height = height
  return area as Area
}

function buildTouch(x: number, y: number): TouchObject {
  const touch = new TestTouch()
  touch.x = x
  touch.y = y
  return touch as TouchObject
}

function createPage(): PictureBeautification {
  const page = new PictureBeautification(undefined, new PictureBeautificationParams())
  createdPages.push(page)
  page.cropRatio = 0
  page.imageArea = buildRect(10, 20, 120, 90)
  page.clipRect = buildRect(30, 40, 40, 30)
  page.clipRectMaxH = 120
  page.clipRectMaxW = 80
  return page
}

function chooseFreeAction(page: PictureBeautification, x: number, y: number, width: number, height: number) {
  page.cropRatio = 0
  page.isMove(buildArea(width, height), buildTouch(x, y))
}

function chooseRatioAction(page: PictureBeautification, x: number, y: number, width: number, height: number) {
  page.cropRatio = 1
  page.isMove(buildArea(width, height), buildTouch(x, y))
}

export default function PictureBeautificationTest() {
  describe('PictureBeautificationTest', () => {
    afterEach(() => {
      while (createdPages.length > 0) {
        const page = createdPages.pop() as PictureBeautification
        const lifecycle = page as Object as ComponentLifecycleLike
        lifecycle.aboutToBeDeleted?.()
      }
    })

    it('detects corner edge and move operations in free crop mode', 0, () => {
      const page = createPage()

      chooseFreeAction(page, 5, 5, 100, 80)
      page.moveClipCanvasFreeType(-10, -10)
      expect(page.clipRect.x).assertEqual(20)
      expect(page.clipRect.y).assertEqual(30)
      expect(page.clipRect.width).assertEqual(50)
      expect(page.clipRect.height).assertEqual(40)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 50, 5, 100, 80)
      page.moveClipCanvasFreeType(0, -10)
      expect(page.clipRect.y).assertEqual(30)
      expect(page.clipRect.height).assertEqual(40)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 5, 40, 100, 80)
      page.moveClipCanvasFreeType(-10, 0)
      expect(page.clipRect.x).assertEqual(20)
      expect(page.clipRect.width).assertEqual(50)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 50, 40, 100, 80)
      page.moveClipCanvasFreeType(10, 5)
      expect(page.clipRect.x).assertEqual(40)
      expect(page.clipRect.y).assertEqual(45)
    })

    it('detects the diagonal handles in fixed ratio crop mode', 0, () => {
      const page = createPage()
      page.imageArea = buildRect(10, 20, 120, 120)
      page.clipRect = buildRect(30, 40, 40, 40)
      page.clipRectMaxW = 100
      page.clipRectMaxH = 100

      chooseRatioAction(page, 10, 10, 100, 80)
      page.moveClipCanvasRatioType(-10, -20)
      expect(page.clipRect.x).assertEqual(10)
      expect(page.clipRect.y).assertEqual(20)
      expect(page.clipRect.width).assertEqual(60)
      expect(page.clipRect.height).assertEqual(60)

      page.clipRect = buildRect(30, 40, 40, 40)
      chooseRatioAction(page, 90, 10, 100, 80)
      page.moveClipCanvasRatioType(20, -10)
      expect(page.clipRect.y).assertEqual(30)
      expect(page.clipRect.width).assertEqual(50)
      expect(page.clipRect.height).assertEqual(50)

      page.clipRect = buildRect(30, 40, 40, 40)
      chooseRatioAction(page, 90, 75, 100, 80)
      page.moveClipCanvasRatioType(10, 20)
      expect(page.clipRect.width).assertEqual(60)
      expect(page.clipRect.height).assertEqual(60)

      page.clipRect = buildRect(30, 40, 40, 40)
      chooseRatioAction(page, 45, 35, 100, 80)
      page.moveClipCanvasRatioType(-50, -50)
      expect(page.clipRect.x).assertEqual(10)
      expect(page.clipRect.y).assertEqual(20)
    })

    it('moves the free crop rect and clamps it inside the image area', 0, () => {
      const page = createPage()

      chooseFreeAction(page, 50, 40, 100, 80)
      page.moveClipCanvasFreeType(-60, -50)
      expect(page.clipRect.x).assertEqual(10)
      expect(page.clipRect.y).assertEqual(20)

      page.moveClipCanvasFreeType(200, 200)
      expect(page.clipRect.x).assertEqual(90)
      expect(page.clipRect.y).assertEqual(80)
      expect(page.clipRect.width).assertEqual(40)
      expect(page.clipRect.height).assertEqual(30)
    })

    it('resizes the free crop rect from the top left handle and keeps it within bounds', 0, () => {
      const page = createPage()

      chooseFreeAction(page, 5, 5, 100, 80)
      page.moveClipCanvasFreeType(-40, -40)

      expect(page.clipRect.x).assertEqual(10)
      expect(page.clipRect.y).assertEqual(20)
      expect(page.clipRect.width).assertEqual(80)
      expect(page.clipRect.height).assertEqual(70)
    })

    it('resizes the free crop rect from other handles', 0, () => {
      const page = createPage()

      chooseFreeAction(page, 95, 5, 100, 80)
      page.moveClipCanvasFreeType(10, -10)
      expect(page.clipRect.x).assertEqual(30)
      expect(page.clipRect.y).assertEqual(30)
      expect(page.clipRect.width).assertEqual(50)
      expect(page.clipRect.height).assertEqual(40)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 5, 75, 100, 80)
      page.moveClipCanvasFreeType(-10, 10)
      expect(page.clipRect.x).assertEqual(20)
      expect(page.clipRect.y).assertEqual(40)
      expect(page.clipRect.width).assertEqual(50)
      expect(page.clipRect.height).assertEqual(40)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 95, 75, 100, 80)
      page.moveClipCanvasFreeType(10, 10)
      expect(page.clipRect.width).assertEqual(50)
      expect(page.clipRect.height).assertEqual(40)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 50, 5, 100, 80)
      page.moveClipCanvasFreeType(0, -10)
      expect(page.clipRect.y).assertEqual(30)
      expect(page.clipRect.height).assertEqual(40)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 50, 75, 100, 80)
      page.moveClipCanvasFreeType(0, 10)
      expect(page.clipRect.height).assertEqual(40)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 5, 40, 100, 80)
      page.moveClipCanvasFreeType(-10, 0)
      expect(page.clipRect.x).assertEqual(20)
      expect(page.clipRect.width).assertEqual(50)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 95, 40, 100, 80)
      page.moveClipCanvasFreeType(10, 0)
      expect(page.clipRect.width).assertEqual(50)
    })

    it('keeps the fixed ratio crop rect proportional and respects max width and height', 0, () => {
      const page = createPage()

      page.cropRatio = 2
      page.imageArea = buildRect(10, 20, 200, 220)
      page.clipRect = buildRect(30, 40, 40, 80)
      page.clipRectMaxW = 70
      page.clipRectMaxH = 120
      chooseRatioAction(page, 90, 75, 100, 80)

      page.moveClipCanvasRatioType(50, 30)

      expect(page.clipRect.x).assertEqual(30)
      expect(page.clipRect.y).assertEqual(40)
      expect(page.clipRect.width).assertEqual(70)
      expect(page.clipRect.height).assertEqual(120)
    })

    it('moves and resizes the fixed ratio crop rect with multiple handles', 0, () => {
      const page = createPage()
      page.cropRatio = 1
      page.imageArea = buildRect(10, 20, 120, 120)
      page.clipRect = buildRect(30, 40, 40, 40)
      page.clipRectMaxW = 100
      page.clipRectMaxH = 100

      chooseRatioAction(page, 45, 35, 100, 80)
      page.moveClipCanvasRatioType(-50, -50)
      expect(page.clipRect.x).assertEqual(10)
      expect(page.clipRect.y).assertEqual(20)

      page.clipRect = buildRect(30, 40, 40, 40)
      chooseRatioAction(page, 10, 10, 100, 80)
      page.moveClipCanvasRatioType(-10, -20)
      expect(page.clipRect.x).assertEqual(10)
      expect(page.clipRect.y).assertEqual(20)
      expect(page.clipRect.width).assertEqual(60)
      expect(page.clipRect.height).assertEqual(60)

      page.clipRect = buildRect(30, 40, 40, 40)
      chooseRatioAction(page, 90, 10, 100, 80)
      page.moveClipCanvasRatioType(20, -10)
      expect(page.clipRect.y).assertEqual(30)
      expect(page.clipRect.width).assertEqual(50)
      expect(page.clipRect.height).assertEqual(50)

      page.clipRect = buildRect(30, 40, 40, 40)
      chooseRatioAction(page, 10, 75, 100, 80)
      page.moveClipCanvasRatioType(-20, 10)
      expect(page.clipRect.x).assertEqual(20)
      expect(page.clipRect.width).assertEqual(50)
      expect(page.clipRect.height).assertEqual(50)
    })

    it('classifies free crop edge operations through isMove and updates the rectangle accordingly', 0, () => {
      const page = createPage()

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 50, 75, 100, 80)
      page.moveClipCanvasFreeType(0, 8)
      expect(page.clipRect.height).assertEqual(38)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 95, 40, 100, 80)
      page.moveClipCanvasFreeType(9, 0)
      expect(page.clipRect.width).assertEqual(49)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 50, 40, 100, 80)
      page.moveClipCanvasFreeType(5, -6)
      expect(page.clipRect.x).assertEqual(35)
      expect(page.clipRect.y).assertEqual(34)
      expect(page.clipRect.width).assertEqual(40)
      expect(page.clipRect.height).assertEqual(30)
    })

    it('keeps fixed ratio move action within image bounds', 0, () => {
      const page = createPage()
      page.cropRatio = 1
      page.imageArea = buildRect(10, 20, 120, 120)
      page.clipRect = buildRect(30, 40, 40, 40)
      page.clipRectMaxW = 100
      page.clipRectMaxH = 100

      chooseRatioAction(page, 45, 35, 100, 80)
      page.moveClipCanvasRatioType(-100, -100)
      expect(page.clipRect.x).assertEqual(10)
      expect(page.clipRect.y).assertEqual(20)
      expect(page.clipRect.width).assertEqual(40)
      expect(page.clipRect.height).assertEqual(40)

      page.moveClipCanvasRatioType(500, 500)
      expect(page.clipRect.x).assertEqual(90)
      expect(page.clipRect.y).assertEqual(100)
      expect(page.clipRect.width).assertEqual(40)
      expect(page.clipRect.height).assertEqual(40)
    })

    it('handles top-right and top-left ratio resize branches for opposite drag directions', 0, () => {
      const page = createPage()
      page.cropRatio = 1
      page.imageArea = buildRect(10, 20, 200, 200)
      page.clipRect = buildRect(50, 60, 60, 60)
      page.clipRectMaxW = 180
      page.clipRectMaxH = 180

      chooseRatioAction(page, 90, 5, 100, 80)
      page.moveClipCanvasRatioType(-20, 10)
      expect(page.clipRect.y).assertEqual(70)
      expect(page.clipRect.width).assertEqual(50)
      expect(page.clipRect.height).assertEqual(50)

      page.clipRect = buildRect(50, 60, 60, 60)
      chooseRatioAction(page, 10, 10, 100, 80)
      page.moveClipCanvasRatioType(10, 25)
      expect(page.clipRect.x).assertEqual(60)
      expect(page.clipRect.y).assertEqual(70)
      expect(page.clipRect.width).assertEqual(50)
      expect(page.clipRect.height).assertEqual(50)
    })

    it('covers remaining free mode edge selectors in isMove', 0, () => {
      const page = createPage()
      page.cropRatio = 0

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 50, 5, 100, 80)
      page.moveClipCanvasFreeType(0, -8)
      expect(page.clipRect.y).assertEqual(32)
      expect(page.clipRect.height).assertEqual(38)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 5, 40, 100, 80)
      page.moveClipCanvasFreeType(-6, 0)
      expect(page.clipRect.x).assertEqual(24)
      expect(page.clipRect.width).assertEqual(46)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 95, 75, 100, 80)
      page.moveClipCanvasFreeType(8, 6)
      expect(page.clipRect.width).assertEqual(48)
      expect(page.clipRect.height).assertEqual(36)
    })

    it('covers ratio mode bottom-left selector and max clamp', 0, () => {
      const page = createPage()
      page.cropRatio = 1
      page.imageArea = buildRect(10, 20, 120, 120)
      page.clipRect = buildRect(30, 40, 40, 40)
      page.clipRectMaxW = 50
      page.clipRectMaxH = 50

      chooseRatioAction(page, 10, 75, 100, 80)
      page.moveClipCanvasRatioType(-20, 10)
      expect(page.clipRect.x).assertEqual(20)
      expect(page.clipRect.width).assertEqual(50)
      expect(page.clipRect.height).assertEqual(50)
    })

    it('classifies free mode threshold points as move and supports edge actions around threshold', 0, () => {
      const page = createPage()
      page.cropRatio = 0

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 20, 20, 100, 80)
      page.moveClipCanvasFreeType(3, 4)
      expect(page.clipRect.x).assertEqual(33)
      expect(page.clipRect.y).assertEqual(44)
      expect(page.clipRect.width).assertEqual(40)
      expect(page.clipRect.height).assertEqual(30)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 21, 19, 100, 80)
      page.moveClipCanvasFreeType(0, -7)
      expect(page.clipRect.y).assertEqual(33)
      expect(page.clipRect.height).assertEqual(37)

      page.clipRect = buildRect(30, 40, 40, 30)
      chooseFreeAction(page, 19, 21, 100, 80)
      page.moveClipCanvasFreeType(-7, 0)
      expect(page.clipRect.x).assertEqual(23)
      expect(page.clipRect.width).assertEqual(47)
    })

    it('handles ratio top-right and bottom-left negative drag branches and keeps ratio', 0, () => {
      const page = createPage()
      page.cropRatio = 1
      page.imageArea = buildRect(10, 20, 200, 200)
      page.clipRectMaxW = 180
      page.clipRectMaxH = 180

      page.clipRect = buildRect(60, 70, 50, 50)
      chooseRatioAction(page, 90, 10, 100, 80)
      page.moveClipCanvasRatioType(-20, 5)
      expect(page.clipRect.x).assertEqual(60)
      expect(page.clipRect.y).assertEqual(75)
      expect(page.clipRect.width).assertEqual(45)
      expect(page.clipRect.height).assertEqual(45)

      page.clipRect = buildRect(60, 70, 50, 50)
      chooseRatioAction(page, 10, 75, 100, 80)
      page.moveClipCanvasRatioType(20, -5)
      expect(page.clipRect.x).assertEqual(65)
      expect(page.clipRect.y).assertEqual(70)
      expect(page.clipRect.width).assertEqual(45)
      expect(page.clipRect.height).assertEqual(45)
    })

    it('combines ratio resizing with image bounds and max size clamp', 0, () => {
      const page = createPage()
      page.cropRatio = 1
      page.imageArea = buildRect(10, 20, 100, 100)
      page.clipRect = buildRect(20, 30, 60, 60)
      page.clipRectMaxW = 55
      page.clipRectMaxH = 55

      chooseRatioAction(page, 90, 75, 100, 80)
      page.moveClipCanvasRatioType(120, 10)
      expect(page.clipRect.x).assertEqual(20)
      expect(page.clipRect.y).assertEqual(30)
      expect(page.clipRect.width).assertEqual(55)
      expect(page.clipRect.height).assertEqual(55)
    })

    it('covers title mapping, sticker deletion and pushPixelMap history trimming', 0, () => {
      const page = createPage()

      page.barIndex = 0
      expect(page.getTitle()).assertEqual('一键美颜')
      page.barIndex = 1
      expect(page.getTitle()).assertEqual('裁剪旋转')
      page.barIndex = 2
      expect(page.getTitle()).assertEqual('添加文字')
      page.barIndex = 3
      expect(page.getTitle()).assertEqual('添加滤镜')
      page.barIndex = 4
      expect(page.getTitle()).assertEqual('添加贴纸')
      page.barIndex = 99
      expect(page.getTitle()).assertEqual('美化图片')

      page.stickerList = [
        { id: 'a', positionX: 0, positionY: 0, img: '' },
        { id: 'b', positionX: 1, positionY: 1, img: '' }
      ]
      page.deleteSticker('a')
      expect(page.stickerList.length).assertEqual(1)
      expect(page.stickerList[0].id).assertEqual('b')

      const pixelA = {} as PixelMap
      const pixelB = {} as PixelMap
      const pixelC = {} as PixelMap
      page.pixelMapList = [pixelA, pixelB]
      page.currentPixelMapIndex = 0
      page.pushPixelMap(pixelC)
      expect(page.pixelMapList.length).assertEqual(1)
      expect(page.pixelMapList[0] !== undefined).assertTrue()
      expect(page.currentPixelMap !== undefined).assertTrue()
      expect(page.totalPixelMapCount).assertEqual(1)
      expect(page.currentPixelMapIndex).assertEqual(0)
    })
  })
}
