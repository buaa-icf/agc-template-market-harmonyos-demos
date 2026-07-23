import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const GENERATE_OHOS_TEST_TEMPLATE_TASK = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_ARK_TS_TASK = 'ohosTest@OhosTestCompileArkTS';
const IDE_GENERATE_ON_DEVICE_TEST_HAP_TASK = 'genOnDeviceTestHap';

const replaceOhosTestIndexPlugin: HvigorPlugin = {
  pluginId: 'picture_beautification_replace_ohos_test_index',
  apply(node) {
    hvigor.nodesEvaluated(() => {
      // A normal IDE sync does not have the ohosTest task graph.  DevEco's
      // runtime node here does not expose lazy-task inspection APIs, so use
      // the command entry names instead.  DevEco's instrument-test runner uses
      // "genOnDeviceTestHap", while command-line device runs use
      // "onDeviceTest".
      const entryTasks = hvigor.getCommandEntryTask() ?? [];
      const isOhosTestBuild = entryTasks.some((task) =>
        task.includes('onDeviceTest') || task.includes(IDE_GENERATE_ON_DEVICE_TEST_HAP_TASK) ||
          task.toLowerCase().includes('ohostest'));
      if (!isOhosTestBuild) {
        return;
      }

      node.registerTask({
        name: 'ReplaceOhosTestIndex',
        dependencies: [GENERATE_OHOS_TEST_TEMPLATE_TASK],
        postDependencies: [OHOS_TEST_COMPILE_ARK_TS_TASK],
        run(taskContext) {
          const sourcePath = path.resolve(taskContext.modulePath, 'src/ohosTest/ets/testability/pages/Index.ets');
          const targetPath = path.resolve(taskContext.modulePath,
            '.test/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets');

          if (!fs.existsSync(sourcePath)) {
            return;
          }

          fs.mkdirSync(path.dirname(targetPath), { recursive: true });
          fs.copyFileSync(sourcePath, targetPath);
        }
      });
    });
  }
};

export default {
  system: harTasks,
  plugins: [replaceOhosTestIndexPlugin]
}
