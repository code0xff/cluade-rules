# Claude Rules

범용 개발 워크플로우를 위한 Claude Code rules와 skills 모음.

새 프로젝트에 `.claude/` 디렉토리를 복사하여 사용한다.

## 사용법

```bash
cp -r .claude/ /path/to/your-project/.claude/
```

## 구성

## 범용 Harness 확장 (Codex Plan + Claude Build)

이 저장소는 Claude 중심 규칙을 유지하면서도, 아래 문서로 **모델 분업형 범용 harness**로 바로 운용할 수 있다.

- `WORKFLOW_FEATURE.md` — 표준 개발 파이프라인
  - 기본: **Codex(Plan) → Claude(Build) → Codex(Review) → Claude(Fix)**
- `MODEL_ROUTING_POLICY.md` — 역할별 모델 라우팅 정책
- `CHECKLIST_DONE.md` — Definition of Done 체크리스트

권장 운영:
1. 작업 시작 시 Codex로 `plan` 산출
2. Claude로 구현 (plan lock 준수)
3. Codex로 교차 리뷰
4. 체크리스트 통과 시 완료


### Rules (7개) — 개발 원칙

| 파일 | 역할 |
|------|------|
| `guardrails.md` | 코드 품질, 에러 처리, 외부 연동, 확장성 |
| `security.md` | 입력 검증, secrets, 로깅 보안, 최소 권한 |
| `dependencies.md` | 의존성 추가/업데이트/제거 기준 |
| `docs.md` | 문서 유형, README/API 기준, 품질 원칙 |
| `testing.md` | 테스트 레이어, 원칙, 규칙 |
| `commits.md` | 커밋 단위, 메시지, 히스토리 품질 |
| `workflow.md` | 워크플로우, 문서 계층, phase 규칙 |

### Skills (4개) — 실행 워크플로우

| 스킬 | 역할 |
|------|------|
| `/plan` | 구현 전 설계 및 계획 수립 |
| `/phase` | Phase 시작~종료 오케스트레이션 |
| `/codex-review` | 구현 완료 후 외부 Codex CLI 반복 리뷰 |
| `/self-review` | 구현 완료 후 내부 thinking mode 반복 리뷰 |

### 라이프사이클

```
/plan → /phase (구현 + 리뷰 포함) → (push)
```

`/phase`는 구현, 커밋, 코드 리뷰를 내부에서 순차 수행한다. 변경 크기에 따라 경량 리뷰(빌드+테스트만) 또는 전체 리뷰(`/codex-review` + `/self-review`)를 선택한다. 리뷰를 별도로 실행하려면 `/phase` 없이 직접 호출한다.

## 프로젝트별 확장

복사 후 프로젝트에 맞게 추가할 것:

- `docs/architecture.md` — 프로젝트 아키텍처 문서
- `docs/roadmap/` — Phase 정의와 deliverable
- `.claude/rules/` — 프로젝트 특화 규칙 추가
- `.claude/settings.json` — 프로젝트에서 사용하는 빌드/테스트 도구에 맞게 권한 추가 (예: `Bash(cargo:*)`, `Bash(go:*)`, `Bash(make:*)`)
