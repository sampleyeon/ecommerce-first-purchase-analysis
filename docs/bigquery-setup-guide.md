# BigQuery 샌드박스 세팅 가이드

카드 등록 없이 GA4 샘플 데이터를 BigQuery·Python·Power BI에서 조회하기 위한 환경 설정 기록입니다. 30~40분이면 끝납니다.

준비물: Google 계정, Windows 노트북의 Chrome, Python 3.10 이상, Power BI Desktop

1. GCP 프로젝트를 만들고 샌드박스 상태 확인
2. 공개 데이터셋 `bigquery-public-data.ga4_obfuscated_sample_ecommerce` 고정, 내 데이터셋 만들기(위치 US)
3. 비용 아끼는 습관 4가지 설정
4. 동작 확인 SQL 5개 실행 → [`sql/00_setup/`](../sql/00_setup)
5. Python 연결
6. Power BI 연결

> SQL은 공식 스키마 기준으로 작성했고, 아래 예상 결과는 모두 **추정**입니다. 실제 실행 결과로 갱신할 예정입니다.

## 1단계. GCP 프로젝트 만들고 샌드박스 확인

샌드박스는 따로 켜는 메뉴가 없습니다. 결제 계정 없이 프로젝트를 만들고 BigQuery를 열면 자동으로 샌드박스가 됩니다.

