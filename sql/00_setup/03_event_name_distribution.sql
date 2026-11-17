-- 프로젝트: 이커머스 첫 구매 전환 개선 분석
-- 데이터: bigquery-public-data.ga4_obfuscated_sample_ecommerce (2020-11-01 ~ 2021-01-31, 위치 US)
-- 목적: event_name 분포 확인 (첫 주만 읽어 처리량 절약) → 1주차 퍼널 단계 정의의 출발점
-- 예상(추정): page_view 최다, 퍼널 add_to_cart → begin_checkout → add_shipping_info
--            → add_payment_info → purchase 순으로 급감, purchase는 전체의 1% 미만

SELECT
  event_name,
  COUNT(*) AS events,
  COUNT(DISTINCT user_pseudo_id) AS users,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201107'
GROUP BY event_name
ORDER BY events DESC;
