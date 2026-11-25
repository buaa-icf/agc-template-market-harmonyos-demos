import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const ON_DEVICE_TEST_TASK = 'onDeviceTest';
const GENERATE_OHOS_TEST_TEMPLATE_TASK = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_ARK_TS_TASK = 'ohosTest@OhosTestCompileArkTS';

const replaceOhosTestIndexPlugin: HvigorPlugin = {
    pluginId: 'phone_replace_ohos_test_index',
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
                    const hostPath = 'default/intermediates/src/ohosTest/ets/testability/pages/Index.ets';
                    const generatedHosts = ['.test', 'build']
                        .map(root => path.resolve(taskContext.modulePath, root, hostPath))
                        .filter(file => fs.existsSync(file));

                    if (generatedHosts.length === 0) {
                        throw new Error('GenerateOhosTestTemplate did not create the test host page');
                    }
                    for (const host of generatedHosts) {
                        fs.copyFileSync(sourcePath, host);
                    }
                }
            });
        });
    }
};

export default {
    system: hapTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins: [replaceOhosTestIndexPlugin]         /* Custom plugin to extend the functionality of Hvigor. */
}
