-- Must return zero rows before scoring or snapshot capture.
-- Tables are deliberately free of platform-specific enforced constraints.
SELECT 'expected_one_period' AS issue
WHERE (SELECT COUNT(*) FROM dbo.scoring_period) <> 1
UNION ALL
SELECT 'invalid_period' WHERE EXISTS (
    SELECT 1 FROM dbo.scoring_period WHERE start_date >= end_date_exclusive)
UNION ALL
SELECT 'duplicate_group' WHERE EXISTS (
    SELECT group_id FROM dbo.community_groups GROUP BY group_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'duplicate_metric' WHERE EXISTS (
    SELECT metric_key FROM dbo.metric_definitions GROUP BY metric_key HAVING COUNT(*) > 1)
UNION ALL
SELECT 'duplicate_dimension' WHERE EXISTS (
    SELECT dimension_key FROM dbo.scoring_dimensions GROUP BY dimension_key HAVING COUNT(*) > 1)
UNION ALL
SELECT 'invalid_metric_configuration' WHERE EXISTS (
    SELECT 1 FROM dbo.metric_definitions m
    WHERE m.target_value <= 0 OR m.metric_weight <= 0
       OR NOT EXISTS (SELECT 1 FROM dbo.scoring_dimensions d WHERE d.dimension_key = m.dimension_key))
UNION ALL
SELECT 'invalid_dimension_configuration' WHERE EXISTS (
    SELECT 1 FROM dbo.scoring_dimensions d
    WHERE d.dimension_weight <= 0
       OR NOT EXISTS (SELECT 1 FROM dbo.metric_definitions m WHERE m.dimension_key = d.dimension_key))
UNION ALL
SELECT 'empty_configuration' WHERE NOT EXISTS (SELECT 1 FROM dbo.metric_definitions)
UNION ALL
SELECT 'invalid_fact' WHERE EXISTS (
    SELECT 1 FROM dbo.vw_activity a
    WHERE a.metric_value < 0
       OR NOT EXISTS (SELECT 1 FROM dbo.community_groups g WHERE g.group_id = a.group_id)
       OR NOT EXISTS (SELECT 1 FROM dbo.metric_definitions m WHERE m.metric_key = a.metric_key));
