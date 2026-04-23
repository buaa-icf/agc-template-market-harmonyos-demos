import * as fs from 'fs';
import * as path from 'path';
import { harTasks } from '@ohos/hvigor-ohos-plugin';

const syncOhosTestHostPagePlugin = {
  pluginId: 'syncOhosTestHostPagePlugin',
  apply(node) {
    node.afterNodeEvaluate(() => {
      const compileTask = node.getTaskByName('ohosTest@OhosTestCompileArkTS')
        ?? node.getTaskByName('OhosTestCompileArkTS');

      if (!compileTask) {
        return;
      }

      compileTask.beforeRun(() => {
        const sourcePath = path.resolve(__dirname, 'src/ohosTest/ets/testability/pages/Index.ets');
        const targetPath = path.resolve(__dirname, '.test/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets');
        if (!fs.existsSync(sourcePath)) {
          return;
        }

        const targetDir = path.dirname(targetPath);
        const replacements = new Map([
          ['../../../../main/ets/model/BeautificationParam',
            path.relative(targetDir, path.resolve(__dirname, 'src/main/ets/model/BeautificationParam.ets'))
              .replace(/\\/g, '/')
              .replace(/\.ets$/, '')],
          ['../../../../main/ets/components/StickerToolBar',
            path.relative(targetDir, path.resolve(__dirname, 'src/main/ets/components/StickerToolBar.ets'))
              .replace(/\\/g, '/')
              .replace(/\.ets$/, '')],
          ['../../../../main/ets/model/Constants',
            path.relative(targetDir, path.resolve(__dirname, 'src/main/ets/model/Constants.ets'))
              .replace(/\\/g, '/')
              .replace(/\.ets$/, '')]
        ]);

        let sourceContent = fs.readFileSync(sourcePath, 'utf-8');
        replacements.forEach((targetImportPath, sourceImportPath) => {
          sourceContent = sourceContent.replace(sourceImportPath, targetImportPath);
        });

        fs.mkdirSync(targetDir, { recursive: true });
        fs.writeFileSync(targetPath, sourceContent);
      });
    });
  }
};

export default {
  system: harTasks,
  plugins: [syncOhosTestHostPagePlugin]
}
