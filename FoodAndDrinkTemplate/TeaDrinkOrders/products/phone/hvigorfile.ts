import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const GENERATE_OHOS_TEST_TEMPLATE_TASK = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_ARK_TS_TASK = 'ohosTest@OhosTestCompileArkTS';

const replaceOhosTestIndexPlugin: HvigorPlugin = {
    pluginId: 'tea_drink_orders_phone_replace_ohos_test_index',
    apply(node) {
        hvigor.nodesEvaluated(() => {
            const nodeApi = node as unknown as Record<string, Function>;
            const hasTask: (name: string) => boolean = typeof nodeApi.hasTask === 'function'
                ? (nodeApi.hasTask as (name: string) => boolean).bind(node)
                : (name: string): boolean => node.getTaskByName(name) !== undefined;
            if (!hasTask(GENERATE_OHOS_TEST_TEMPLATE_TASK)) {
                return;
            }

            node.registerTask({
                name: 'ReplaceOhosTestIndex',
                dependencies: [GENERATE_OHOS_TEST_TEMPLATE_TASK],
                postDependencies: hasTask(OHOS_TEST_COMPILE_ARK_TS_TASK) ? [OHOS_TEST_COMPILE_ARK_TS_TASK] : [],
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

export default {
    system: hapTasks,
    plugins: [replaceOhosTestIndexPlugin]
}
