-- 프로젝트: 이커머스 첫 구매 전환 개선 분석
-- 데이터: bigquery-public-data.ga4_obfuscated_sample_ecommerce (2020-11-01 ~ 2021-01-31, 위치 US)
-- 목적: 중첩 구조(event_params) 맛보기 - 세션 ID, 기기, 채널 꺼내기
-- 참고: 세션 = user_pseudo_id + ga_session_id
--       traffic_source는 사용자의 '최초 유입' 채널 (지표 정의에 명시할 것)
--       비식별화 데이터라 '<Other>', '(data deleted)' 값이 섞일 수 있음

SELECT
  user_pseudo_id,
  TIMESTAMP_MICROS(event_timestamp) AS event_ts,
  event_name,
  (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS ga_session_id,
  device.category       AS device_category,
  traffic_source.medium AS first_medium,
  traffic_source.source AS first_source
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20201201`
ORDER BY user_pseudo_id, event_ts
LIMIT 50;