1. [console.cloud.google.com/bigquery](https://console.cloud.google.com/bigquery)에 접속해 Google 계정으로 로그인합니다.
2. 처음이면 국가(대한민국)를 고르고 서비스 약관에 동의합니다.
3. 상단 프로젝트 선택 드롭다운 → **새 프로젝트**
4. 프로젝트 이름을 예를 들어 `ecom-first-purchase`로 넣고 **프로젝트 ID**를 메모합니다.
   - 프로젝트 ID는 만든 뒤 바꿀 수 없으니 스크린샷에 나와도 괜찮은 이름으로 정합니다.
   - 조직은 “조직 없음”으로 둡니다.
5. **만들기** 후 상단에서 새 프로젝트가 선택되었는지 확인합니다.
6. BigQuery 화면 상단에 **샌드박스(Sandbox)** 배너가 보이면 성공입니다.

주의할 점
- 무료 체험(크레딧) 안내나 **업그레이드** 버튼은 누르지 않습니다. 카드 등록 화면으로 넘어갑니다.
- Python에서 `API not enabled` 오류가 나면 콘솔 검색창에 “BigQuery API”를 치고 **사용**을 누릅니다.

## 2단계. 공개 데이터셋 고정하고 내 데이터셋 만들기

GA4 샘플은 `bigquery-public-data` 프로젝트에 있고, 일자별 테이블 92개(`events_20201101` ~ `events_20210131`)로 나뉘어 있습니다. 저장 위치는 **US**입니다.

**공개 데이터셋 고정**
1. 왼쪽 **탐색기(Explorer)** 상단의 **+ 추가** → **이름으로 프로젝트 별표 표시** → `bigquery-public-data` 입력
2. `bigquery-public-data` → `ga4_obfuscated_sample_ecommerce` → `events_` 테이블 선택 (탐색기 검색창에 `ga4_obfuscated`를 쳐도 나옵니다)
3. **스키마** 탭에서 `event_params`, `items`가 REPEATED RECORD(배열)인 것을 확인합니다. 퍼널·상품 쌍 분석에서 `UNNEST`가 필요한 이유입니다.
4. **미리보기** 탭은 처리량을 쓰지 않습니다. 데이터 구조 구경은 여기서 합니다.

**내 데이터셋 만들기** (중간 결과·집계 테이블 저장용)
1. 탐색기에서 내 프로젝트 옆 ⋮ → **데이터세트 만들기**
2. 데이터세트 ID: `ecom_analysis`
3. 위치 유형: **멀티 리전 → US** (공개 데이터와 위치가 다르면 쿼리가 실패합니다)
4. 샌드박스는 테이블 만료가 60일로 고정이므로, 테이블을 만든 SQL은 이 저장소에 파일로 보관합니다.

2주차 `ab_data.csv`는 pandas로 바로 읽거나, `ecom_analysis`에서 **테이블 만들기 → 업로드 → CSV, 스키마 자동 감지**로 올립니다(콘솔 업로드 한도 100MB).

## 3단계. 샌드박스 한도와 비용 아끼는 법

| 항목 | 샌드박스 한도 | 이 프로젝트에서의 의미 |
|---|---|---|
| 쿼리 처리량 | 월 1TB | 추정상 여유 충분. 매달 1일 초기화 |
| 저장 용량 | 10GB | 집계 테이블만 저장하면 수십 MB 이하 |
| 테이블 만료 | 생성 후 60일 자동 삭제 | 만드는 SQL을 파일로 보관해 재생성 |
| DML(INSERT·UPDATE·DELETE) | 사용 불가 | `CREATE OR REPLACE TABLE ... AS SELECT`로 대체 |
| 스트리밍·예약 쿼리 | 사용 불가 | 필요 없음 |

비용 아끼는 습관
1. **실행 전에 처리량을 확인합니다.** 쿼리 편집기 오른쪽 위 “실행 시 ○○ MB를 처리합니다”가 과금 기준입니다.
2. **`_TABLE_SUFFIX`로 날짜를 걸러냅니다.** `events_*`는 92개 테이블 전체를 읽습니다. `WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201107'`처럼 쓰면 해당 테이블만 읽습니다. `event_date`로 걸러도 읽는 테이블은 줄지 않습니다.
3. **필요한 컬럼만 SELECT합니다.** BigQuery는 컬럼 단위로 과금합니다. `LIMIT`은 처리량을 줄이지 못합니다.
4. **안전장치를 겁니다.** 쿼리 설정 → 고급 옵션 → **최대 청구 바이트**에 `10000000000`(10GB)을 넣습니다.

자주 쓰는 중간 결과는 `ecom_analysis`에 테이블로 저장해 두면 이후 분석과 Power BI는 작은 테이블만 읽습니다.

## 4단계. 동작 확인 SQL

[`sql/00_setup/`](../sql/00_setup) 폴더의 파일을 순서대로 실행합니다.

| 파일 | 확인 내용 | 예상 결과(추정) |
|---|---|---|
| `01_table_list_and_size.sql` | 테이블 목록과 크기 | 92행 |
| `02_overall_counts.sql` | 이벤트·사용자 수, 날짜 범위 | 이벤트 약 400만, 사용자 약 27만, 92일 |
| `03_event_name_distribution.sql` | event_name 분포(첫 주) | page_view 최다, purchase 1% 미만 |
| `04_daily_trend.sql` | 일별 추이 | 블랙프라이데이~12월 중순 구매 증가 |
| `05_nested_fields_preview.sql` | 세션 ID·기기·채널 꺼내기 | 세션 = `user_pseudo_id` + `ga_session_id` |

메모
- `event_date`는 `'YYYYMMDD'` 문자열이라 날짜 계산에는 `PARSE_DATE('%Y%m%d', event_date)`를 씁니다.
- `traffic_source`는 사용자의 **최초 유입** 채널입니다. 채널별 전환 지표 정의에 명시합니다.
- 비식별화 데이터라 `<Other>`, `(data deleted)` 같은 값이 섞일 수 있습니다.

## 5단계. Python 연결

인증은 서비스 계정 키 파일 대신 **gcloud CLI 사용자 로그인(ADC)**을 씁니다. 키 파일을 실수로 GitHub에 올릴 위험이 없습니다.

1. [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)를 설치합니다.
2. PowerShell에서 로그인합니다.

```powershell
gcloud auth application-default login
gcloud auth application-default set-quota-project <프로젝트ID>
```

3. 가상환경과 패키지를 설치합니다. `db-dtypes`가 없으면 `to_dataframe()`에서 오류가 납니다.

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install google-cloud-bigquery db-dtypes pandas pyarrow jupyter
```

4. 연결 확인 코드 (dry run으로 처리량을 먼저 보고, 10GB 상한을 건 채로 실행)

```python
from google.cloud import bigquery

PROJECT_ID = "<프로젝트ID>"   # 예: ecom-first-purchase
client = bigquery.Client(project=PROJECT_ID)

sql = """
SELECT event_name, COUNT(*) AS events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201107'
GROUP BY event_name
ORDER BY events DESC
"""

# 1) 실행 전 처리량 확인 (과금 없음)
dry = client.query(sql, job_config=bigquery.QueryJobConfig(dry_run=True, use_query_cache=False))
print(f"예상 처리량: {dry.total_bytes_processed / 1024**2:,.1f} MB")

# 2) 10GB 넘는 쿼리는 실행 자체를 막는 안전장치
safe = bigquery.QueryJobConfig(maximum_bytes_billed=10 * 1024**3)
df = client.query(sql, job_config=safe).to_dataframe()
df.head(20)
```

## 6단계. Power BI Desktop 연결

Power BI에는 원본 이벤트가 아니라 **내 데이터셋의 집계 테이블**을 연결합니다. 원본을 연결하면 새로 고침 때마다 처리량이 쌓이기 때문입니다.

1. [`sql/00_setup/06_create_daily_kpi.sql`](../sql/00_setup/06_create_daily_kpi.sql)로 `ecom_analysis.daily_kpi` 테이블을 만듭니다.
2. Power BI Desktop → **홈 → 데이터 가져오기 → 자세히** → **Google BigQuery** → 연결
3. **청구 프로젝트 ID**에 내 프로젝트 ID 입력 → **로그인** → 연결
4. 탐색 창에서 `내 프로젝트 → ecom_analysis → daily_kpi` 체크 → **로드**
5. 연결 모드는 **가져오기(Import)**를 고릅니다.
6. 선 차트에 `dt`, `purchases`를 올려 4단계 ④와 같은 모양이면 완료입니다.

60일 만료에 대비해, 3주차에 집계 테이블을 CSV로도 내려 두면 `.pbix`가 언제든 열립니다.

## 자주 막히는 문제

| 증상 | 원인 | 해결 |
|---|---|---|
| `Not found: Dataset ... in location` | 내 데이터셋 위치가 US가 아님 | 데이터셋을 US로 다시 만들기 |
| `Billing has not been enabled` | 샌드박스에서 DML 사용 | `CREATE OR REPLACE TABLE ... AS SELECT`로 바꾸기 |
| `Unrecognized name: _TABLE_SUFFIX` | 와일드카드 없이 단일 테이블 조회 | FROM을 `events_*`로 바꾸기 |
| Python `DefaultCredentialsError` | ADC 로그인 안 함 | `gcloud auth application-default login` |
| Python `quota project` 경고 | 기본 프로젝트 미지정 | `set-quota-project <프로젝트ID>` |
| `Activate.ps1`이 막힘 | PowerShell 실행 정책 | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| `to_dataframe()`에서 `db-dtypes` 오류 | 패키지 누락 | `pip install db-dtypes` |
| 며칠 뒤 내 테이블이 사라짐 | 샌드박스 60일 만료 | 저장해 둔 SQL로 다시 생성 |
