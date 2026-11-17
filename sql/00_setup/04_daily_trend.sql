-- 프로젝트: 이커머스 첫 구매 전환 개선 분석
-- 데이터: bigquery-public-data.ga4_obfuscated_sample_ecommerce (2020-11-01 ~ 2021-01-31, 위치 US)
-- 목적: 일별 추이로 데이터가 빈 날·이상치 확인 (결과 화면의 '차트' 탭으로 선 그래프)
-- 예상(추정): 11월 말(블랙프라이데이) ~ 12월 중순 구매 증가, 연말연시 감소

SELECT
  PARSE_DATE('%Y%m%d', event_date)           AS dt,
  COUNT(*)                                   AS events,
  COUNT(DISTINCT user_pseudo_id)             AS users,
  COUNTIF(event_name = 'purchase')           AS purchases,
  ROUND(SUM(ecommerce.purchase_revenue_in_usd), 0) AS revenue_usd
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY dt
ORDER BY dt;
