import * as fs from 'fs';
import * as path from 'path';
import { hvigor } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const syncAgreementOhosTestHostPagePlugin: HvigorPlugin = {
    pluginId: 'syncAgreementOhosTestHostPagePlugin',
    apply(node) {
        hvigor.nodesEvaluated(() => {
            const nodeApi = node as unknown as Record<string, Function>;
            const hasTask: (name: string) => boolean = typeof nodeApi.hasTask === 'function'
                ? (nodeApi.hasTask as (name: string) => boolean).bind(node)
                : (name: string): boolean => node.getTaskByName(name) !== undefined;
            if (!hasTask('ohosTest@GenerateOhosTestTemplate')) {
                return;
            }
            node.registerTask({
                name: 'SyncAgreementOhosTestHostPage',
                dependencies: ['ohosTest@GenerateOhosTestTemplate'],
                postDependencies: hasTask('ohosTest@OhosTestCompileArkTS')
                    ? ['ohosTest@OhosTestCompileArkTS']
                    : [],
                run(taskContext) {
                const sourcePath = path.resolve(taskContext.modulePath,
                    'src/ohosTest/ets/testability/pages/Index.ets');
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
                    const targetDir = path.dirname(targetPath);
                    const importReplacements = new Map([
                        ['../../../../main/ets/view/AgreementView',
                            path.relative(targetDir, path.resolve(taskContext.modulePath,
                                'src/main/ets/view/AgreementView.ets'))
                                .replace(/\\/g, '/')
                                .replace(/\.ets$/, '')],
                        ['../../../../main/ets/pages/PrivacyPolicyPage',
                            path.relative(targetDir, path.resolve(taskContext.modulePath,
                                'src/main/ets/pages/PrivacyPolicyPage.ets'))
                                .replace(/\\/g, '/')
                                .replace(/\.ets$/, '')],
                        ['../../../../main/ets/pages/QuickLoginPage',
                            path.relative(targetDir, path.resolve(taskContext.modulePath,
                                'src/main/ets/pages/QuickLoginPage.ets'))
                                .replace(/\\/g, '/')
                                .replace(/\.ets$/, '')],
                        ['../../../../main/ets/pages/TermsOfServicePage',
                            path.relative(targetDir, path.resolve(taskContext.modulePath,
                                'src/main/ets/pages/TermsOfServicePage.ets'))
                                .replace(/\\/g, '/')
                                .replace(/\.ets$/, '')]
                    ]);
                    let sourceContent = fs.readFileSync(sourcePath, 'utf-8');

                    importReplacements.forEach((relativeTargetPath, originalImportPath) => {
                        sourceContent = sourceContent.replace(originalImportPath, relativeTargetPath);
                    });
                    fs.mkdirSync(path.dirname(targetPath), { recursive: true });
                    fs.writeFileSync(targetPath, sourceContent);
                });
                }
            });
        });
    }
};

export default {
    system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[syncAgreementOhosTestHostPagePlugin]         /* Custom plugin to extend the functionality of Hvigor. */
}
