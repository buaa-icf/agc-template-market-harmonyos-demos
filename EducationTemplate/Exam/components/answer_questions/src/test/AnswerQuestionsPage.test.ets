/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { describe, it, expect } from '@ohos/hypium';
import { AnswerQuestionsComponent } from '../main/ets/components/AnswerQuestionsPage';
import { TopicItemType } from '../main/ets/viewModel/TopicPageModel';

class TestLocalStorage extends LocalStorage {
  onChange: () => void = () => {
  }
}

function createComponent(): AnswerQuestionsComponent {
  return new AnswerQuestionsComponent(undefined, new TestLocalStorage());
}

export default function answerQuestionsPageTest() {
  describe('AnswerQuestionsPageTest', () => {
    it('transTopicItemModel copies question data and resets runtime state', 0, () => {
      const component = createComponent();
      const rawTopic: TopicItemType = {
        type: '2',
        title: 'topic title',
        keyID: 'topic-001',
        ques: [
          {
            ansTitle: 'Option A',
            ans: 'A',
            ansID: 'ans-1',
            isSelect: true,
            isTrue: true,
            state: 2
          },
          {
            ansTitle: 'Option B',
            ans: 'B',
            ansID: 'ans-2',
            isSelect: false,
            isTrue: false,
            state: 1
          }
        ],
        rightQues: ['A'],
        parse: '解析内容',
        note: 'old note',
        selectQues: ['B'],
        isAnswer: true,
        jlStamp: 123456
      };

      const topic = component.transTopicItemModel(rawTopic);

      expect(topic.type).assertEqual('2');
      expect(topic.title).assertEqual('topic title');
      expect(topic.keyID).assertEqual('topic-001');
      expect(topic.parse).assertEqual('解析内容');
      expect(JSON.stringify(topic.rightQues)).assertEqual(JSON.stringify(['A']));
      expect(topic.isAnswer).assertFalse();
      expect(topic.note).assertEqual('');
      expect(topic.selectQues.length).assertEqual(0);
      expect(topic.ques.length).assertEqual(2);
      expect(topic.ques[0].ansTitle).assertEqual('Option A');
      expect(topic.ques[0].ans).assertEqual('A');
      expect(topic.ques[0].ansID).assertEqual('ans-1');
      expect(topic.ques[0].isSelect).assertFalse();
      expect(topic.ques[0].showState).assertEqual(0);
      expect(topic.ques[1].ansTitle).assertEqual('Option B');
      expect(topic.ques[1].ans).assertEqual('B');
      expect(topic.ques[1].ansID).assertEqual('ans-2');
      expect(topic.ques[1].isSelect).assertFalse();
      expect(topic.ques[1].showState).assertEqual(0);
    });

    it('transTopicItemModel keeps empty answer list empty', 0, () => {
      const component = createComponent();
      const rawTopic: TopicItemType = {
        type: '1',
        title: 'empty question list',
        keyID: 'topic-002',
        ques: [],
        rightQues: ['D'],
        parse: '',
        note: 'legacy note',
        selectQues: ['D'],
        isAnswer: true,
        jlStamp: 0
      };

      const topic = component.transTopicItemModel(rawTopic);

      expect(topic.ques.length).assertEqual(0);
      expect(topic.isAnswer).assertFalse();
      expect(topic.note).assertEqual('');
      expect(topic.selectQues.length).assertEqual(0);
      expect(JSON.stringify(topic.rightQues)).assertEqual(JSON.stringify(['D']));
    });
  });
}
