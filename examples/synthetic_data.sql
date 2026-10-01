-- All names, dates, targets, weights, and observations below are invented.
-- These values do not represent any organization's scoring policy or results.
INSERT INTO dbo.community_groups (group_id, group_label)
VALUES ('DEMO-A', 'Example Group A'), ('DEMO-B', 'Example Group B'),
       ('DEMO-C', 'Example Group C');
INSERT INTO dbo.scoring_dimensions (dimension_key, dimension_weight)
VALUES ('Activity', 6), ('Learning', 4);
INSERT INTO dbo.metric_definitions
    (metric_key, dimension_key, target_value, metric_weight)
VALUES ('DEMO_TASK', 'Activity', 8, 2),
       ('DEMO_SESSION', 'Activity', 5, 1),
       ('DEMO_NOTE', 'Learning', 3, 1);
INSERT INTO dbo.scoring_period (start_date, end_date_exclusive, snapshot_date)
VALUES ('2025-01-01', '2025-02-01', '2025-01-31');
INSERT INTO dbo.activity_facts (group_id, metric_key, activity_date, metric_value)
VALUES ('DEMO-A', 'DEMO_TASK', '2025-01-10', 8),
       ('DEMO-A', 'DEMO_SESSION', '2025-01-12', 2),
       ('DEMO-B', 'DEMO_TASK', '2025-01-10', 2),
       ('DEMO-B', 'DEMO_SESSION', '2025-01-12', 5);
INSERT INTO dbo.manual_facts (group_id, metric_key, activity_date, metric_value)
VALUES ('DEMO-A', 'DEMO_NOTE', '2025-01-15', 3);
