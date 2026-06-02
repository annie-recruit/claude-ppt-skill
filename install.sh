#!/usr/bin/env bash
# /ppt 스킬 설치 — 비개발자도 한 줄이면 끝.
#   A) 한 줄 설치:  curl -fsSL https://raw.githubusercontent.com/annie-recruit/claude-ppt-skill/main/install.sh | bash
#   B) 클론 후:     git clone … && cd claude-ppt-skill && bash install.sh
# Homebrew · git · python3 · python-pptx · PyMuPDF · LibreOffice · Pretendard 폰트까지 자동 설치.
set -uo pipefail
REPO="https://github.com/annie-recruit/claude-ppt-skill.git"
DEST="$HOME/.claude/commands"
OS="$(uname -s)"
say(){  printf "\033[1;36m▶ %s\033[0m\n" "$1"; }
ok(){   printf "  \033[1;32m✓ %s\033[0m\n" "$1"; }
warn(){ printf "  \033[1;33m! %s\033[0m\n" "$1"; }

# 1) Homebrew (macOS, 없으면 설치) ----------------------------------------
if [ "$OS" = "Darwin" ] && ! command -v brew >/dev/null 2>&1; then
  say "Homebrew 설치 (최초 1회 · 암호 입력이 필요할 수 있음)"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || warn "Homebrew 설치 실패 — https://brew.sh 참고 후 다시 실행"
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [ -x /usr/local/bin/brew ]   && eval "$(/usr/local/bin/brew shellenv)"
fi
HAS_BREW=0; command -v brew >/dev/null 2>&1 && HAS_BREW=1

# 2) git · python3 보장 ----------------------------------------------------
if [ "$HAS_BREW" = "1" ]; then
  command -v git     >/dev/null 2>&1 || { say "git 설치";     brew install git     || warn "git 설치 실패"; }
  command -v python3 >/dev/null 2>&1 || { say "python3 설치"; brew install python  || warn "python 설치 실패"; }
fi
command -v python3 >/dev/null 2>&1 || { warn "python3가 없습니다. https://www.python.org 에서 설치 후 다시 실행"; exit 1; }
command -v git     >/dev/null 2>&1 || { warn "git이 없습니다. 설치 후 다시 실행"; exit 1; }

# 3) 스킬 파일 확보: 스크립트 옆에 있으면 그걸, (curl 실행 등) 없으면 클론 -----
SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
TMP=""
if [ -z "${SRC:-}" ] || [ ! -f "$SRC/ppt.md" ]; then
  say "레포 내려받기"
  TMP="$(mktemp -d)"; git clone --depth 1 "$REPO" "$TMP" >/dev/null 2>&1 && SRC="$TMP" || { warn "클론 실패"; exit 1; }
fi

# 4) 스킬 파일 복사 -------------------------------------------------------
say "스킬 파일 복사 → $DEST"
mkdir -p "$DEST/assets"
cp "$SRC/ppt.md" "$SRC/ppt_benchmarks.md" "$DEST/"
cp "$SRC"/assets/* "$DEST/assets/" 2>/dev/null || true
ok "ppt.md · ppt_benchmarks.md · assets/ 복사 완료"

# 5) Python 패키지 (필수) -------------------------------------------------
say "Python 패키지 설치 (python-pptx · PyMuPDF)"
( python3 -m pip install --quiet --upgrade pip >/dev/null 2>&1 ) || true
if python3 -m pip install --quiet python-pptx PyMuPDF 2>/dev/null \
   || python3 -m pip install --quiet --user python-pptx PyMuPDF 2>/dev/null \
   || python3 -m pip install --quiet --break-system-packages python-pptx PyMuPDF 2>/dev/null; then
  ok "python-pptx · PyMuPDF 설치 완료"
else
  warn "Python 패키지 설치 실패 — 수동: python3 -m pip install python-pptx PyMuPDF"
fi

# 6) 렌더 검증 도구: Pretendard 폰트 + LibreOffice -----------------------
if [ "$HAS_BREW" = "1" ]; then
  say "Pretendard 폰트 설치"
  brew list --cask font-pretendard >/dev/null 2>&1 || brew install --cask font-pretendard >/dev/null 2>&1 || warn "폰트 설치 실패 (동봉 .otf로 대체)"
  if [ ! -x "/Applications/LibreOffice.app/Contents/MacOS/soffice" ] && ! command -v soffice >/dev/null 2>&1; then
    say "LibreOffice 설치 (PDF 렌더 검증용 · 용량 큼, 수 분 소요)"
    brew install --cask libreoffice >/dev/null 2>&1 && ok "LibreOffice 설치 완료" || warn "LibreOffice 설치 실패 — 없어도 .pptx 생성은 됨"
  else
    ok "LibreOffice 확인됨"
  fi
else
  warn "Homebrew 없음 — LibreOffice/폰트는 수동 설치 (없어도 .pptx 생성은 됨)"
fi

# 7) 동봉 폰트를 사용자 폰트 폴더에도 복사 (인식 보강) -------------------
if [ "$OS" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Fonts" 2>/dev/null && cp "$DEST"/assets/Pretendard-*.otf "$HOME/Library/Fonts/" 2>/dev/null || true
fi

[ -n "$TMP" ] && rm -rf "$TMP"
echo
ok "설치 완료!  Claude Code에서   /ppt <기획 내용>   으로 사용하세요."
