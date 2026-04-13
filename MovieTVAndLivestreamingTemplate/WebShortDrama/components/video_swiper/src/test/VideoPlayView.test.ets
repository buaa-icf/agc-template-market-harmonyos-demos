import { afterEach, describe, expect, it } from '@ohos/hypium'
import { audio } from '@kit.AudioKit'
import { media } from '@kit.MediaKit'

import { PlayController } from '../main/ets/controller/PlayController'
import { PlaySession } from '../main/ets/controller/PlaySession'
import { VideoPlayData } from '../main/ets/datasource/VideoPlayDataSource'
import { VideoPlayView } from '../main/ets/view/VideoPlayView'

interface VideoPlayViewPrivateFields {
  surfaceID: string
}

interface ComponentLifecycleLike {
  aboutToBeDeleted?: () => void
}

class SeekCallRecord {
  time: number
  mode?: media.SeekMode

  constructor(time: number, mode?: media.SeekMode) {
    this.time = time
    this.mode = mode
  }
}

class TestVideoData implements VideoPlayData {
  private readonly playTime: number

  constructor(playTime: number = 0) {
    this.playTime = playTime
  }

  getUrl(): string | media.AVFileDescriptor {
    return 'file://video.mp4'
  }

  getPlayTime(): number {
    return this.playTime
  }

  getPic(): ResourceStr {
    return ''
  }
}

class VideoPlayViewConfig {
  playTime: number = 0
  firstFlag: boolean = false
  curIndex: number = 0
  isPageShow: boolean = false
  index: number = 0
  firstLoaded?: () => void
}

class VideoPlayViewParams extends LocalStorage {
  firstFlag: boolean = false
  firstLoaded: () => void = () => {
  }
  curIndex: number = 0
  isPageShow: boolean = false
  contentBuilder: WrappedBuilder<[VideoPlayData, PlayController, PlaySession]> | undefined = undefined
  previewUri: ResourceStr = ''
  videoData: VideoPlayData
  playController: PlayController
  index: number = 0

  constructor(videoData: VideoPlayData, playController: PlayController, config: VideoPlayViewConfig) {
    super()
    this.videoData = videoData
    this.playController = playController
    this.firstFlag = config.firstFlag
    this.curIndex = config.curIndex
    this.isPageShow = config.isPageShow
    this.index = config.index
    if (config.firstLoaded) {
      this.firstLoaded = config.firstLoaded
    }
  }
}

class FakeSwiperController {
  readonly changeIndexCalls: Array<number> = []

  changeIndex(index: number): void {
    this.changeIndexCalls.push(index)
  }
}

class FakeAVPlayer {
  surfaceId: string = ''
  audioInterruptMode?: audio.InterruptMode
  prepareCallCount: number = 0
  playCallCount: number = 0
  resetCallCount: number = 0
  seekCalls: Array<SeekCallRecord> = []
  private stateChangeListener?: (state: string) => Promise<void> | void

  on(event: string, callback: (state: string) => Promise<void> | void): void {
    if (event === 'stateChange') {
      this.stateChangeListener = callback
    }
  }

  prepare(): void {
    this.prepareCallCount += 1
  }

  play(): void {
    this.playCallCount += 1
  }

  seek(time: number, mode?: media.SeekMode): void {
    this.seekCalls.push(new SeekCallRecord(time, mode))
  }

  reset(): void {
    this.resetCallCount += 1
  }

  async emitStateChange(state: string): Promise<void> {
    if (!this.stateChangeListener) {
      throw new Error('stateChange listener was not registered')
    }
    await this.stateChangeListener(state)
  }
}

const createdComponents: Array<VideoPlayView> = []

function createView(config?: VideoPlayViewConfig): VideoPlayView {
  const resolvedConfig = config ?? new VideoPlayViewConfig()
  const playController = new PlayController()
  const params = new VideoPlayViewParams(new TestVideoData(resolvedConfig.playTime), playController, resolvedConfig)
  const component = new VideoPlayView(undefined, params as Object as LocalStorage)
  createdComponents.push(component)
  return component
}

function registerStateCollector(component: VideoPlayView): Array<string> {
  const states: Array<string> = []
  component.playerSession.onStateChange('stateChange', (state: string) => {
    states.push(state)
  })
  return states
}

function setSurfaceId(component: VideoPlayView, surfaceId: string): void {
  const privateFields = component as Object as VideoPlayViewPrivateFields
  privateFields.surfaceID = surfaceId
}

function disposeComponent(component: VideoPlayView): void {
  const lifecycle = component as Object as ComponentLifecycleLike
  lifecycle.aboutToBeDeleted?.()
}

function stringifyStates(states: Array<string>): string {
  return states.join(',')
}

