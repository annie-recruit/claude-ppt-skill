#!/usr/bin/env bash
# /ppt 스킬 설치 스크립트 — 클론한 레포 디렉터리 안에서 실행하세요.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.claude/commands"

echo "▶ /ppt 스킬 설치"
echo "  소스: $SRC"
echo "  대상: $DEST"

mkdir -p "$DEST/assets"
cp "$SRC/ppt.md" "$DEST/ppt.md"
cp "$SRC/ppt_benchmarks.md" "$DEST/ppt_benchmarks.md"
cp "$SRC"/assets/* "$DEST/assets/" 2>/dev/null || true
echo "✓ 스킬 파일 복사 완료 (ppt.md, ppt_benchmarks.md, assets/)"

# --- Python 의존성 (필수) ---
if command -v pip3 >/dev/null 2>&1; then
  echo "▶ python-pptx · PyMuPDF 설치..."
  pip3 install --quiet python-pptx PyMuPDF && echo "✓ Python 패키지 설치 완료"
else
  echo "⚠ pip3 없음 — python-pptx, PyMuPDF 를 수동 설치하세요."
fi

# --- 렌더 검증용 (선택, macOS Homebrew) ---
if command -v brew >/dev/null 2>&1; then
  echo "▶ (선택) LibreOffice · Pretendard 폰트 확인..."
  brew list --cask font-pretendard >/dev/null 2>&1 || brew install --cask font-pretendard || true
  if [ ! -x "/Applications/LibreOffice.app/Contents/MacOS/soffice" ] && ! command -v soffice >/dev/null 2>&1; then
    echo "  LibreOffice 미설치 → 렌더 검증을 원하면: brew install --cask libreoffice"
  else
    echo "✓ LibreOffice 확인됨"
  fi
else
  echo "⚠ Homebrew 없음 — 렌더 검증을 원하면 LibreOffice와 Pretendard 폰트를 수동 설치하세요."
fi

echo
echo "✅ 설치 완료! Claude Code에서  /ppt <기획 내용>  으로 사용하세요."
