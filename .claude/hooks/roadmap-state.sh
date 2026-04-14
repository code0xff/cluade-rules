#!/bin/bash

# roadmap-state.sh — roadmap.md iteration 파싱/상태 갱신 유틸
#
# 사용법:
#   source .claude/hooks/roadmap-state.sh
#   get_current_iteration_number
#   get_iteration_service_goal 1
#   get_iteration_status 1
#   count_iterations
#   all_iterations_done
#   append_iteration "service_goal" "acceptance" "WS1 goal" ["WS2 goal" ...]
#   mark_iteration_active 1
#   mark_iteration_done 1

ROADMAP_FILE="${ROADMAP_FILE:-docs/roadmap.md}"

# iteration N의 헤더 패턴
_iter_header_pattern() {
  local n="$1"
  echo "^## Iteration ${n}$"
}

# roadmap에서 iteration 섹션 수 반환
count_iterations() {
  if [ ! -f "$ROADMAP_FILE" ]; then
    echo 0
    return 0
  fi
  grep -c "^## Iteration [0-9]" "$ROADMAP_FILE" || echo 0
}

# iteration N의 특정 필드 값 반환
_get_iteration_field() {
  local iter_num="$1"
  local field="$2"
  if [ ! -f "$ROADMAP_FILE" ]; then
    echo ""
    return 0
  fi
  awk -v n="$iter_num" -v field="$field" '
    /^## Iteration / {
      cur = $3 + 0
      in_iter = (cur == n)
      next
    }
    /^## / && !/^## Iteration / { in_iter = 0 }
    in_iter && $0 ~ ("^- " field ":") {
      sub("^- " field ": *", "")
      print
      exit
    }
  ' "$ROADMAP_FILE"
}

# iteration N의 service_goal 반환
get_iteration_service_goal() {
  _get_iteration_field "$1" "service_goal"
}

# iteration N의 status 반환 (active | done | pending)
get_iteration_status() {
  local val
  val="$(_get_iteration_field "$1" "status")"
  echo "${val:-pending}"
}

# 현재 active 또는 첫 번째 pending iteration 번호 반환
get_current_iteration_number() {
  local total
  total="$(count_iterations)"
  if [ "$total" -eq 0 ]; then
    echo 0
    return 0
  fi

  local i status
  for i in $(seq 1 "$total"); do
    status="$(get_iteration_status "$i")"
    if [ "$status" = "active" ]; then
      echo "$i"
      return 0
    fi
  done

  # active 없으면 첫 번째 pending
  for i in $(seq 1 "$total"); do
    status="$(get_iteration_status "$i")"
    if [ "$status" = "pending" ]; then
      echo "$i"
      return 0
    fi
  done

  # 모두 done이면 마지막 번호
  echo "$total"
}

# 모든 iteration이 done인지 확인 (0=true, 1=false)
all_iterations_done() {
  local total
  total="$(count_iterations)"
  if [ "$total" -eq 0 ]; then
    return 1
  fi

  local i status
  for i in $(seq 1 "$total"); do
    status="$(get_iteration_status "$i")"
    if [ "$status" != "done" ]; then
      return 1
    fi
  done
  return 0
}

# iteration N의 status를 지정 값으로 변경
_set_iteration_status() {
  local iter_num="$1"
  local new_status="$2"
  if [ ! -f "$ROADMAP_FILE" ]; then
    echo "roadmap-state: $ROADMAP_FILE 파일이 없습니다." >&2
    return 1
  fi

  awk -v n="$iter_num" -v new_status="$new_status" '
    /^## Iteration / {
      cur = $3 + 0
      in_iter = (cur == n)
      print
      next
    }
    /^## / && !/^## Iteration / { in_iter = 0; print; next }
    in_iter && /^- status:/ {
      print "- status: " new_status
      next
    }
    { print }
  ' "$ROADMAP_FILE" > "${ROADMAP_FILE}.tmp"
  mv "${ROADMAP_FILE}.tmp" "$ROADMAP_FILE"
}

# iteration N을 active로 변경
mark_iteration_active() {
  _set_iteration_status "$1" "active"
}

# iteration N을 done으로 변경
mark_iteration_done() {
  _set_iteration_status "$1" "done"
}

# 새 iteration 블록을 roadmap 말미에 append
# 사용법: append_iteration "service_goal" "acceptance" "WS goal1" ["WS goal2" ...]
append_iteration() {
  local service_goal="$1"
  local acceptance="$2"
  shift 2
  local ws_goals=("$@")

  if [ ! -f "$ROADMAP_FILE" ]; then
    mkdir -p "$(dirname "$ROADMAP_FILE")"
    echo "# Roadmap" > "$ROADMAP_FILE"
  fi

  local next_num
  next_num=$(( $(count_iterations) + 1 ))

  {
    echo ""
    echo "## Iteration ${next_num}"
    echo ""
    echo "- service_goal: ${service_goal}"
    echo "- acceptance: ${acceptance}"
    echo "- status: pending"
  } >> "$ROADMAP_FILE"

  local i=1
  for ws_goal in "${ws_goals[@]}"; do
    local ws_num=$(( (next_num - 1) * 10 + i ))
    {
      echo ""
      echo "### Workstream ${ws_num}"
      echo ""
      echo "- Goal: ${ws_goal}"
      echo "- Deliverables: (to be defined)"
      echo "- Exit Criteria: (to be defined)"
      echo "- status: pending"
    } >> "$ROADMAP_FILE"
    i=$(( i + 1 ))
  done
}
