import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const ENTRY_OHOS_TEST_MODULE: string = 'entry@ohosTest';
const GENERATE_OHOS_TEST_TEMPLATE_TASK: string = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_ARK_TS_TASK: string = 'ohosTest@OhosTestCompileArkTS';

function shouldConfigureOhosTest(): boolean {
    return hvigor.getParameter().getExtParam('module') === ENTRY_OHOS_TEST_MODULE;
}

const replaceOhosTestIndexPlugin: HvigorPlugin = {
    pluginId: 'driver_license_exam_replace_ohos_test_index',
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
                    const sourcePath: string = path.resolve(
                        taskContext.modulePath,
                        'src/ohosTest/ets/testability/pages/Index.ets'
                    );
                    const targetPaths: string[] = [
                        path.resolve(
                            taskContext.modulePath,
                            'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets'
                        ),
                        path.resolve(
                            taskContext.modulePath,
                            '.test/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets'
                        )
                    ];

                    if (!fs.existsSync(sourcePath)) {
                        throw new Error(`OhosTest host page not found: ${sourcePath}`);
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
