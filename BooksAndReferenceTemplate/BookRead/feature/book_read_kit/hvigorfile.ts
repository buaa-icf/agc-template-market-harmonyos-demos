import fs from 'fs';
import path from 'path';
import { spawnSync } from 'child_process';
import { hvigor } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const ON_DEVICE_TEST_TASK = 'onDeviceTest';
const GENERATE_ON_DEVICE_TEST_HAP_TASK = 'genOnDeviceTestHap';
const BOOK_READ_KIT_OHOS_TEST_MODULE = 'book_read_kit@ohosTest';
const GENERATE_OHOS_TEST_TEMPLATE_TASK = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_ARK_TS_TASK = 'ohosTest@OhosTestCompileArkTS';
const OHOS_TEST_PACKAGE_HAP_TASK = 'ohosTest@PackageHap';
const OHOS_TEST_SIGN_HAP_TASK = 'ohosTest@SignHap';

function shouldConfigureOhosTest(): boolean {
  const module = hvigor.getParameter().getExtParam('module') ?? '';
  const entryTasks = new Set(hvigor.getCommandEntryTask() ?? []);

  return module === BOOK_READ_KIT_OHOS_TEST_MODULE &&
    (entryTasks.has(ON_DEVICE_TEST_TASK) || entryTasks.has(GENERATE_ON_DEVICE_TEST_HAP_TASK));
}

const replaceOhosTestIndexPlugin: HvigorPlugin = {
  pluginId: 'book_read_kit_replace_ohos_test_index',
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
          const targetPaths = [
            path.resolve(taskContext.modulePath,
              '.test/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets'),
            path.resolve(taskContext.modulePath,
              'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets')
          ];

          if (!fs.existsSync(sourcePath)) {
            return;
          }

          targetPaths.forEach((targetPath: string) => {
            fs.mkdirSync(path.dirname(targetPath), { recursive: true });
            fs.copyFileSync(sourcePath, targetPath);
          });
        }
      });
    });
  }
};

const stripUnsupportedTestNativeLibsPlugin: HvigorPlugin = {
  pluginId: 'book_read_kit_strip_unsupported_test_native_libs',
  apply(node) {
    hvigor.nodesEvaluated(() => {
      if (!shouldConfigureOhosTest()) {
        return;
      }

      node.registerTask({
        name: 'StripUnsupportedOhosTestNativeLibs',
        dependencies: [OHOS_TEST_PACKAGE_HAP_TASK],
        postDependencies: [OHOS_TEST_SIGN_HAP_TASK],
        run(taskContext) {
          const unsignedHap = path.resolve(taskContext.modulePath,
            'build/default/outputs/ohosTest/book_read_kit-ohosTest-unsigned.hap');
          if (!fs.existsSync(unsignedHap)) {
            throw new Error(`Unsigned ohosTest HAP not found: ${unsignedHap}`);
          }

          const workDir = path.resolve(taskContext.modulePath,
            '.test/default/intermediates/ohosTest/x86_hap_repack');
          const unpackedDir = path.resolve(workDir, 'unpacked');
          const repackedHap = path.resolve(workDir, 'book_read_kit-ohosTest-x86.hap');
          fs.rmSync(workDir, { recursive: true, force: true });
          fs.mkdirSync(unpackedDir, { recursive: true });

          const tar = 'C:\\Windows\\System32\\tar.exe';
          const extract = spawnSync(tar, ['-xf', unsignedHap, '-C', unpackedDir], { encoding: 'utf-8' });
          if (extract.status !== 0) {
            throw new Error(`Unable to unpack ohosTest HAP: ${extract.stderr}`);
          }

          fs.rmSync(path.resolve(unpackedDir, 'libs'), { recursive: true, force: true });
          const topLevelEntries = fs.readdirSync(unpackedDir);
          const pack = spawnSync(tar,
            ['--format', 'zip', '-cf', repackedHap, '-C', unpackedDir, ...topLevelEntries],
            { encoding: 'utf-8' });
          if (pack.status !== 0) {
            throw new Error(`Unable to repack x86-compatible ohosTest HAP: ${pack.stderr}`);
          }

          fs.copyFileSync(repackedHap, unsignedHap);
          fs.rmSync(workDir, { recursive: true, force: true });
        }
      });
    });
  }
};

export default {
  system: harTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: [replaceOhosTestIndexPlugin, stripUnsupportedTestNativeLibsPlugin]
}
