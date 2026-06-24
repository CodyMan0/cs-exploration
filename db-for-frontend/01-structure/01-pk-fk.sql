-- ============================================================
-- 1단계 / 01. PK와 FK — 번호표로 테이블을 잇는다
-- 실행:  docker compose exec -T db psql -U study -d playground < 01-structure/01-pk-fk.sql
-- ============================================================

-- 깨끗한 상태에서 시작 (이미 있으면 지우고 다시)
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS clinics;

-- 병원: 가장 위(부모) 테이블
CREATE TABLE clinics (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  -- PK: 병원 고유 번호
    name        TEXT NOT NULL,
    address     TEXT NOT NULL
);

-- 의사: 어느 병원 소속인지 FK로 연결
CREATE TABLE doctors (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    clinic_id   BIGINT NOT NULL REFERENCES clinics(id),  -- FK: clinics.id를 가리킴
    name        TEXT NOT NULL,
    specialty   TEXT NOT NULL
);

-- 예약: 어느 의사에게 잡힌 예약인지 FK로 연결
CREATE TABLE appointments (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    doctor_id   BIGINT NOT NULL REFERENCES doctors(id),  -- FK
    patient_name TEXT NOT NULL,
    starts_at   TIMESTAMPTZ NOT NULL
);

-- 데이터 넣기
INSERT INTO clinics (name, address) VALUES
    ('강남연세병원', '서울 강남구 테헤란로 1'),
    ('서초성모의원', '서울 서초구 서초대로 2');

INSERT INTO doctors (clinic_id, name, specialty) VALUES
    (1, '김내과', '내과'),
    (1, '이정형', '정형외과'),
    (2, '박소아', '소아과');

INSERT INTO appointments (doctor_id, patient_name, starts_at) VALUES
    (1, '홍길동', '2026-07-01 10:00+09'),
    (1, '김영희', '2026-07-01 10:30+09'),
    (3, '이철수', '2026-07-02 14:00+09');

-- ------------------------------------------------------------
-- 실습 1) JOIN: 흩어진 정보를 FK로 다시 합치기
--   "예약 — 의사 — 병원"을 번호표(키)로 이어서 사람이 읽을 표로
-- ------------------------------------------------------------
SELECT
    a.patient_name        AS 환자,
    d.name                AS 의사,
    d.specialty           AS 진료과,
    c.name                AS 병원,
    a.starts_at           AS 예약시각
FROM appointments a
JOIN doctors d ON d.id = a.doctor_id     -- FK로 연결
JOIN clinics c ON c.id = d.clinic_id     -- FK로 연결
ORDER BY a.starts_at;

-- ------------------------------------------------------------
-- 실습 2) FK가 무결성을 "강제"하는 걸 직접 보기
--   존재하지 않는 99번 의사로 예약을 넣어보면? → DB가 거부함
--   아래 주석을 풀고 실행해보세요. ERROR 가 나야 정상입니다.
-- ------------------------------------------------------------
-- INSERT INTO appointments (doctor_id, patient_name, starts_at)
-- VALUES (99, '없는의사예약', '2026-07-03 09:00+09');
--   => ERROR: insert or update on table "appointments" violates
--      foreign key constraint  ← 이게 바로 FK의 방어막!

-- ------------------------------------------------------------
-- 실습 3) 부모를 함부로 못 지우는 것도 무결성
--   1번 병원엔 의사가 매달려 있어서 그냥 삭제 안 됨
-- ------------------------------------------------------------
-- DELETE FROM clinics WHERE id = 1;
--   => ERROR: ... still referenced from table "doctors"

-- 정리: PK = 나를 유일하게 가리키는 번호,  FK = 남을 가리키는 번호.
-- DB는 이 번호표의 약속을 스스로 지켜줍니다(참조 무결성).
