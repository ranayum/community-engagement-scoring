CREATE VIEW dbo.vw_dimension_scores AS
SELECT s.group_id, s.dimension_key, d.dimension_weight,
       SUM(s.metric_score * s.metric_weight)
           / NULLIF(SUM(s.metric_weight), 0) AS dimension_score
FROM dbo.vw_metric_scores s
JOIN dbo.scoring_dimensions d ON d.dimension_key = s.dimension_key
GROUP BY s.group_id, s.dimension_key, d.dimension_weight;
