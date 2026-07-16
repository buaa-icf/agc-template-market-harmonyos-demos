import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const BOOK_HOME_OHOS_TEST_MODULE = 'book_home@ohosTest';
const GENERATE_OHOS_TEST_TEMPLATE_TASK = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_ARK_TS_TASK = 'ohosTest@OhosTestCompileArkTS';
const OHOS_TEST_CACHE_NATIVE_LIBS_TASK = 'ohosTest@CacheNativeLibs';
const OHOS_TEST_PACKAGE_HAP_TASK = 'ohosTest@PackageHap';
const PAYMENT_NATIVE_LIBRARIES = ['libblueshield.so', 'libutdid_native.so'];

function shouldConfigureOhosTest(): boolean {
  const module = hvigor.getParameter().getExtParam('module') ?? '';

  return module === BOOK_HOME_OHOS_TEST_MODULE;
}

function stripPaymentNativeLibraries(modulePath: string): void {
  const testNativeLibDirectories = [
    path.resolve(modulePath, 'build/default/intermediates/libs/ohosTest/arm64-v8a'),
    path.resolve(modulePath, 'build/default/intermediates/stripped_native_libs/ohosTest/arm64-v8a'),
  ];

  for (const directory of testNativeLibDirectories) {
    for (const fileName of PAYMENT_NATIVE_LIBRARIES) {
      fs.rmSync(path.resolve(directory, fileName), { force: true });
    }
  }

  const testOutputDirectory = path.resolve(modulePath, 'build/default/outputs/ohosTest');
  if (!fs.existsSync(testOutputDirectory)) {
    return;
  }

  for (const fileName of fs.readdirSync(testOutputDirectory)) {
    if (fileName.endsWith('.hap')) {
      fs.rmSync(path.resolve(testOutputDirectory, fileName), { force: true });
    }
  }
}

const replaceOhosTestIndexPlugin: HvigorPlugin = {
  pluginId: 'book_home_replace_ohos_test_index',
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

      node.registerTask({
        name: 'StripOhosTestPaymentNativeLibs',
        dependencies: [OHOS_TEST_CACHE_NATIVE_LIBS_TASK],
        postDependencies: [OHOS_TEST_PACKAGE_HAP_TASK],
        run(taskContext) {
          stripPaymentNativeLibraries(taskContext.modulePath);
        }
      });
    });
  }
};

export default {
  system: harTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: [replaceOhosTestIndexPlugin]
}
