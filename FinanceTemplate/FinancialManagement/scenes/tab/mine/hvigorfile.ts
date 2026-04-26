import fs from 'fs';
import path from 'path';
import { hvigor, HvigorPlugin } from '@ohos/hvigor';
import { hspTasks } from '@ohos/hvigor-ohos-plugin';

const ON_DEVICE_TEST_TASK = 'onDeviceTest';
const GENERATE_OHOS_TEST_TEMPLATE_TASK = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_ARK_TS_TASK = 'ohosTest@OhosTestCompileArkTS';

const replaceOhosTestIndexPlugin: HvigorPlugin = {
  pluginId: 'replace_ohos_test_index',
  apply(node) {
    hvigor.nodesEvaluated(() => {
      const entryTasks = new Set(hvigor.getCommandEntryTask() ?? []);
      if (!entryTasks.has(ON_DEVICE_TEST_TASK)) {
        return;
      }
      node.registerTask({
        name: 'ReplaceOhosTestIndex',
        dependencies: [GENERATE_OHOS_TEST_TEMPLATE_TASK],
        postDependencies: [OHOS_TEST_COMPILE_ARK_TS_TASK],
        run(taskContext) {
          const sourcePath = path.resolve(taskContext.modulePath,
            'src/ohosTest/ets/testability/pages/Index.ets');
          const targetPath = path.resolve(taskContext.modulePath,
            'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets');
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
    system: hspTasks,
    plugins: [replaceOhosTestIndexPlugin]
}
