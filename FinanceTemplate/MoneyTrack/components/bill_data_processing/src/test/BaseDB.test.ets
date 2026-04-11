import { relationalStore } from '@kit.ArkData';
import {
  describe,
  beforeEach,
  afterEach,
  it,
  expect,
  MockKit,
} from '@ohos/hypium';
import { DBOperator } from '../main/ets/utils/basedb/Constants';
import { BaseDB } from '../main/ets/utils/basedb/BaseDB';
import {
  TablePredicateParams,
  TableSchema,
} from '../main/ets/utils/basedb/Types';

const TEST_TABLE_NAME = 'base_db_test_table';
const TEST_FIELD_NAME = 'testField';

interface PredicatesPrototypeMethods {
  equalTo: Function;
  notEqualTo: Function;
  greaterThan: Function;
  greaterThanOrEqualTo: Function;
  lessThan: Function;
  lessThanOrEqualTo: Function;
  like: Function;
  isNull: Function;
  isNotNull: Function;
  beginsWith: Function;
  endsWith: Function;
  contains: Function;
}

class FakeResultSet {
  public rowCount: number = 0;

  public goToRow(_index: number): void {
  }

  public getRow(): relationalStore.ValuesBucket {
    return {};
  }
}

class FakeRdbStore {
  public lastPredicates: relationalStore.RdbPredicates | null = null;

  public async update(
    _values: relationalStore.ValuesBucket,
    predicates: relationalStore.RdbPredicates,
  ): Promise<number> {
    this.lastPredicates = predicates;
    return 1;
  }

  public async delete(
    predicates: relationalStore.RdbPredicates,
  ): Promise<number> {
    this.lastPredicates = predicates;
    return 1;
  }

  public async query(
    predicates: relationalStore.RdbPredicates,
    _columns?: string[],
  ): Promise<relationalStore.ResultSet> {
    this.lastPredicates = predicates;
    return new FakeResultSet() as Object as relationalStore.ResultSet;
  }
}

class TestBaseDB extends BaseDB {
  protected dbConfig: relationalStore.StoreConfig = {
    name: 'BaseDBTest.db',
    securityLevel: relationalStore.SecurityLevel.S1,
    encrypt: false,
  };
  protected tableSchemas: TableSchema[] = [];

  public useStoreForTest(store: FakeRdbStore): void {
    this.rdbStore = store as Object as relationalStore.RdbStore;
  }

  public async runQueryForTest(
    conditions: TablePredicateParams[],
  ): Promise<void> {
    await this.query<relationalStore.ValuesBucket>(TEST_TABLE_NAME, conditions);
  }

  public async runUpdateForTest(
    conditions: TablePredicateParams[],
  ): Promise<number> {
    return this.update<relationalStore.ValuesBucket>(
      TEST_TABLE_NAME,
      { testValue: 1 },
      conditions,
    );
  }

  public async runDeleteForTest(
    conditions: TablePredicateParams[],
  ): Promise<number> {
    return this.delete(TEST_TABLE_NAME, conditions);
  }
}

