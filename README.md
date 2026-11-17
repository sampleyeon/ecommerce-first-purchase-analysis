# 이커머스 첫 구매 전환 개선 분석

GA4 이커머스 로그로 **첫 구매 전환이 어디서 막히는지** 찾고, A/B 테스트로 개선안을 검증해 출시 여부까지 판단하는 3주 프로젝트입니다.

> 온라인 쇼핑몰을 직접 운영한 경험을 가설의 근거로 활용합니다. 데이터로 확인한 이탈 지점을 실제 운영에서 겪었던 문제와 연결해 실행 가능한 액션을 제안하는 것이 목표입니다.

## 분석 질문 (1주차에 확정, 5개 이내)

1. 방문부터 구매까지 퍼널의 어느 단계에서 가장 많이 이탈하는가?
2. 유입 채널·기기에 따라 첫 구매 전환율은 얼마나 다른가?
3. 첫 방문 주차별 코호트는 얼마나 다시 방문하는가?
4. 어떤 상품이 함께 구매되는가? (교차 판매 기회)
5. 개선안(실험)은 전환율을 유의하게 높였고, 출시해도 되는가?

## 데이터

| 데이터 | 출처 | 기간·규모 |
|---|---|---|
| GA4 이커머스 샘플 | BigQuery `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` | 2020-11-01 ~ 2021-01-31 (92일) |
| A/B 테스트 | Kaggle [zhangluyuan/ab-testing](https://www.kaggle.com/datasets/zhangluyuan/ab-testing) `ab_data.csv` | 약 29만 행 |

데이터 파일은 저장소에 올리지 않습니다. 받는 방법은 [data/README.md](data/README.md)에 있습니다.

## 진행 단계

| 주차 | 도구 | 내용 | 상태 |
|---|---|---|---|
| 0 | BigQuery | 샌드박스 세팅, 데이터 동작 확인 | 완료 |
| 1 | SQL | 지표 정의, 퍼널 단계별 이탈, 채널·기기별 전환, 주차별 코호트 재방문, 함께 구매되는 상품 쌍 | 예정 |
| 2 | SQL + Python | 실험 설계서(가설, 주 지표, 가드레일, 표본 수), ab_data 정제, SRM 체크, 유의성 검정, 출시 판단 | 예정 |
| 3 | Power BI | KPI 요약 / 퍼널·코호트 / 실험 결과 3페이지 + 한 장 요약(문제 → 근거 → 실험 결과 → 제안 액션) | 예정 |

## 폴더 구조

```
.
├── sql/
│   ├── 00_setup/   # 데이터 동작 확인 쿼리, 집계 테이블 생성
│   └── week1/      # 1주차 분석 SQL
├── python/         # 2주차 A/B 테스트 분석 노트북
├── powerbi/        # 3주차 대시보드(.pbix)와 캡처
├── docs/           # 세팅 가이드, 지표 정의, 실험 설계서
└── data/           # 로컬 데이터 (GitHub에 올리지 않음)
```

## 환경

- BigQuery 샌드박스 (카드 등록 없음, 위치 US, 내 데이터셋 `ecom_analysis`)
- Python 3.10+ (`google-cloud-bigquery`, `pandas`)
- Power BI Desktop
- 세팅 방법: [docs/bigquery-setup-guide.md](docs/bigquery-setup-guide.md)
