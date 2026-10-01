-- Automatic and manual facts share the same input contract.
CREATE VIEW dbo.vw_activity AS
SELECT group_id, metric_key, activity_date, metric_value
FROM dbo.activity_facts
UNION ALL
SELECT group_id, metric_key, activity_date, metric_value
FROM dbo.manual_facts;
