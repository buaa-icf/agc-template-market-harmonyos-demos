import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const plugin: HvigorPlugin = {
  pluginId: 'feed_replace_ohos_test_index',
  apply(node) {
    hvigor.nodesEvaluated(() => {
      if (!(hvigor.getCommandEntryTask() ?? []).includes('onDeviceTest')) {
        return;
      }
      node.registerTask({
        name: 'ReplaceOhosTestIndex',
        dependencies: ['ohosTest@GenerateOhosTestTemplate'],
        postDependencies: ['ohosTest@OhosTestCompileArkTS'],
        run(taskContext) {
          const sourcePath = path.resolve(taskContext.modulePath, 'src/ohosTest/ets/testability/pages/Index.ets');
          const targetPath = path.resolve(taskContext.modulePath,
            'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets');
          if (fs.existsSync(sourcePath)) {
            fs.mkdirSync(path.dirname(targetPath), { recursive: true });
            fs.copyFileSync(sourcePath, targetPath);
          }
        }
      });
    });
  }
};

export default {
  system: harTasks,
  plugins: [plugin]
};
