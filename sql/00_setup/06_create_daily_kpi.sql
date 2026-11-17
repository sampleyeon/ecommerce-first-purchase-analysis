-- 프로젝트: 이커머스 첫 구매 전환 개선 분석
-- 데이터: bigquery-public-data.ga4_obfuscated_sample_ecommerce (2020-11-01 ~ 2021-01-31, 위치 US)
-- 목적: Power BI 연결 테스트용 일별 KPI 집계 테이블 생성 (내 데이터셋 ecom_analysis, 위치 US)
-- 참고: 샌드박스는 DML 불가·60일 만료 → CREATE OR REPLACE로 언제든 다시 생성

CREATE OR REPLACE TABLE `ecom_analysis.daily_kpi` AS
SELECT
  PARSE_DATE('%Y%m%d', event_date)     AS dt,
  COUNT(DISTINCT user_pseudo_id)       AS users,
  COUNTIF(event_name = 'purchase')     AS purchases,
  SUM(ecommerce.purchase_revenue_in_usd) AS revenue_usd
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY dt;
