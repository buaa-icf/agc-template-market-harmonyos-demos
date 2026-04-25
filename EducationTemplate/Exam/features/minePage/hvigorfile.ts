import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorNode, HvigorPlugin } from 'hvigor';
import fs from 'node:fs';
import path from 'node:path';

const copyOhosTestIndexPlugin: HvigorPlugin = {
  pluginId: 'copyOhosTestIndexPlugin',
  apply(node: HvigorNode): void {
    const copyIndex = (): void => {
      const modulePath: string = node.getNodeDir().filePath;
      const sourceIndex: string = path.join(modulePath, 'src', 'ohosTest', 'ets', 'testability', 'pages', 'Index.ets');
      const targetIndex: string = path.join(
        modulePath,
        'build',
        'default',
        'intermediates',
        'src',
        'ohosTest',
        'ets',
        'testability',
        'pages',
        'Index.ets'
      );
      if (!fs.existsSync(sourceIndex)) {
        return;
      }
      fs.mkdirSync(path.dirname(targetIndex), { recursive: true });
      const sourceContent: string = fs.readFileSync(sourceIndex, 'utf8');
      let rewrittenContent: string = sourceContent.replace(
        '../../../../main/ets/views/AuthenticationPage',
        '../../../../../../../../src/main/ets/views/AuthenticationPage.ets'
      );
      rewrittenContent = rewrittenContent.replace(
        '../../../../main/ets/views/CollectionPage',
        '../../../../../../../../src/main/ets/views/CollectionPage.ets'
      );
      rewrittenContent = rewrittenContent.replace(
        '../../../../main/ets/views/CoursePage',
        '../../../../../../../../src/main/ets/views/CoursePage.ets'
      );
      fs.writeFileSync(targetIndex, rewrittenContent, 'utf8');
    };

    node.afterNodeEvaluate((currentNode: HvigorNode) => {
      const compileTask =
        currentNode.getTaskByName('ohosTest@OhosTestCompileArkTS') ??
        currentNode.getTaskByName('default@OhosTestCompileArkTS');
      if (compileTask) {
        compileTask.beforeRun(copyIndex);
      }
    });
  }
};

export default {
  system: harTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: [copyOhosTestIndexPlugin]         /* Custom plugin to extend the functionality of Hvigor. */
}
