import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';
import { hvigor } from '@ohos/hvigor';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';

const copyOhosTestHostPagePlugin: HvigorPlugin = {
  pluginId: 'activities-copy-ohos-test-host-page',
  apply(node) {
    const moduleArg = hvigor.getParameter().getExtParam('module') || '';
    if (!moduleArg.includes('@ohosTest')) {
      return;
    }

    const hostSourcePath = join(
      node.getNodeDir().getPath(),
      'src',
      'ohosTest',
      'ets',
      'testability',
      'pages',
      'Index.ets'
    );

    const intermediatesHostPath = join(
      node.getNodeDir().getPath(),
      '.test',
      'default',
      'intermediates',
      'src',
      'ohosTest',
      'ets',
      'testability',
      'pages',
      'Index.ets'
    );
    const generatedTestabilityHostPath = join(
      node.getNodeDir().getPath(),
      '.test',
      'default',
      'intermediates',
      '.test',
      'testability',
      'pages',
      'Index.ets'
    );

    const copyHostPages = () => {
      if (!existsSync(hostSourcePath)) {
        return;
      }
      mkdirSync(dirname(intermediatesHostPath), { recursive: true });
      const sourceContent = readFileSync(hostSourcePath, 'utf-8');
      const contentForSrcIntermediates = sourceContent
        // Import path must be valid from generated intermediates testability page.
        .replace(
          "../../../../main/ets/view/ActivityBooking",
          "../../../../../../../../src/main/ets/view/ActivityBooking"
        );
      writeFileSync(intermediatesHostPath, contentForSrcIntermediates, 'utf-8');

      mkdirSync(dirname(generatedTestabilityHostPath), { recursive: true });
      const contentForGeneratedTestability = sourceContent
        .replace(
          "../../../../main/ets/view/ActivityBooking",
          "../../../../../../src/main/ets/view/ActivityBooking"
        )
        .replace('@ComponentV2', '@Component');
      writeFileSync(generatedTestabilityHostPath, contentForGeneratedTestability, 'utf-8');
    };

    const generateTemplateTask = node.getTaskByName('ohosTest@GenerateOhosTestTemplate');
    if (generateTemplateTask) {
      generateTemplateTask.afterRun(copyHostPages);
    }
    const compileResourceTask = node.getTaskByName('ohosTest@CompileResource');
    if (compileResourceTask) {
      compileResourceTask.beforeRun(copyHostPages);
    }
    const compileArkTsTask = node.getTaskByName('ohosTest@OhosTestCompileArkTS');
    if (compileArkTsTask) {
      compileArkTsTask.beforeRun(copyHostPages);
    }
    const compileJsTask = node.getTaskByName('ohosTest@OhosTestCompileJS');
    if (compileJsTask) {
      compileJsTask.beforeRun(copyHostPages);
    }
  }
};

export default {
  system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: [copyOhosTestHostPagePlugin] /* Custom plugin to extend the functionality of Hvigor. */
}