export default function BaseDBTest() {
  describe('BaseDBTest', () => {
    const testDB = new TestBaseDB();
    const fakeStore = new FakeRdbStore();
    const predicatesPrototype = relationalStore.RdbPredicates.prototype as Object;
    const predicateMethods =
      relationalStore.RdbPredicates.prototype as Object as PredicatesPrototypeMethods;
    let mocker: MockKit;

    const mockPredicateMethod = (methodName: string) => {
      switch (methodName) {
        case 'equalTo':
          mocker.mockFunc(predicatesPrototype, predicateMethods.equalTo);
          break;
        case 'notEqualTo':
          mocker.mockFunc(predicatesPrototype, predicateMethods.notEqualTo);
          break;
        case 'greaterThan':
          mocker.mockFunc(predicatesPrototype, predicateMethods.greaterThan);
          break;
        case 'greaterThanOrEqualTo':
          mocker.mockFunc(
            predicatesPrototype,
            predicateMethods.greaterThanOrEqualTo,
          );
          break;
        case 'lessThan':
          mocker.mockFunc(predicatesPrototype, predicateMethods.lessThan);
          break;
        case 'lessThanOrEqualTo':
          mocker.mockFunc(
            predicatesPrototype,
            predicateMethods.lessThanOrEqualTo,
          );
          break;
        case 'like':
          mocker.mockFunc(predicatesPrototype, predicateMethods.like);
          break;
        case 'isNull':
          mocker.mockFunc(predicatesPrototype, predicateMethods.isNull);
          break;
        case 'isNotNull':
          mocker.mockFunc(predicatesPrototype, predicateMethods.isNotNull);
          break;
        case 'beginsWith':
          mocker.mockFunc(predicatesPrototype, predicateMethods.beginsWith);
          break;
        case 'endsWith':
          mocker.mockFunc(predicatesPrototype, predicateMethods.endsWith);
          break;
        case 'contains':
          mocker.mockFunc(predicatesPrototype, predicateMethods.contains);
          break;
        default:
          break;
      }
    };

    const expectQueryUsesOperator = async (
      operator: DBOperator,
      methodName: string,
      value: string | number,
    ) => {
      mockPredicateMethod(methodName);
      await testDB.runQueryForTest([
        { field: TEST_FIELD_NAME, value, operator },
      ]);
      mocker.verify(methodName, [TEST_FIELD_NAME, value]).once();
      expect(fakeStore.lastPredicates !== null).assertEqual(true);
    };

    const expectQueryUsesFieldOnlyOperator = async (
      operator: DBOperator,
      methodName: string,
    ) => {
      mockPredicateMethod(methodName);
      await testDB.runQueryForTest([
        { field: TEST_FIELD_NAME, value: '', operator },
      ]);
      mocker.verify(methodName, [TEST_FIELD_NAME]).once();
      expect(fakeStore.lastPredicates !== null).assertEqual(true);
    };

    beforeEach(() => {
      mocker = new MockKit();
      fakeStore.lastPredicates = null;
      testDB.useStoreForTest(fakeStore);
    });

    afterEach(() => {
      mocker.clear(predicatesPrototype);
    });

    it('maps EQUAL to equalTo', 0, async () => {
      await expectQueryUsesOperator(DBOperator.EQUAL, 'equalTo', 1);
    });

    it('maps NOT_EQUAL to notEqualTo', 0, async () => {
      await expectQueryUsesOperator(DBOperator.NOT_EQUAL, 'notEqualTo', 2);
    });

    it('maps GREATER to greaterThan', 0, async () => {
      await expectQueryUsesOperator(DBOperator.GREATER, 'greaterThan', 3);
    });

    it('maps GREATER_OR_EQUAL to greaterThanOrEqualTo', 0, async () => {
      await expectQueryUsesOperator(
        DBOperator.GREATER_OR_EQUAL,
        'greaterThanOrEqualTo',
        4,
      );
    });

    it('maps LESS to lessThan', 0, async () => {
      await expectQueryUsesOperator(DBOperator.LESS, 'lessThan', 5);
    });

    it('maps LESS_OR_EQUAL to lessThanOrEqualTo', 0, async () => {
      await expectQueryUsesOperator(
        DBOperator.LESS_OR_EQUAL,
        'lessThanOrEqualTo',
        6,
      );
    });

    it('maps LIKE to like', 0, async () => {
      await expectQueryUsesOperator(DBOperator.LIKE, 'like', '%key%');
    });

    it('maps IS_NULL to isNull', 0, async () => {
      await expectQueryUsesFieldOnlyOperator(DBOperator.IS_NULL, 'isNull');
    });

    it('maps IS_NOT_NULL to isNotNull', 0, async () => {
      await expectQueryUsesFieldOnlyOperator(
        DBOperator.IS_NOT_NULL,
        'isNotNull',
      );
    });

    it('maps BEGIN_WITH to beginsWith', 0, async () => {
      await expectQueryUsesOperator(
        DBOperator.BEGIN_WITH,
        'beginsWith',
        'start',
      );
    });

    it('maps END_WITH to endsWith', 0, async () => {
      await expectQueryUsesOperator(DBOperator.END_WITH, 'endsWith', 'end');
    });

    it('maps CONTAIN to contains', 0, async () => {
      await expectQueryUsesOperator(DBOperator.CONTAIN, 'contains', 'part');
    });

    it('ignores unsupported operators', 0, async () => {
      mockPredicateMethod('equalTo');
      await testDB.runQueryForTest([
        { field: TEST_FIELD_NAME, value: 1, operator: 99 as DBOperator },
      ]);
      mocker.verify('equalTo', [TEST_FIELD_NAME, 1]).never();
      expect(fakeStore.lastPredicates !== null).assertEqual(true);
    });

    it('applies each condition in sequence', 0, async () => {
      mockPredicateMethod('equalTo');
      mockPredicateMethod('isNotNull');

      await testDB.runQueryForTest([
        {
          field: 'firstField',
          value: 1,
          operator: DBOperator.EQUAL,
        },
        {
          field: 'secondField',
          value: '',
          operator: DBOperator.IS_NOT_NULL,
        },
      ]);

      mocker.verify('equalTo', ['firstField', 1]).once();
      mocker.verify('isNotNull', ['secondField']).once();
    });

    it('feeds built predicates into update', 0, async () => {
      mockPredicateMethod('equalTo');

      const result = await testDB.runUpdateForTest([
        { field: TEST_FIELD_NAME, value: 7, operator: DBOperator.EQUAL },
      ]);

      expect(result).assertEqual(1);
      mocker.verify('equalTo', [TEST_FIELD_NAME, 7]).once();
      expect(fakeStore.lastPredicates !== null).assertEqual(true);
    });

    it('feeds built predicates into delete', 0, async () => {
      mockPredicateMethod('lessThan');

      const result = await testDB.runDeleteForTest([
        { field: TEST_FIELD_NAME, value: 8, operator: DBOperator.LESS },
      ]);

      expect(result).assertEqual(1);
      mocker.verify('lessThan', [TEST_FIELD_NAME, 8]).once();
      expect(fakeStore.lastPredicates !== null).assertEqual(true);
    });
  });
}
