# DB for Frontend — 손으로 배우는 PostgreSQL

> 프론트엔드 개발자가 **백엔드 회의에서 구조적 의견을 낼 수 있을 때까지**,
> 진짜 Postgres를 띄워놓고 직접 쿼리를 돌려보며 배우는 실습 커리큘럼.

도메인은 **병원 예약 서비스**로 통일했습니다. 한 도메인이 전 단계를 관통해요:

| 단계 | 이 도메인에서 마주치는 진짜 문제 |
|------|----------------------------------|
| 1. 구조 | 병원·의사·예약을 어떻게 쪼개고 묶을까 |
| 2. 무결성 | "예약 + 결제"가 중간에 깨지면? |
| 3. 인덱스/검색 | 예약 100만 건에서 내 예약 찾기가 왜 느릴까 |
| 4. 동시성 | 같은 시간대를 두 명이 동시에 예약하면? |
| 5. 공간(PostGIS) | "내 주변 2km 병원 찾기"는 내부에서 무슨 일이? |
| 6. 인프라 | 커넥션 풀과 캐시(Redis)는 왜 필요할까 |

전체 로드맵은 [`curriculum.md`](./curriculum.md)에 있어요.

---

## 진행 방식

1. 각 단계 폴더의 `README.md`로 **비유 + 개념**을 먼저 이해
2. `.sql` 파일을 **직접 실행**해보며 손으로 확인
3. Claude(나)와 대화하며 "왜 그런지" 깊게 파기 → 막히면 그냥 물어봐요
4. 이해했으면 각 단계 끝의 **퀘스트**를 풀고 ✅ 체크

> 핵심 원칙: **개념만 읽지 말고 반드시 직접 돌려본다.** `EXPLAIN ANALYZE`를 내 눈으로 본 사람만 회의에서 의견을 낼 수 있어요.

---

## 시작하기 (5분)

```bash
# 1. Postgres + PostGIS 컨테이너 띄우기
cd study/cs-study/db-for-frontend
docker compose up -d

# 2. 잘 떴는지 확인
docker compose ps

# 3. psql로 접속 (비밀번호: study)
docker compose exec db psql -U study -d playground

# 4. 끝나면 내리기 (데이터는 볼륨에 남아있음)
docker compose down
```

접속 정보:

| 항목 | 값 |
|------|-----|
| host | `localhost` |
| port | `5433` (로컬 Postgres와 충돌 피하려고 5432 대신) |
| user | `study` |
| password | `study` |
| database | `playground` |

SQL 파일을 통째로 실행하려면:

```bash
docker compose exec -T db psql -U study -d playground < 01-structure/01-pk-fk.sql
```

> GUI가 편하면 TablePlus / DBeaver로 위 접속 정보를 그대로 넣으면 돼요.

---

## 진행률

```
[x] 0. 셋업          docker compose up
[x] 1. 구조          PK/FK · 정규화 · JSONB
[ ] 2. 무결성        트랜잭션 · ACID · 격리 수준
[ ] 3. 인덱스/검색    B-Tree · EXPLAIN · N+1 · 페이지네이션
[ ] 4. 동시성        Lock · Deadlock · MVCC
[ ] 5. 공간 데이터    PostGIS · 내 주변 2km
[ ] 6. 인프라        Connection Pool · Redis 캐싱
```
