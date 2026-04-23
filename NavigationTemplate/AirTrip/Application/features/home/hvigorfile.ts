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

function normalizeToPosix(filePath: string): string {
  return filePath.replace(/\\/g, '/');
}

function existingTasks(node: any, taskNames: string[]): string[] {
  return taskNames.filter((taskName: string) => node.getTaskByName(taskName) !== undefined);
}

function writeHostIndex(taskContext: any, sourcePath: string, targetPath: string): void {
  if (!fs.existsSync(sourcePath)) {
    return;
  }

  const targetDir = path.dirname(targetPath);
  const homePageModulePath = path.resolve(taskContext.modulePath, 'src/main/ets/pages/HomePage');
  const homePageImportPath = normalizeToPosix(path.relative(targetDir, homePageModulePath));

  const originalContent = fs.readFileSync(sourcePath, 'utf-8');
  const importLine = `import { homePageBuilder } from '${homePageImportPath}';`;
  const fixedContent = originalContent.replace(
    /import\s+\{\s*homePageBuilder\s*\}\s+from\s+['"][^'"]+['"];/,
    importLine
  );

  fs.mkdirSync(targetDir, { recursive: true });
  fs.writeFileSync(targetPath, fixedContent);
}

const replaceOhosTestIndexPlugin: HvigorPlugin = {
  pluginId: 'home_replace_ohos_test_index',
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
        name: 'CopyHomeOhosTestHostIndex',
        dependencies: [GENERATE_OHOS_TEST_TEMPLATE_TASK],
        postDependencies,
        run(taskContext) {
          const sourcePath = path.resolve(taskContext.modulePath, 'src/ohosTest/ets/testability/pages/Index.ets');
          const targets = [
            path.resolve(taskContext.modulePath, '.test/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets'),
            path.resolve(taskContext.modulePath, 'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets')
          ];

          targets.forEach((targetPath: string) => writeHostIndex(taskContext, sourcePath, targetPath));
        }
      });
    });
  }
};

export default {
  system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: [replaceOhosTestIndexPlugin]         /* Custom plugin to extend the functionality of Hvigor. */
}
