# /ppt — 프롬프트 → 완성도 높은 기획안 PPT 생성 (Claude Code 슬래시 커맨드)

비정형 텍스트(프롬프트·이메일·메모)를 입력하면, **python-pptx**로 16:9 기획안 `.pptx` + `.pdf`를 만들어 주는 [Claude Code](https://claude.com/claude-code) 슬래시 커맨드. 명사형 종결·Executive Register·스토리텔링 서사·플랫 디자인 시스템(Navy/Sky · Pretendard)을 따른다. 생성 후 PDF로 렌더해 **눈으로 자체 검증**까지 한다.

```
/ppt 신규 입사자 온보딩을 입사 전·당일·1주·1개월로 표준화하는 기획안. 웰컴 메일·멘토멘티·협업툴 가이드·30일 피드백 포함.
/ppt <기획 내용 또는 메일 붙여넣기 — 길고 비정형이어도 됨>
```

## 설치

```bash
git clone https://github.com/annie-recruit/claude-ppt-skill.git
cd claude-ppt-skill
bash install.sh
```

`install.sh`는 스킬 파일을 `~/.claude/commands/`에 복사하고 의존성을 설치한다. 이후 Claude Code에서 `/ppt`를 바로 쓸 수 있다.

> 수동 설치: `ppt.md`, `ppt_benchmarks.md`, `assets/`를 `~/.claude/commands/`에 그대로 두면 된다. 스킬이 경로를 `~/.claude/commands/...`로 참조하므로 위치가 중요하다.

## 의존성

| 항목 | 용도 | 설치 |
|---|---|---|
| `python-pptx` | pptx 생성 엔진 (필수) | `pip3 install python-pptx` |
| `PyMuPDF` 또는 poppler | PDF→PNG 렌더 검증 | `pip3 install PyMuPDF` |
| LibreOffice | pptx→pdf 변환 | `brew install --cask libreoffice` |
| Pretendard 폰트 | 한글 렌더 정확도 | `brew install --cask font-pretendard` |

macOS 기준. (LibreOffice·폰트 미설치 시 생성은 되지만 자체 렌더 검증은 건너뛴다.)

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
