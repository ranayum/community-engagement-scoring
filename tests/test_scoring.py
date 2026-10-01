"""Execute the public SQL in an isolated SQLite database using synthetic facts.

This checks the example's calculations, not Fabric deployment compatibility.
"""
from pathlib import Path
import sqlite3
import unittest

ROOT = Path(__file__).resolve().parents[1]


def load_example():
    db = sqlite3.connect(':memory:')
    db.execute("ATTACH DATABASE ':memory:' AS dbo")
    for filename in ['01_tables.sql', '02_activity_view.sql', '03_metric_scores.sql',
                     '04_dimension_scores.sql', '05_overall_scores.sql']:
        db.executescript((ROOT/'sql'/filename).read_text())
    db.executescript((ROOT/'examples/synthetic_data.sql').read_text())
    return db


class ScoringTests(unittest.TestCase):
    def setUp(self):
        self.db = load_example()

    def tearDown(self):
        self.db.close()

    def issues(self):
        return [r[0] for r in self.db.execute((ROOT/'sql/validate_inputs.sql').read_text())]

    def scores(self):
        self.assertEqual(self.issues(), [])
        return dict(self.db.execute('SELECT group_id, overall_score FROM dbo.vw_overall_scores'))

    def test_expected_scores(self):
        actual = self.scores()
        for key, expected in {'DEMO-A': 88, 'DEMO-B': 30, 'DEMO-C': 0}.items():
            self.assertAlmostEqual(actual[key], expected)

    def test_score_cap(self):
        self.db.execute("UPDATE dbo.activity_facts SET metric_value=800 WHERE group_id='DEMO-A' AND metric_key='DEMO_TASK'")
        self.assertAlmostEqual(self.scores()['DEMO-A'], 88)

    def test_manual_facts_contribute(self):
        self.db.execute('DELETE FROM dbo.manual_facts')
        self.assertAlmostEqual(self.scores()['DEMO-A'], 48)

    def test_date_boundaries(self):
        for day in ['2024-12-31', '2025-02-01']:
            self.db.execute('INSERT INTO dbo.activity_facts VALUES (?, ?, ?, ?)',
                            ('DEMO-C', 'DEMO_TASK', day, 8))
        self.assertAlmostEqual(self.scores()['DEMO-C'], 0)
        self.db.execute("INSERT INTO dbo.activity_facts VALUES ('DEMO-C','DEMO_TASK','2025-01-01',8)")
        self.assertAlmostEqual(self.scores()['DEMO-C'], 40)

    def test_snapshot_preserves_existing_rows(self):
        self.scores()
        capture = (ROOT/'sql/06_snapshot.sql').read_text()
        self.db.executescript(capture)
        self.db.execute('DELETE FROM dbo.manual_facts')
        self.db.executescript(capture)
        rows = dict(self.db.execute('SELECT group_id, overall_score FROM dbo.score_history'))
        self.assertEqual(len(rows), 3)
        self.assertEqual(self.db.execute('SELECT COUNT(*) FROM dbo.score_history').fetchone()[0], 3)
        self.assertAlmostEqual(rows['DEMO-A'], 88)
        self.db.execute("UPDATE dbo.scoring_period SET snapshot_date='2025-02-02'")
        self.db.executescript(capture)
        self.assertEqual(self.db.execute('SELECT COUNT(*) FROM dbo.score_history').fetchone()[0], 6)

    def test_invalid_configuration_detected(self):
        self.db.execute('UPDATE dbo.metric_definitions SET target_value=0')
        self.assertIn('invalid_metric_configuration', self.issues())
        self.db.execute('INSERT INTO dbo.scoring_period SELECT * FROM dbo.scoring_period')
        self.assertIn('expected_one_period', self.issues())

    def test_unknown_or_negative_facts_detected(self):
        self.db.execute("INSERT INTO dbo.manual_facts VALUES ('UNKNOWN','DEMO_TASK','2025-01-01',-1)")
        self.assertIn('invalid_fact', self.issues())

    def test_duplicate_configuration_detected(self):
        self.db.execute('INSERT INTO dbo.metric_definitions SELECT * FROM dbo.metric_definitions')
        self.assertIn('duplicate_metric', self.issues())

    def test_weight_normalization(self):
        self.db.execute('UPDATE dbo.scoring_dimensions SET dimension_weight=dimension_weight*10')
        self.db.execute('UPDATE dbo.metric_definitions SET metric_weight=metric_weight*10')
        self.assertAlmostEqual(self.scores()['DEMO-A'], 88)


if __name__ == '__main__':
    unittest.main()
