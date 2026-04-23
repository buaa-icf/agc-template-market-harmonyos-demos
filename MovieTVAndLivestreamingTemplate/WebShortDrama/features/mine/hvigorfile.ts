import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import type { HvigorPlugin } from '@ohos/hvigor';
import { hspTasks } from '@ohos/hvigor-ohos-plugin';

const ON_DEVICE_TEST_TASK = 'onDeviceTest';
const GENERATE_OHOS_TEST_TEMPLATE_TASK = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_TASK_CANDIDATES = [
  'ohosTest@OhosTestCompileArkTS',
  'ohosTest@CompileArkTS',
  'ohosTest@OhosTestCompileJS',
  'ohosTest@BuildArkTS',
  'ohosTest@BuildJS'
];

function existingTasks(node: any, taskNames: string[]): string[] {
  return taskNames.filter((taskName: string) => node.getTaskByName(taskName) !== undefined);
}

function copyAndFixOhosTestIndex(sourcePath: string, targetPath: string): void {
  if (!fs.existsSync(sourcePath)) {
    return;
  }
  fs.mkdirSync(path.dirname(targetPath), { recursive: true });
  let fixedContent = fs.readFileSync(sourcePath, 'utf-8');
  fixedContent = fixedContent.replace(
    "from '../../../../main/ets/pages/MyFavoritesPage';",
    "from '../../../../../../../../src/main/ets/pages/MyFavoritesPage';"
  );
  fixedContent = fixedContent.replace(
    "from '../../../../main/ets/pages/WatchRecordsPage';",
    "from '../../../../../../../../src/main/ets/pages/WatchRecordsPage';"
  );
  fs.writeFileSync(targetPath, fixedContent);
}

const replaceOhosTestIndexPlugin: HvigorPlugin = {
  pluginId: 'mine_replace_ohos_test_index',
  apply(node) {
    hvigor.nodesEvaluated(() => {
      const entryTasks = new Set(hvigor.getCommandEntryTask() ?? []);
      if (!entryTasks.has(ON_DEVICE_TEST_TASK)) {
        return;
      }
      if (node.getTaskByName(GENERATE_OHOS_TEST_TEMPLATE_TASK) === undefined) {
        return;
      }
      const postDependencies = existingTasks(node, OHOS_TEST_COMPILE_TASK_CANDIDATES);
      if (postDependencies.length === 0) {
        return;
      }

      node.registerTask({
        name: 'CopyMineOhosTestHostIndex',
        dependencies: [GENERATE_OHOS_TEST_TEMPLATE_TASK],
        postDependencies,
        run(taskContext) {
          const sourcePath = path.resolve(taskContext.modulePath, 'src/ohosTest/ets/testability/pages/Index.ets');
          const buildTargetPath = path.resolve(taskContext.modulePath,
            'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets');
          const testTargetPath = path.resolve(taskContext.modulePath,
            '.test/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets');

          copyAndFixOhosTestIndex(sourcePath, buildTargetPath);
          copyAndFixOhosTestIndex(sourcePath, testTargetPath);
        }
      });
    });
  }
};

export default {
  system: hspTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins:[replaceOhosTestIndexPlugin]         /* Custom plugin to extend the functionality of Hvigor. */
}
