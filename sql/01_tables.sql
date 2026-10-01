-- Generic interfaces for the public example. No original system schema is used.
CREATE TABLE dbo.community_groups (
    group_id varchar(40) NOT NULL,
    group_label varchar(100) NOT NULL
);
CREATE TABLE dbo.scoring_dimensions (
    dimension_key varchar(40) NOT NULL,
    dimension_weight decimal(12,4) NOT NULL
);
CREATE TABLE dbo.metric_definitions (
    metric_key varchar(40) NOT NULL,
    dimension_key varchar(40) NOT NULL,
    target_value decimal(12,4) NOT NULL,
    metric_weight decimal(12,4) NOT NULL
);
CREATE TABLE dbo.activity_facts (
    group_id varchar(40) NOT NULL,
    metric_key varchar(40) NOT NULL,
    activity_date date NOT NULL,
    metric_value decimal(12,4) NOT NULL
);
CREATE TABLE dbo.manual_facts (
    group_id varchar(40) NOT NULL,
    metric_key varchar(40) NOT NULL,
    activity_date date NOT NULL,
    metric_value decimal(12,4) NOT NULL
);
CREATE TABLE dbo.scoring_period (
    start_date date NOT NULL,
    end_date_exclusive date NOT NULL,
    snapshot_date date NOT NULL
);
CREATE TABLE dbo.score_history (
    snapshot_date date NOT NULL,
    group_id varchar(40) NOT NULL,
    overall_score decimal(12,4) NOT NULL
);
