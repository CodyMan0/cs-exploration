-- ============================================================
-- 1단계 / 02. 정규화 — 중복투성이 한 장을 안전하게 쪼갠다
-- 실행:  docker compose exec -T db psql -U study -d playground < 01-structure/02-normalization.sql
-- ============================================================

-- ------------------------------------------------------------
-- [BEFORE] 정규화가 안 된 "엑셀 한 장" — 모든 걸 한 테이블에
--   문제를 눈으로 보려고 일부러 이렇게 만듭니다.
-- ------------------------------------------------------------
DROP TABLE IF EXISTS messy_reservations;

CREATE TABLE messy_reservations (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    clinic_name     TEXT,   -- 병원 이름이 예약마다 반복됨
    clinic_address  TEXT,   -- 주소도 반복
    doctor_name     TEXT,   -- 의사 이름도 반복
    doctor_specialty TEXT,
    patient_name    TEXT,
    starts_at       TIMESTAMPTZ
);

INSERT INTO messy_reservations
    (clinic_name, clinic_address, doctor_name, doctor_specialty, patient_name, starts_at)
VALUES
    ('강남연세병원', '서울 강남구 테헤란로 1', '김내과', '내과', '홍길동', '2026-07-01 10:00+09'),
    ('강남연세병원', '서울 강남구 테헤란로 1', '김내과', '내과', '김영희', '2026-07-01 10:30+09'),
    ('강남연세병원', '서울 강남구 테헤란로 1', '이정형', '정형외과', '이철수', '2026-07-01 11:00+09'),
    ('서초성모의원', '서울 서초구 서초대로 2', '박소아', '소아과', '최지우', '2026-07-02 14:00+09');

-- 👀 중복을 직접 보세요: '강남연세병원' 주소가 3번이나 똑같이 적힘
SELECT clinic_name, clinic_address, doctor_name FROM messy_reservations;

-- ❗ 이상 현상(Anomaly) 체험:
--   강남연세병원이 이사를 갔다면? → 여러 행을 전부 고쳐야 함.
--   하나라도 빠뜨리면 같은 병원 주소가 행마다 달라지는 "데이터 분열"이 일어남.
UPDATE messy_reservations
SET clinic_address = '서울 강남구 테헤란로 99'
WHERE clinic_name = '강남연세병원' AND id = 1;   -- 일부러 1건만 고쳐봄

SELECT id, clinic_name, clinic_address FROM messy_reservations;  -- 주소가 서로 안 맞음 😱

-- ------------------------------------------------------------
-- [AFTER] 정규화 — 한 사실은 한 곳에만
--   01-pk-fk.sql 에서 만든 clinics / doctors / appointments 가 정규화된 형태예요.
--   "병원 주소"는 clinics 한 곳에만 있으니, 이사 가도 한 줄만 고치면 끝.
-- ------------------------------------------------------------

-- 정규화된 구조에서 같은 정보를 보려면 JOIN으로 합칩니다
-- (01-pk-fk.sql 을 먼저 실행해 두었다면 아래가 동작해요)
SELECT
    a.patient_name AS 환자,
    d.name         AS 의사,
    c.name         AS 병원,
    c.address      AS 주소          -- 주소는 clinics 단 한 곳에서 옴
FROM appointments a
JOIN doctors d ON d.id = a.doctor_id
JOIN clinics c ON c.id = d.clinic_id
ORDER BY a.starts_at;

-- 핵심 트레이드오프:
--   정규화 ↑  → 중복/이상현상 ↓, 저장 효율 ↑   (대신 읽을 때 JOIN 필요)
--   정규화 ↓  → 읽기 간단/빠름                 (대신 중복/수정 위험 ↑)
-- 백엔드가 "테이블을 쪼개려는" 이유가 바로 이 위쪽 장점들 때문입니다.

-- 🎯 퀘스트 답 맞추기: messy_reservations 한 장 → clinics / doctors / appointments
--    어떤 컬럼이 어디로 가야 할지, Claude와 함께 짚어보세요.
