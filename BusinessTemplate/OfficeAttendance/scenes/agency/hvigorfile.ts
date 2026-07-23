import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const replaceOhosTestIndexPlugin: HvigorPlugin = {
    pluginId: 'agency_replace_ohos_test_index',
    apply(node) {
        hvigor.nodesEvaluated(() => {
            const entryTasks = new Set(hvigor.getCommandEntryTask() ?? []);
            if (!entryTasks.has('onDeviceTest')) {
                return;
            }

            node.registerTask({
                name: 'ReplaceOhosTestIndex',
                dependencies: ['ohosTest@GenerateOhosTestTemplate'],
                postDependencies: ['ohosTest@OhosTestCompileArkTS'],
                run(taskContext) {
                    const sourcePath = path.resolve(taskContext.modulePath,
                        'src/ohosTest/ets/testability/pages/Index.ets');
                    const targetPath = path.resolve(taskContext.modulePath,
                        '.test/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets');
                    if (!fs.existsSync(sourcePath)) {
                        return;
                    }
                    fs.mkdirSync(path.dirname(targetPath), { recursive: true });
                    fs.copyFileSync(sourcePath, targetPath);
                }
            });
        });
    }
};

function skipWhitespace(content: string, index: number): number {
    while (index < content.length && /\s/.test(content[index])) {
        index++;
    }
    return index;
}

function readJsonString(content: string, start: number): { value: string, end: number } | null {
    let escaped = false;
    for (let index = start + 1; index < content.length; index++) {
        if (escaped) {
            escaped = false;
        } else if (content[index] === '\\') {
            escaped = true;
        } else if (content[index] === '"') {
            const raw = content.slice(start, index + 1);
            return { value: JSON.parse(raw) as string, end: index + 1 };
        }
    }
    return null;
}

function readJsonObject(content: string, start: number): { raw: string, end: number } | null {
    let depth = 0;
    let inString = false;
    let escaped = false;
    for (let index = start; index < content.length; index++) {
        const char = content[index];
        if (inString) {
            if (escaped) {
                escaped = false;
            } else if (char === '\\') {
                escaped = true;
            } else if (char === '"') {
                inString = false;
            }
        } else if (char === '"') {
            inString = true;
        } else if (char === '{') {
            depth++;
        } else if (char === '}') {
            depth--;
            if (depth === 0) {
                return { raw: content.slice(start, index + 1), end: index + 1 };
            }
        }
    }
    return null;
}

function repairConcatenatedCoverageJson(content: string): string | null {
    try {
        JSON.parse(content);
        // DevEco's isSurroundedByCurlyBrace uses startsWith/endsWith without trim.
        // A valid JSON document ending in a newline is otherwise wrapped again as { { ... } }.
        return content.trim();
    } catch (_) {
    }

    const entries: string[] = [];
    let index = content.indexOf('{') + 1;
    while (index > 0 && index < content.length) {
        index = skipWhitespace(content, index);
        while (index < content.length && (content[index] === '{' || content[index] === '}' ||
            content[index] === ',')) {
            index = skipWhitespace(content, index + 1);
        }
        if (index >= content.length) {
            break;
        }
        if (content[index] !== '"') {
            return null;
        }
        const key = readJsonString(content, index);
        if (key === null) {
            return null;
        }
        index = skipWhitespace(content, key.end);
        if (content[index] !== ':') {
            return null;
        }
        index = skipWhitespace(content, index + 1);
        const value = readJsonObject(content, index);
        if (value === null) {
            return null;
        }
        entries.push(`${JSON.stringify(key.value)}:${value.raw}`);
        index = value.end;
    }
    if (entries.length === 0) {
        return null;
    }
    const repaired = `{\n${entries.join(',\n')}\n}\n`;
    JSON.parse(repaired);
    return repaired;
}

function initCoveragePaths(): string[] {
    const projectRoot = path.resolve(__dirname, '../..');
    const result: string[] = [];
    for (const group of ['commons', 'scenes', 'product']) {
        const groupPath = path.resolve(projectRoot, group);
        if (!fs.existsSync(groupPath)) {
            continue;
        }
        for (const moduleName of fs.readdirSync(groupPath)) {
            result.push(path.resolve(groupPath, moduleName,
                '.test/default/intermediates/ohosTest/init_coverage.json'));
        }
    }
    return result;
}

const sanitizeInitCoveragePlugin: HvigorPlugin = {
    pluginId: 'agency_sanitize_init_coverage_before_report',
    apply(node) {
        node.afterNodeEvaluate(() => {
            const task = node.getTaskByName('default@GenerateDeviceCoverage')
                ?? node.getTaskByName('GenerateDeviceCoverage');
            if (!task) {
                return;
            }
            task.beforeRun(() => {
                // Hvigor scans stale coverage intermediates from unrelated modules. A previous
                // schedule run is not an agency dependency and can be appended again after this
                // hook, so exclude that generated artifact from the agency report entirely.
                const staleScheduleCoverage = path.resolve(__dirname,
                    '../schedule/.test/default/intermediates/ohosTest/init_coverage.json');
                if (fs.existsSync(staleScheduleCoverage)) {
                    fs.unlinkSync(staleScheduleCoverage);
                }
                const staleComponentCoverage = path.resolve(__dirname,
                    '../../commons/component_lib/.test/default/intermediates/ohosTest/init_coverage.json');
                if (fs.existsSync(staleComponentCoverage)) {
                    fs.unlinkSync(staleComponentCoverage);
                }
                for (const coveragePath of initCoveragePaths()) {
                    if (!fs.existsSync(coveragePath)) {
                        continue;
                    }
                    const original = fs.readFileSync(coveragePath, 'utf-8');
                    const repaired = repairConcatenatedCoverageJson(original);
                    if (repaired !== null && repaired !== original) {
                        fs.writeFileSync(coveragePath, repaired);
                    }
                }
            });
        });
    }
};

export default {
    system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[replaceOhosTestIndexPlugin, sanitizeInitCoveragePlugin]
    /* Custom plugin to extend the functionality of Hvigor. */
}
