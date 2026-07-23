import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const plugin: HvigorPlugin = {
  pluginId: 'user_replace_ohos_test_index',
  apply(node) {
    hvigor.nodesEvaluated(() => {
      const ohosTestEntryTasks = new Set(['onDeviceTest', 'genOnDeviceTestHap']);
      const commandEntryTasks = hvigor.getCommandEntryTask() ?? [];
      const targetModule = hvigor.getParameter().getExtParam('module');
      if (targetModule !== 'user@ohosTest' ||
        !commandEntryTasks.some(taskName => ohosTestEntryTasks.has(taskName))) {
        return;
      }
      node.registerTask({
        name: 'ReplaceOhosTestIndex',
        dependencies: ['ohosTest@GenerateOhosTestTemplate'],
        postDependencies: ['ohosTest@OhosTestCompileArkTS'],
        run(taskContext) {
          const sourcePath = path.resolve(taskContext.modulePath, 'src/ohosTest/ets/testability/pages/Index.ets');
          if (fs.existsSync(sourcePath)) {
            const targetPaths = [
              '.test/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets',
              'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets'
            ];
            targetPaths.forEach((targetRelativePath: string) => {
              const targetPath = path.resolve(taskContext.modulePath, targetRelativePath);
              fs.mkdirSync(path.dirname(targetPath), { recursive: true });
              fs.copyFileSync(sourcePath, targetPath);
            });
          }
        }
      });
    });
  }
};

export default {
    system: harTasks,
    plugins: [plugin]
}
