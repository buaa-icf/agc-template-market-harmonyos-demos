import fs from 'fs';
import path from 'path';
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin, HvigorTask } from '@ohos/hvigor';

const SYNC_TESTABILITY_INDEX_TASK: string = 'ohosTest@SyncTestabilityIndex';
const GENERATE_OHOS_TEST_TEMPLATE_TASK: string = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_TASK: string = 'ohosTest@OhosTestCompileArkTS';

function toPosixPath(filePath: string): string {
    return filePath.split(path.sep).join('/');
}

function rewriteRelativeImports(source: string, sourceFilePath: string, targetFilePath: string): string {
    return source.replace(/from\s+['"](\.[^'"]+)['"]/g, (_match: string, importPath: string) => {
        const resolvedImportPath: string = path.resolve(path.dirname(sourceFilePath), importPath);
        let rewrittenImportPath: string = path.relative(path.dirname(targetFilePath), resolvedImportPath);
        rewrittenImportPath = toPosixPath(rewrittenImportPath);
        if (!rewrittenImportPath.startsWith('.')) {
            rewrittenImportPath = `./${rewrittenImportPath}`;
        }
        return `from '${rewrittenImportPath}'`;
    });
}

function hasTask(node: Parameters<HvigorPlugin['apply']>[0], taskName: string): boolean {
    return node.getAllTasks().some((task) => task.name === taskName);
}

const syncOhosTestIndexPlugin: HvigorPlugin = {
    pluginId: 'sync-ohos-test-index-plugin',
    apply(node) {
        if (!hasTask(node, GENERATE_OHOS_TEST_TEMPLATE_TASK) || !hasTask(node, OHOS_TEST_COMPILE_TASK)) {
            return;
        }

        node.registerTask({
            name: SYNC_TESTABILITY_INDEX_TASK,
            dependencies: [GENERATE_OHOS_TEST_TEMPLATE_TASK],
            postDependencies: [OHOS_TEST_COMPILE_TASK],
            run(taskContext) {
                const sourceFilePath: string = path.join(taskContext.modulePath, 'src/ohosTest/ets/testability/pages/Index.ets');
                const targetFilePath: string = path.join(taskContext.modulePath,
                    'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets');

                if (!fs.existsSync(sourceFilePath)) {
                    throw new Error(`Missing ohosTest host page: ${sourceFilePath}`);
                }

                const sourceFileContent: string = fs.readFileSync(sourceFilePath, 'utf8');
                const rewrittenContent: string = rewriteRelativeImports(sourceFileContent, sourceFilePath, targetFilePath);

                fs.mkdirSync(path.dirname(targetFilePath), { recursive: true });
                fs.writeFileSync(targetFilePath, rewrittenContent, 'utf8');
            },
        } satisfies HvigorTask);
    },
};

export default {
    system: hapTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[syncOhosTestIndexPlugin]         /* Custom plugin to extend the functionality of Hvigor. */
}
