import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const GENERATE_OHOS_TEST_TEMPLATE_TASK = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_TASK_CANDIDATES = [
  'ohosTest@OhosTestCompileArkTS',
  'ohosTest@CompileArkTS',
  'ohosTest@OhosTestCompileJS',
  'ohosTest@BuildArkTS',
  'ohosTest@BuildJS'
];

const replaceOhosTestIndexPlugin: HvigorPlugin = {
  pluginId: 'components_replace_ohos_test_index',
  apply(node) {
    hvigor.nodesEvaluated(() => {
      const generateTask = node.getTaskByName(GENERATE_OHOS_TEST_TEMPLATE_TASK);
      if (generateTask === undefined) {
        return;
      }

      const postDependencies: string[] = OHOS_TEST_COMPILE_TASK_CANDIDATES.filter((taskName: string) => {
        return node.getTaskByName(taskName) !== undefined;
      });
      if (postDependencies.length === 0) {
        return;
      }

      node.registerTask({
        name: 'ReplaceOhosTestIndex',
        dependencies: [GENERATE_OHOS_TEST_TEMPLATE_TASK],
        postDependencies,
        run(taskContext) {
          const sourcePath = path.resolve(taskContext.modulePath, 'src/ohosTest/ets/testability/pages/Index.ets');
          const targetPaths = [
            path.resolve(taskContext.modulePath,
              'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets'),
            path.resolve(taskContext.modulePath,
              '.test/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets')
          ];

          if (!fs.existsSync(sourcePath)) {
            return;
          }

          targetPaths.forEach((targetPath) => {
            fs.mkdirSync(path.dirname(targetPath), { recursive: true });
            fs.copyFileSync(sourcePath, targetPath);
          });
        }
      });
    });
  }
};

export default {
    system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[replaceOhosTestIndexPlugin]         /* Custom plugin to extend the functionality of Hvigor. */
}
