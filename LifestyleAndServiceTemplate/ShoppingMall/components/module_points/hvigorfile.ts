import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const ON_DEVICE_TEST_TASK = 'onDeviceTest';
const GENERATE_OHOS_TEST_TEMPLATE_TASK = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_ARK_TS_TASK = 'ohosTest@OhosTestCompileArkTS';

const replaceOhosTestIndexPlugin: HvigorPlugin = {
    pluginId: 'module_points_replace_ohos_test_index',
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
                    const sourcePath = path.resolve(taskContext.modulePath, 'src/ohosTest/ets/testability/pages/Index.ets');
                    if (!fs.existsSync(sourcePath)) {
                        return;
                    }

                    const targetPaths = [
                        path.resolve(taskContext.modulePath, 'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets'),
                        path.resolve(taskContext.modulePath, '.test/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets')
                    ];

                    for (const targetPath of targetPaths) {
                        fs.mkdirSync(path.dirname(targetPath), { recursive: true });
                        fs.copyFileSync(sourcePath, targetPath);
                    }
                }
            });
        });
    }
};

export default {
    system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[replaceOhosTestIndexPlugin]         /* Custom plugin to extend the functionality of Hvigor. */
}
