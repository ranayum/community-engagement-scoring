-- New generic example: capped progress toward a configurable target.
-- No original tier thresholds or metric definitions are reproduced.
CREATE VIEW dbo.vw_metric_scores AS
WITH totals AS (
    SELECT
        g.group_id,
        m.metric_key,
        m.dimension_key,
        m.target_value,
        m.metric_weight,
        COALESCE(SUM(a.metric_value), 0) AS raw_value
    FROM dbo.community_groups g
    CROSS JOIN dbo.metric_definitions m
    CROSS JOIN dbo.scoring_period p
    LEFT JOIN dbo.vw_activity a
        ON a.group_id = g.group_id
       AND a.metric_key = m.metric_key
       AND a.activity_date >= p.start_date
       AND a.activity_date < p.end_date_exclusive
    GROUP BY g.group_id, m.metric_key, m.dimension_key,
             m.target_value, m.metric_weight
)
SELECT group_id, metric_key, dimension_key, metric_weight, raw_value,
       CASE
           WHEN raw_value <= 0 THEN 0.0
           WHEN raw_value >= target_value THEN 100.0
           ELSE CAST(raw_value AS float) / NULLIF(target_value, 0) * 100.0
       END AS metric_score
FROM totals;
