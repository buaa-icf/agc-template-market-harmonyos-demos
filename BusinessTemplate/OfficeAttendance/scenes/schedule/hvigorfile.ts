import fs from 'fs';
import path from 'path';
import { hvigor } from '@ohos/hvigor';
import { harTasks } from '@ohos/hvigor-ohos-plugin';
import type { HvigorPlugin } from '@ohos/hvigor';

const ON_DEVICE_TEST_TASK = 'onDeviceTest';
const GENERATE_OHOS_TEST_TEMPLATE_TASK = 'ohosTest@GenerateOhosTestTemplate';
const OHOS_TEST_COMPILE_ARK_TS_TASK = 'ohosTest@OhosTestCompileArkTS';
const BEFORE_GENERATE_DEVICE_COVERAGE_TASK = 'default@BeforeGenerateDeviceCoverage';
const GENERATE_DEVICE_COVERAGE_TASK = 'default@GenerateDeviceCoverage';

function skipWhitespace(content: string, index: number): number {
    while (index < content.length && /\s/.test(content[index])) {
        index++;
    }
    return index;
}

function readJsonString(content: string, startIndex: number): { value: string, endIndex: number } | null {
    if (content[startIndex] !== '"') {
        return null;
    }

    let index = startIndex + 1;
    let escaped = false;
    while (index < content.length) {
        const char = content[index];
        if (escaped) {
            escaped = false;
            index++;
            continue;
        }
        if (char === '\\') {
            escaped = true;
            index++;
            continue;
        }
        if (char === '"') {
            const raw = content.slice(startIndex, index + 1);
            return {
                value: JSON.parse(raw) as string,
                endIndex: index + 1
            };
        }
        index++;
    }

    return null;
}

function readJsonObject(content: string, startIndex: number): { value: string, endIndex: number } | null {
    if (content[startIndex] !== '{') {
        return null;
    }

    let index = startIndex;
    let depth = 0;
    let inString = false;
    let escaped = false;

    while (index < content.length) {
        const char = content[index];
        if (inString) {
            if (escaped) {
                escaped = false;
            } else if (char === '\\') {
                escaped = true;
            } else if (char === '"') {
                inString = false;
            }
            index++;
            continue;
        }

        if (char === '"') {
            inString = true;
            index++;
            continue;
        }

        if (char === '{') {
            depth++;
        } else if (char === '}') {
            depth--;
            if (depth === 0) {
                return {
                    value: content.slice(startIndex, index + 1),
                    endIndex: index + 1
                };
            }
        }

        index++;
    }

    return null;
}

function repairInitCoverageJson(content: string): string | null {
    try {
        JSON.parse(content);
        return content;
    } catch (_) {
    }

    const firstBraceIndex = content.indexOf('{');
    if (firstBraceIndex === -1) {
        return null;
    }

    const entries: string[] = [];
    let index = firstBraceIndex + 1;

    while (index < content.length) {
        index = skipWhitespace(content, index);
        while (index < content.length && (content[index] === ',' || content[index] === '}')) {
            index++;
            index = skipWhitespace(content, index);
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
        index = skipWhitespace(content, key.endIndex);
        if (content[index] !== ':') {
            return null;
        }

        index = skipWhitespace(content, index + 1);
        const value = readJsonObject(content, index);
        if (value === null) {
            return null;
        }

        entries.push(`${JSON.stringify(key.value)}:${value.value}`);
        index = value.endIndex;
    }

    if (entries.length === 0) {
        return null;
    }

    const repaired = `{\n${entries.join(',\n')}\n}\n`;
    JSON.parse(repaired);
    return repaired;
}

const replaceOhosTestIndexPlugin: HvigorPlugin = {
    pluginId: 'schedule_replace_ohos_test_index',
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
                    const targetPath = path.resolve(taskContext.modulePath,
                        'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets');

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

const sanitizeInitCoveragePlugin: HvigorPlugin = {
    pluginId: 'schedule_sanitize_init_coverage',
    apply(node) {
        hvigor.nodesEvaluated(() => {
            const entryTasks = new Set(hvigor.getCommandEntryTask() ?? []);
            if (!entryTasks.has(ON_DEVICE_TEST_TASK)) {
                return;
            }

            node.registerTask({
                name: 'SanitizeInitCoverageJson',
                dependencies: [BEFORE_GENERATE_DEVICE_COVERAGE_TASK],
                postDependencies: [GENERATE_DEVICE_COVERAGE_TASK],
                run(taskContext) {
                    const coveragePath = path.resolve(taskContext.modulePath,
                        '.test/default/intermediates/ohosTest/init_coverage.json');

                    if (!fs.existsSync(coveragePath)) {
                        return;
                    }

                    const original = fs.readFileSync(coveragePath, 'utf-8');
                    const repaired = repairInitCoverageJson(original);
                    if (repaired === null || repaired === original) {
                        return;
                    }

                    fs.writeFileSync(coveragePath, repaired);
                }
            });
        });
    }
};

export default {
    system: harTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[replaceOhosTestIndexPlugin, sanitizeInitCoveragePlugin]         /* Custom plugin to extend the functionality of Hvigor. */
}
