import { harTasks } from '@ohos/hvigor-ohos-plugin';
import { hvigor, HvigorNode } from '@ohos/hvigor';
import * as fs from 'fs';
import * as path from 'path';

const SOURCE_RELATIVE: string = 'src/ohosTest/ets/testability/pages/Index.ets';
const DEST_RELATIVE: string = 'build/default/intermediates/src/ohosTest/ets/testability/pages/Index.ets';

function copyTestabilityIndex(moduleDir: string): void {
  const src: string = path.join(moduleDir, SOURCE_RELATIVE);
  const dst: string = path.join(moduleDir, DEST_RELATIVE);
  if (!fs.existsSync(src)) {
    return;
  }
  const content: string = fs.readFileSync(src, 'utf8');
  // Rewrite relative imports so they resolve correctly from the generated intermediates directory.
  const rewritten: string = content.replace(/\.\.\/\.\.\/\.\.\/\.\.\/main\/ets\//g, '../../../../../../../../src/main/ets/');
  fs.mkdirSync(path.dirname(dst), { recursive: true });
  fs.writeFileSync(dst, rewritten, 'utf8');
}

function nodeDir(n: HvigorNode): string {
  const dirObj: object = n.getNodeDir() as object;
  if (typeof dirObj === 'string') {
    return dirObj as unknown as string;
  }
  const dirAny: Record<string, unknown> = dirObj as Record<string, unknown>;
  if (typeof dirAny.path === 'string') {
    return dirAny.path as string;
  }
  if (typeof dirAny.absolutePath === 'string') {
    return dirAny.absolutePath as string;
  }
  if (typeof n.getNodePath === 'function') {
    return n.getNodePath();
  }
  return '';
}

hvigor.nodesEvaluated(() => {
  const node: HvigorNode | undefined = hvigor.getNodeByName('business_home');
  if (!node) {
    return;
  }
  // Skip during project sync / non-ohosTest builds where ohosTest tasks are not instantiated.
  const nAny: Record<string, Function> = node as unknown as Record<string, Function>;
  const hasTask: (name: string) => boolean = typeof nAny.hasTask === 'function'
    ? (nAny.hasTask as (name: string) => boolean).bind(node)
    : (name: string): boolean => node.getTaskByName(name) !== undefined;
  if (!hasTask('ohosTest@GenerateOhosTestTemplate')) {
    return;
  }
  const moduleDir: string = nodeDir(node);
  node.registerTask({
    name: 'ohosTest@CopyTestabilityIndex',
    run: () => {
      copyTestabilityIndex(moduleDir);
    },
    dependencies: ['ohosTest@GenerateOhosTestTemplate'],
    postDependencies: hasTask('ohosTest@OhosTestCompileArkTS')
      ? ['ohosTest@OhosTestCompileArkTS']
      : []
  });
});

export default {
    system: harTasks,
    plugins: []
}
