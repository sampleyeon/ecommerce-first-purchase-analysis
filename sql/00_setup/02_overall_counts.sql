-- 프로젝트: 이커머스 첫 구매 전환 개선 분석
-- 데이터: bigquery-public-data.ga4_obfuscated_sample_ecommerce (2020-11-01 ~ 2021-01-31, 위치 US)
-- 목적: 전체 이벤트 수, 사용자 수, 날짜 범위 확인
-- 예상(추정): 이벤트 약 400만 건대, 사용자 약 27만 명, 20201101 ~ 20210131, 92일
-- 참고: event_date는 'YYYYMMDD' 문자열 → 날짜 계산은 PARSE_DATE('%Y%m%d', event_date)

SELECT
  COUNT(*)                       AS events,
  COUNT(DISTINCT user_pseudo_id) AS users,
  MIN(event_date)                AS first_date,
  MAX(event_date)                AS last_date,
  COUNT(DISTINCT event_date)     AS days
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131';