export default function VideoPlayViewTest() {
  describe('VideoPlayViewTest', () => {
    afterEach(() => {
      while (createdComponents.length > 0) {
        const component = createdComponents.pop()
        if (component) {
          disposeComponent(component)
        }
      }
    })

    it('initializes the player surface and prepares playback when entering initialized state', 0, async () => {
      const component = createView()
      const fakePlayer = new FakeAVPlayer()
      const callbackStates = registerStateCollector(component)
      setSurfaceId(component, 'surface-id-1')

      component.setAVPlayerStateListen(fakePlayer as Object as media.AVPlayer)
      await fakePlayer.emitStateChange('initialized')

      expect(fakePlayer.surfaceId).assertEqual('surface-id-1')
      expect(fakePlayer.prepareCallCount).assertEqual(1)
      expect(stringifyStates(callbackStates)).assertEqual('initialized')
    })

    it('marks the player prepared, restores progress, and auto plays the first visible item', 0, async () => {
      let firstLoadedCount = 0
      const config = new VideoPlayViewConfig()
      config.playTime = 3200
      config.firstFlag = true
      config.curIndex = 2
      config.isPageShow = true
      config.index = 2
      config.firstLoaded = () => {
        firstLoadedCount += 1
      }
      const component = createView(config)
      const fakePlayer = new FakeAVPlayer()
      const callbackStates = registerStateCollector(component)

      component.setAVPlayerStateListen(fakePlayer as Object as media.AVPlayer)
      await fakePlayer.emitStateChange('prepared')

      expect(component.preparedFlag).assertTrue()
      expect(fakePlayer.audioInterruptMode).assertEqual(audio.InterruptMode.INDEPENDENT_MODE)
      expect(fakePlayer.seekCalls.length).assertEqual(1)
      expect(fakePlayer.seekCalls[0].time).assertEqual(3200)
      expect(fakePlayer.playCallCount).assertEqual(1)
      expect(firstLoadedCount).assertEqual(1)
      expect(stringifyStates(callbackStates)).assertEqual('prepared')
    })

    it('toggles the playing flag for playing paused and stopped states', 0, async () => {
      const component = createView()
      const fakePlayer = new FakeAVPlayer()
      const callbackStates = registerStateCollector(component)
      component.isPlaying = false

      component.setAVPlayerStateListen(fakePlayer as Object as media.AVPlayer)
      await fakePlayer.emitStateChange('playing')
      expect(component.isPlaying).assertTrue()

      await fakePlayer.emitStateChange('paused')
      expect(component.isPlaying).assertFalse()

      component.isPlaying = true
      await fakePlayer.emitStateChange('stopped')
      expect(component.isPlaying).assertFalse()

      expect(stringifyStates(callbackStates)).assertEqual('playing,paused,stopped')
    })

    it('stops playback rewinds the stream and advances when autoplay is enabled after completion', 0, async () => {
      const config = new VideoPlayViewConfig()
      config.curIndex = 4
      const component = createView(config)
      const fakePlayer = new FakeAVPlayer()
      const fakeSwiperController = new FakeSwiperController()
      const callbackStates = registerStateCollector(component)
      component.isPlaying = true
      component.playController.autoPlay = true
      component.playController.setSwiperController(fakeSwiperController as Object as SwiperController)

      component.setAVPlayerStateListen(fakePlayer as Object as media.AVPlayer)
      await fakePlayer.emitStateChange('completed')

      expect(component.isPlaying).assertFalse()
      expect(fakeSwiperController.changeIndexCalls.length).assertEqual(1)
      expect(fakeSwiperController.changeIndexCalls[0]).assertEqual(5)
      expect(fakePlayer.seekCalls.length).assertEqual(1)
      expect(fakePlayer.seekCalls[0].time).assertEqual(0)
      expect(fakePlayer.seekCalls[0].mode).assertEqual(media.SeekMode.SEEK_CLOSEST)
      expect(stringifyStates(callbackStates)).assertEqual('completed')
    })

    it('dispatches passive states to listeners and resets the player on error', 0, async () => {
      const component = createView()
      const fakePlayer = new FakeAVPlayer()
      const callbackStates = registerStateCollector(component)

      component.setAVPlayerStateListen(fakePlayer as Object as media.AVPlayer)
      await fakePlayer.emitStateChange('idle')
      await fakePlayer.emitStateChange('released')
      await fakePlayer.emitStateChange('unexpected')
      await fakePlayer.emitStateChange('error')

      expect(fakePlayer.resetCallCount).assertEqual(1)
      expect(stringifyStates(callbackStates)).assertEqual('idle,released,unexpected,error')
    })
  })
}
