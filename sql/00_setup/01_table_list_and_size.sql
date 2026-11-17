-- 프로젝트: 이커머스 첫 구매 전환 개선 분석
-- 데이터: bigquery-public-data.ga4_obfuscated_sample_ecommerce (2020-11-01 ~ 2021-01-31, 위치 US)
-- 목적: 일자별 테이블 목록과 크기 확인 (메타데이터만 읽어 처리량 거의 0)
-- 예상(추정): 92행, events_20201101 ~ events_20210131. size_mb 합계 = 전체 스캔 1회 비용의 상한

SELECT
  table_id,
  row_count,
  ROUND(size_bytes / POW(1024, 2), 1) AS size_mb
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.__TABLES__`
ORDER BY table_id;
