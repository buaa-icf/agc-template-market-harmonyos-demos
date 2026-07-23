import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const READER_TOOL_BAR_OHOS_TEST_MODULE = 'reader_tool_bar@ohosTest';
const GENERATE_OHOS_TEST_TEMPLATE_TASK = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_ARK_TS_TASK = 'ohosTest@OhosTestCompileArkTS';

function shouldConfigureOhosTest(): boolean {
  const module = hvigor.getParameter().getExtParam('module') ?? '';

  return module === READER_TOOL_BAR_OHOS_TEST_MODULE;
}

const replaceOhosTestIndexPlugin: HvigorPlugin = {
  pluginId: 'reader_tool_bar_replace_ohos_test_index',
  apply(node) {
    hvigor.nodesEvaluated(() => {
      if (!shouldConfigureOhosTest()) {
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
    system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[replaceOhosTestIndexPlugin]         /* Custom plugin to extend the functionality of Hvigor. */
}
