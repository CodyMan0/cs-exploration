-- ============================================================
-- 1단계 / 03. 역정규화 & JSONB — 쪼개기 싫은 건 문서로 퉁친다
-- 실행:  docker compose exec -T db psql -U study -d playground < 01-structure/03-jsonb.sql
-- 선행:  01-pk-fk.sql 을 먼저 실행해 clinics 테이블이 있어야 합니다.
-- ============================================================

-- 상황: 병원마다 부가 정보가 제각각이다.
--   A병원은 "주차 가능 + 주말 진료", B병원은 "무료 와이파이 + 외국어 가능 + 키즈존"...
--   이런 걸 컬럼으로 다 만들면 컬럼이 끝없이 늘어나고 대부분 NULL.
--   → 구조가 유연해야 하는 데이터는 JSONB 한 칸으로!

ALTER TABLE clinics ADD COLUMN IF NOT EXISTS features JSONB DEFAULT '{}'::jsonb;

UPDATE clinics SET features = '{
    "parking": true,
    "weekend": true,
    "languages": ["ko", "en"],
    "open_hours": {"mon": "09-18", "sat": "09-13"}
}'::jsonb
WHERE id = 1;

UPDATE clinics SET features = '{
    "parking": false,
    "wifi": true,
    "kids_zone": true,
    "languages": ["ko"]
}'::jsonb
WHERE id = 2;

-- ------------------------------------------------------------
-- 실습 1) 문서 안의 값 꺼내기
--   ->  : JSON 값으로 꺼냄    ->> : 텍스트로 꺼냄
-- ------------------------------------------------------------
SELECT
    name,
    features ->> 'parking'        AS 주차,
    features -> 'open_hours'      AS 영업시간_json,
    features #>> '{open_hours,sat}' AS 토요일영업   -- 중첩 경로로 깊이 들어가기
FROM clinics;

-- ------------------------------------------------------------
-- 실습 2) 조건으로 거르기
--   @> : "이 문서가 오른쪽 내용을 포함하나?" (containment)
-- ------------------------------------------------------------
-- 주차 가능한 병원만
SELECT name FROM clinics WHERE features @> '{"parking": true}';

-- 영어 가능한(languages 배열에 "en" 포함) 병원만
SELECT name FROM clinics WHERE features -> 'languages' ? 'en';

-- ------------------------------------------------------------
-- 실습 3) JSONB도 인덱스로 빨라진다 (GIN 인덱스) — 3단계 예고편
--   @> 같은 검색을 빠르게 하려면 GIN 인덱스를 건다
-- ------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_clinics_features ON clinics USING GIN (features);

-- 언제 JSONB? vs 언제 컬럼/테이블?
--   JSONB가 좋은 곳: 스키마가 자주 바뀌거나 병원마다 제각각인 "부가 옵션"
--   정규 컬럼이 좋은 곳: 항상 조건/정렬/조인에 쓰는 핵심 값(이름, 좌표, 가격 등)
--   ⚠️ 함정: JSONB에 다 넣으면 편하지만, 그 안의 값으로 자주 필터/정렬하면
--            결국 인덱스 관리가 까다로워져요. "핵심은 컬럼, 부가는 JSONB"가 실무 감각.

-- 프론트 비유:
--   정규 컬럼 = 잘 정의된 props (타입 고정, 예측 가능)
--   JSONB     = 자유로운 config 객체 (유연하지만 추적이 어려움)
