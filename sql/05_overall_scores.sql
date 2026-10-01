CREATE VIEW dbo.vw_overall_scores AS
SELECT group_id,
       SUM(dimension_score * dimension_weight)
           / NULLIF(SUM(dimension_weight), 0) AS overall_score
FROM dbo.vw_dimension_scores
GROUP BY group_id;
