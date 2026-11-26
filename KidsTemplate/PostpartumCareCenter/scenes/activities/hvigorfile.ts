import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const ON_DEVICE_TEST_TASK = 'onDeviceTest';
const GENERATE_OHOS_TEST_TEMPLATE_TASK = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_ARK_TS_TASK = 'ohosTest@OhosTestCompileArkTS';

const replaceOhosTestIndexPlugin: HvigorPlugin = {
  pluginId: 'activities_replace_ohos_test_index',
  apply(node) {
    hvigor.nodesEvaluated(() => {
      const entryTasks = new Set(hvigor.getCommandEntryTask() ?? []);
      const isStudioTestHap = entryTasks.has('genOnDeviceTestHap') &&
        hvigor.getParameter().getExtParam('module') === `${node.getNodeName()}@ohosTest`;
      if (!entryTasks.has(ON_DEVICE_TEST_TASK) && !isStudioTestHap) {
        return;
      }

      node.registerTask({
        name: 'ReplaceOhosTestIndex',
        dependencies: [GENERATE_OHOS_TEST_TEMPLATE_TASK],
        postDependencies: [OHOS_TEST_COMPILE_ARK_TS_TASK],
        run(taskContext) {
          const sourcePath = path.resolve(taskContext.modulePath, 'src/ohosTest/ets/testability/pages/Index.ets');
          // Keep the entry page in sync with both Hvigor output layouts.
          const targetPaths = [
            path.resolve(taskContext.modulePath, 'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets'),
            path.resolve(taskContext.modulePath, '.test/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets')
          ];

          if (!fs.existsSync(sourcePath)) {
            return;
          }

          for (const targetPath of targetPaths) {
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
  plugins: [replaceOhosTestIndexPlugin]
}
