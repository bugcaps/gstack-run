# Phase 4: 외부 의존 · 위험 지점

| 항목 | 찾는 법 |
|---|---|
| 범위 밖 import | Grep `^import|require\(` |
| 전역/싱글턴 상태 | 모듈 최상위 `let`, `static`, 캐시 객체 |
| I/O | fs, fetch/http, DB 클라이언트 |
| TODO/FIXME | Grep `TODO|FIXME|HACK` |
| 테스트 유무 | Glob `**/*.test.*`, `**/*_test.*` |

출력물: 위 표를 file:line으로 채운 것
