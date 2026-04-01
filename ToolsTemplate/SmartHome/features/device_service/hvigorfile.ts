import * as fs from 'fs';
import * as path from 'path';
import { harTasks } from '@ohos/hvigor-ohos-plugin';

const syncAgreementOhosTestHostPagePlugin = {
    pluginId: 'syncAgreementOhosTestHostPagePlugin',
    apply(node) {
        node.afterNodeEvaluate(() => {
            const sourcePath = path.resolve(__dirname, 'src/ohosTest/ets/testability/pages/Index.ets');
            const targetPath = path.resolve(__dirname,
                'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets');
            const compileTask = node.getTaskByName('ohosTest@OhosTestCompileArkTS')
                ?? node.getTaskByName('OhosTestCompileArkTS');

            if (!compileTask) {
                return;
            }

            compileTask.beforeRun(() => {
                if (!fs.existsSync(sourcePath)) {
                    return;
                }
                const targetDir = path.dirname(targetPath);
                const importReplacements = new Map([
                    ['../../../../main/ets/view/AgreementView',
                        path.relative(targetDir, path.resolve(__dirname, 'src/main/ets/view/AgreementView.ets'))
                            .replace(/\\/g, '/')
                            .replace(/\.ets$/, '')],
                    ['../../../../main/ets/pages/PrivacyPolicyPage',
                        path.relative(targetDir, path.resolve(__dirname, 'src/main/ets/pages/PrivacyPolicyPage.ets'))
                            .replace(/\\/g, '/')
                            .replace(/\.ets$/, '')],
                    ['../../../../main/ets/pages/TermsOfServicePage',
                        path.relative(targetDir, path.resolve(__dirname, 'src/main/ets/pages/TermsOfServicePage.ets'))
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
        });
    }
};

export default {
    system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[syncAgreementOhosTestHostPagePlugin]         /* Custom plugin to extend the functionality of Hvigor. */
}
