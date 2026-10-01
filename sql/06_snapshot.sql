-- Run only after input validation. Existing group/date snapshots are preserved.
-- Sequential reruns are safe; concurrent writers require deployment coordination.
INSERT INTO dbo.score_history (snapshot_date, group_id, overall_score)
SELECT p.snapshot_date, s.group_id, s.overall_score
FROM dbo.vw_overall_scores s
CROSS JOIN dbo.scoring_period p
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.score_history h
    WHERE h.snapshot_date = p.snapshot_date AND h.group_id = s.group_id
);
