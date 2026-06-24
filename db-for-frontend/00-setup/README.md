# 0단계. 셋업 — Postgres 띄우고 첫 쿼리

## 1. 컨테이너 띄우기

```bash
cd study/cs-study/db-for-frontend
docker compose up -d
docker compose ps   # State가 healthy 면 성공
```

`postgis/postgis:16-3.4` 이미지를 써서 **Postgres 16 + PostGIS**가 한 번에 들어있어요.
(5단계 공간 데이터까지 이 컨테이너 하나로 끝)

## 2. 접속하기

```bash
docker compose exec db psql -U study -d playground
```

프롬프트가 `playground=#` 로 바뀌면 DB 안에 들어온 거예요.

자주 쓰는 psql 명령:

| 명령 | 뜻 |
|------|-----|
| `\dt` | 테이블 목록 |
| `\d 테이블명` | 테이블 구조 보기 |
| `\x` | 결과를 세로로 보기 (넓은 행에 유용) |
| `\timing` | 쿼리 실행 시간 표시 켜기 |
| `\q` | 나가기 |

## 3. 첫 쿼리

```sql
SELECT version();
SELECT postgis_version();   -- PostGIS 살아있는지 확인
```

`postgis_version()`이 버전을 뱉으면 5단계 준비까지 끝난 거예요.

## 4. 파일로 실행하기

각 단계의 `.sql`을 통째로 돌리려면:

```bash
docker compose exec -T db psql -U study -d playground < 01-structure/01-pk-fk.sql
```

> `-T`는 "터미널 입력 흉내(TTY) 끄기" 옵션. 파일을 파이프로 넣을 땐 꼭 필요해요.

---

준비됐으면 → `01-structure/README.md` 로!
