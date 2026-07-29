import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import type { HvigorPlugin } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';

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

function writeHostIndex(sourcePath: string, targetPath: string): void {
  if (!fs.existsSync(sourcePath)) {
    return;
  }

  const sourceContent = fs.readFileSync(sourcePath, 'utf-8');
  const fixedContent = sourceContent.replace(
    '../../../../main/ets/pages/AuthenticationPage',
    '../../../../../../../../src/main/ets/pages/AuthenticationPage.ets'
  );
  fs.mkdirSync(path.dirname(targetPath), { recursive: true });
  fs.writeFileSync(targetPath, fixedContent, 'utf-8');
}

const replaceOhosTestIndexPlugin: HvigorPlugin = {
  pluginId: 'homepage_replace_ohos_test_index',
  apply(node) {
    hvigor.nodesEvaluated(() => {
      if (node.getTaskByName(GENERATE_OHOS_TEST_TEMPLATE_TASK) === undefined) {
        return;
      }

      const postDependencies = existingTasks(node, OHOS_TEST_COMPILE_TASK_CANDIDATES);
      if (postDependencies.length === 0) {
        return;
      }

      node.registerTask({
        name: 'CopyHomePageOhosTestHostIndex',
        dependencies: [GENERATE_OHOS_TEST_TEMPLATE_TASK],
        postDependencies,
        run(taskContext) {
          const sourcePath = path.resolve(taskContext.modulePath, 'src/ohosTest/ets/testability/pages/Index.ets');
          const targets = [
            path.resolve(taskContext.modulePath, '.test/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets'),
            path.resolve(taskContext.modulePath, 'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets')
          ];
          targets.forEach((targetPath: string) => writeHostIndex(sourcePath, targetPath));
        }
      });
    });
  }
};

export default {
  system: harTasks,
  plugins: [replaceOhosTestIndexPlugin]
}
