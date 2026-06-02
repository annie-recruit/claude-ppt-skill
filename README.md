# /ppt — 프롬프트 → 완성도 높은 기획안 PPT 생성 (Claude Code 슬래시 커맨드)

비정형 텍스트(프롬프트·이메일·메모)를 입력하면, **python-pptx**로 16:9 기획안 `.pptx` + `.pdf`를 만들어 주는 [Claude Code](https://claude.com/claude-code) 슬래시 커맨드. 명사형 종결·Executive Register·스토리텔링 서사·플랫 디자인 시스템(Navy/Sky · Pretendard)을 따른다. 생성 후 PDF로 렌더해 **눈으로 자체 검증**까지 한다.

```
/ppt 신규 입사자 온보딩을 입사 전·당일·1주·1개월로 표준화하는 기획안. 웰컴 메일·멘토멘티·협업툴 가이드·30일 피드백 포함.
/ppt <기획 내용 또는 메일 붙여넣기 — 길고 비정형이어도 됨>
```

## 설치 — 한 줄이면 끝 (macOS)

터미널(응용프로그램 › 유틸리티 › 터미널)에 아래 한 줄을 붙여넣고 Enter:

```bash
curl -fsSL https://raw.githubusercontent.com/annie-recruit/claude-ppt-skill/main/install.sh | bash
```

이 한 줄이 **Homebrew · git · python3 · python-pptx · PyMuPDF · LibreOffice · Pretendard 폰트**까지 알아서 깔고, 스킬 파일을 `~/.claude/commands/`에 복사한다. 끝나면 Claude Code에서 바로 `/ppt`. (Homebrew 최초 설치 시 macOS 암호를 한 번 물어볼 수 있음. 설치는 5~10분 — LibreOffice가 큼.)

> **Claude Code 사용자라면 더 간단히** — 그냥 Claude에게 이 레포 주소를 주고 "이 스킬 설치해줘"라고 하면 알아서 클론하고 `install.sh`를 돌린다.

## 설치 — 한 줄이면 끝 (Windows)

**PowerShell**(시작 › "PowerShell" 검색 › 실행)에 아래 한 줄을 붙여넣고 Enter:

```powershell
irm https://raw.githubusercontent.com/annie-recruit/claude-ppt-skill/main/install.ps1 | iex
```

이 한 줄이 **Python · python-pptx · PyMuPDF · Pretendard 폰트 · (선택)LibreOffice**를 깔고, 스킬 파일을 `%USERPROFILE%\.claude\commands\`에 복사한다. **git·관리자 권한 불필요**(레포 zip을 받아 사용자 단위로 설치). Python·LibreOffice는 `winget`으로 자동 설치된다.

> 스크립트 실행이 막히면(실행 정책) PowerShell에서 먼저 `Set-ExecutionPolicy -Scope Process Bypass -Force` 한 줄 실행 후 다시 시도.

<details><summary>수동 / 클론 후 설치 (macOS·Windows 공통)</summary>

macOS:
```bash
git clone https://github.com/annie-recruit/claude-ppt-skill.git
cd claude-ppt-skill && bash install.sh
```
파일만 직접: `ppt.md`·`ppt_benchmarks.md`·`assets/`를 `~/.claude/commands/`(Windows는 `%USERPROFILE%\.claude\commands\`)에 두고, `python3 -m pip install python-pptx PyMuPDF` 실행.
</details>

## 무엇이 동봉되고 무엇이 자동 설치되나

| 구분 | 항목 | 처리 |
|---|---|---|
| 📦 레포 동봉 | `ppt.md` · `ppt_benchmarks.md` · `assets/` Pretendard 폰트(.otf) | `install.sh`가 `~/.claude/commands/`로 복사 |
| ⚙️ 자동 설치 | Homebrew · git · python3 · **python-pptx** · **PyMuPDF** | `install.sh`가 설치 (python-pptx·PyMuPDF는 필수) |
| ⚙️ 자동 설치 | LibreOffice · Pretendard 폰트 | `install.sh`가 brew로 설치 (렌더 검증용) |

용량이 큰 LibreOffice·Python 패키지는 파일로 동봉하지 않고 `install.sh`가 받아온다. LibreOffice가 없어도 `.pptx` 생성은 되지만, 생성 후 PDF 렌더 자체 검증은 건너뛴다.

## 동작 방식

1. **Step 0** — `ppt_benchmarks.md`(컨펌된 덱 사례)를 읽어 품질 기준 확보
2. 입력 분석 → 문서 유형 판별(해커톤·사업기획·HR·보고서·범용 등) → 서사 골격 설계
3. `python-pptx`로 생성 → LibreOffice로 PDF 변환 → 이미지로 렌더해 깨짐·넘침·정렬 자체 점검
4. 사용자가 컨펌하면 그 덱의 품질 규칙을 `ppt_benchmarks.md`에 한 줄 사례로 누적 (쓸수록 톤이 안정됨)

## 파일 구성

```
ppt.md             스킬 본체 — 워크플로우·디자인 시스템·헬퍼·검증된 레이아웃 교훈
ppt_benchmarks.md  컨펌 사례 벤치마크 (Step 0에서 참조, 사례 누적)
assets/            Pretendard 폰트 (.otf)
install.sh         설치 스크립트
```

## 커스터마이즈

- **컬러**: `ppt.md`의 디자인 시스템 팔레트(Navy/Sky/Card 등) HEX 값을 바꾸면 전체 톤이 바뀐다.
- **벤치마크**: 처음엔 사례가 일반화돼 있다. 본인 작업을 컨펌하며 `ppt_benchmarks.md`에 쌓으면 점점 자기 조직 톤에 맞춰진다.

## 라이선스 / 참고

- Pretendard 폰트는 OFL(오픈소스). 슬라이드에는 로고를 넣지 않는다(브랜드 중립).
- 벤치마크 사례는 비식별화돼 있다(회사·금액·인물 제거). 구조·문체·레이아웃 기준만 담겨 있다.
