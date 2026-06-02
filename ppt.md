# ppt — 프롬프트 → PPT 기획안 자동 생성

프롬프트, 이메일, 요청서 등 비정형 텍스트를 입력받아 **python-pptx**로 완성도 높은 `.pptx` 기획안을 생성하는 스킬. 기본 디자인 시스템(Pretendard · Navy/Sky 키컬러 · 플랫/미니멀)을 따른다.

## 사용법

```
/ppt <프롬프트 또는 요청 내용>
```

예시 (실제 사용 패턴 — 길고 비정형이어도 됨):
```
/ppt 신규 입사자 온보딩을 입사 전·당일·1주·1개월 4시점으로 표준화하는 기획안.
웰컴 메일·멘토멘티 제도·협업툴 가이드·부서 소개 자료·30일 피드백 포함. 기대효과는 정량/정성 모두 현실적으로.
```
```
/ppt 생성형 AI로 서비스 프로토타입을 만드는 사내 해커톤 기획안.
행사명·세계관으로 스토리텔링 잡고, 무박 2일 일정·심사 기준·수상 구성·예산 2안까지.
```
```
/ppt 회의·인터뷰가 많은 조직에 AI 음성 전사 솔루션을 4주 PoC로 도입하는 기획안.
활용 시나리오·보안 대응·기대효과 수치(추정치 명시)·확대 로드맵 포함.
```

---

## 에셋 & 이식 (다른 컴퓨터로 옮기기)

이 스킬을 옮길 때 **반드시 함께 가야 하는 파일은 두 가지**다:
1. **이 `ppt.md`** — 스킬 본체(워크플로우·디자인 시스템·헬퍼·레이아웃 교훈).
2. **`~/.claude/commands/ppt_benchmarks.md`** — 컨펌 사례 벤치마크(Step 0에서 Read). 사례가 늘어도 본체를 가볍게 유지하려 분리한 파일.

**로고는 사용하지 않는다** — 슬라이드에 로고를 넣지 않는다. 폰트·파이썬 패키지·LibreOffice·poppler는 **새 컴퓨터에서 설치/다운로드하면 된다.**

스크립트 상단 상수:
```python
FONT = 'Pretendard'
```

### Pretendard 폰트 설치 (새 컴에서 1회)
`Pretendard`는 무료 오픈소스(OFL)다. 렌더링/PowerPoint에서 정확히 보이려면 OS에 설치돼 있어야 한다. 미설치면 작업 시작 전 설치한다.
```bash
# macOS — 가장 간단 (Homebrew)
brew install --cask font-pretendard
# 또는 공식 릴리스에서 .otf 내려받아 설치:
#   https://github.com/orioncactus/pretendard/releases  → Pretendard-*.otf 를 ~/Library/Fonts/ 에 복사
# (구버전 호환) assets/ 에 Pretendard-*.otf 가 동봉돼 있으면 그걸 복사해도 됨:
#   mkdir -p ~/Library/Fonts && cp ~/.claude/commands/assets/Pretendard-*.otf ~/Library/Fonts/ 2>/dev/null || true
```
설치 후 `fc-list | grep -i pretendard`(또는 폰트 앱)로 확인.

---

## 실행 워크플로우

다음 단계를 **순서대로** 실행한다.

### Step 0. 컨펌 사례 확인

작업 시작 시 **별도 파일 `~/.claude/commands/ppt_benchmarks.md`를 Read로 먼저 읽는다**(슬래시 커맨드는 이 `ppt.md`만 주입하고 그 파일은 자동으로 붙지 않으므로 반드시 직접 Read). 컨펌 사례는 복사 대상이 아니라 **품질 기준**이다. 사례에서 확인할 것은 디자인 장식이 아니라 다음 네 가지:
- 장표 순서가 어떻게 논리를 전개하는지
- 제목과 표제가 어떤 수준의 비즈니스 문어체를 유지하는지
- 한 장이 하나의 역할만 책임지는지
- 표·카드·캡션까지 같은 register로 통일되는지

사용자가 결과물을 컨펌하면, 다음 작업 전에 해당 PPT를 다시 열어 **`ppt_benchmarks.md` 파일에 직접 항목을 추가**한다(`날짜·파일명·문서 유형·슬라이드 순서·좋았던 문체/서사 원칙·재사용 금지할 맥락 의존 요소`). 컨펌되지 않은 산출물은 기준 사례로 등재하지 않는다. 일반화 가능한 레이아웃·정렬 교훈은 `ppt_benchmarks.md`가 아니라 이 `ppt.md`의 "검증된 레이아웃·정렬 교훈" 섹션에 추가한다.

### Step 1. 입력 분석 및 구조화
- **문서 유형** 판별 (템플릿 카탈로그 중 택1)
- **핵심 정보** 추출 (대상, 조건, 타임라인, 수치 등)
- **슬라이드 수** 결정 (기본 9~12장)
- **톤** 결정 (기본: 전문적/담백, **명사형 종결**)

핵심 수치(연봉·인원·매출 등)는 **절대 지어내지 않는다** → 입력에 없으면 `[확인 필요]`.

**문체 — 명사형 종결 (필수):** 모든 본문·설명·캡션은 서술형 어미("~합니다 / ~입니다 / ~됩니다")로 끝내지 않고 **명사·체언으로 끝맺는** 비즈니스 문서 톤으로 작성한다.
- 나쁨: "이 행사는 생성형 AI를 활용해 자사 프로덕트에 접목할 수 있는 서비스 프로토타입을 만드는 사내 해커톤입니다."
- 좋음: "생성형 AI로 자사 프로덕트에 접목할 서비스 프로토타입을 만드는 사내 해커톤"
- 나쁨: "팀별 인터뷰로 사내 기사를 작성하고 공유합니다." → 좋음: "팀별 인터뷰 기반 사내 기사 작성·공유"
- 리드/제목/뱃지뿐 아니라 **설명 문장도** 명사형으로 끝낸다. (statement 슬라이드의 슬로건성 메시지는 예외 허용)

**한국어 비즈니스 문체 (필수):** 영어 구문을 그대로 옮긴 듯한 표현이나 업계 용어를 무조건 유지하지 않는다. 먼저 장표의 역할을 판단한 뒤, 그 역할을 가장 직접적으로 설명하는 한국어 비즈니스 문장으로 쓴다.
- 제목·표제·표 헤더·키커는 해당 장표가 수행하는 기능을 바로 드러내야 한다. 독자가 추가 설명 없이 "무엇을 판단해야 하는 장표인지" 알 수 있어야 한다.
- 전문 용어는 대상 독자가 실제 회의에서 같은 의미로 사용할 때만 유지한다. 그렇지 않으면 용어 자체를 보존하지 말고, 주장과 판단 기준을 한국어로 다시 쓴다.
- "~하는 것", "~되는 것"처럼 구어적 명사화가 생기면 문장 구조가 흐린 신호로 보고, 행위·기준·효과·방식·조건 등 문서 기능에 맞는 표제로 다시 설계한다.
- 문체 문제는 단어 단위로 고치지 않는다. 제목이 어색하면 그 장표의 주장, 독자, 의사결정 맥락부터 다시 정리한다.

**전문 비즈니스 문어체 — Executive Register (필수):** 기획안은 경영진·의사결정자가 읽는 문서다. 제목·표제·문장·캡션은 단어 취향이 아니라 회의실에서의 사용 가능성으로 판단한다.
- 모든 핵심 문구에 대해 네 가지를 점검한다: **회의석상 적합성**, **의미의 정확성**, **한국어 자연도**, **의사결정 연결성**.
- 표현이 감정적이거나 과장되어 보이면 표면적인 단어만 고치지 말고, 해당 장표가 제공해야 하는 판단 기준과 근거를 다시 쓴다.
- 표현이 추상적이거나 번역투로 보이면 용어를 바꾸는 데서 멈추지 말고, 독자가 실제로 판단할 변수·조건·행동으로 문장을 재구성한다.
- 표·리스크·권고 장표는 특히 "무엇을 판단하고 어떤 행동을 해야 하는가"가 바로 보이도록 쓴다.
- **구어체·관용구·비유 표현 금지**: 회의 자료에 어울리지 않는 일상 비유나 속담성 표현은 쓰지 않는다. (나쁨: "안전한 멍석만 제공" → 좋음: "안전한 거래 환경과 운영만 지원") 비유가 떠오르면 그 비유가 가리키는 실제 기능·조건으로 직역해 쓴다.

**서사 구조 — 스토리텔링 순서 (필수):** 슬라이드는 장면을 나열하지 말고 **하나의 이야기로 흐르게** 배치한다. 앞장이 다음장을 자연스럽게 끌어와야 한다.
- **기본 서사 골격 (기획안·보고서·제안서 공통, 우선 적용):**
  **목차 → 개요/전체 요약 → 배경·어려움(문제/니즈) → 그래서 이걸 함(추진하는 구체 안 + 기대 효과) → (도출·탄생 과정, 생략 가능) → 세부 운영 How(운영 방식·진행 일정 + 각 단계별 세부 운영) → 단계별·총 예산 → (사후 관리, 생략 가능) → 마무리(감사합니다)**
  - "그래서 이걸 함" 장표는 추상적 "추진 방향"이 아니라 **실제로 추진하는 구체 안(아이템·서비스·프로그램 등) + 기대 효과**로 구성한다. 기대 효과는 맨 끝이 아니라 추진 안과 함께 앞쪽에 배치한다.
  - **장표 제목은 "추진 아이템 · 기대 효과" 같은 일반 라벨을 그대로 박지 말고, 만드는 문서의 주제에 맞는 단어로 치환한다.** 예) 행사 → `행사 운영안 · 기대 효과`, 신규 서비스 → `서비스 구성 · 기대 성과`, HR 프로그램 → `프로그램 설계 · 도입 효과`, 보고서 → `핵심 제안 · 기대 효과`. 키커도 동일하게 문서 성격에 맞춘다.
  - **핵심·결론·해결방안·기대 효과는 보통 장표 하단**에 온다. 개요·제안·도출 장표는 좌우 병렬보다 **상하 구조**(위 정의/근거 → 아래 핵심)를 우선한다.
  - 예산·사후 관리는 입력에 근거가 없으면 날조하지 말고 생략하거나 인접 항목(준비물 등)으로 대체한다.
  - "(괄호)" 단계는 문서 길이·맥락에 따라 생략한다. 짧은 운영 제안서에 불필요한 단계를 끼워넣지 않는다.
- 문서 유형에 맞게 가감하되 "왜 → 무엇 → 어떻게 → 그래서/그 다음"의 큰 흐름을 지킨다. 행사·교육 등 시간 전개가 중요한 문서는 위 골격 안에서 **규모·골격(stats) → 일정(전체) → 디테일(당일/세부) → 평가·기준 → 혜택·유인 → 이후 계획**을 'How' 구간으로 펼친다.
- **장표 간 연결**: 각 장은 직전 장에서 이어지는 내용이어야 한다. 예) 당일 타임테이블의 '발표·심사' → 다음 장 '심사 기준', 참가 혜택 → 다음 장 '운영 이후 계획'.
- **목차-본문 일치**: 목차는 실제 장표 제목과 1:1로 맞춘다. 목차에서만 추상적인 섹션명을 쓰고 본문 장표 제목이 다르면 독자가 흐름을 다시 해석해야 하므로 금지한다. 목차가 요약 라벨을 쓰더라도 본문 제목과 의미·순서가 어긋나면 장표 제목을 다시 정리한다.
- **중복 금지**: 같은 내용을 여러 장에 흩지 않는다. 한 주제는 한 장이 책임진다. (예: '심사 기준'을 미션 장과 운영 장에 중복 배치 ✕ → 독립된 '심사 기준' 장 하나로.) timeline에 이미 나온 항목을 다른 장이 그대로 반복하지 않는다 — 반복이 필요하면 개요(timeline) vs 상세(전용 장)로 역할을 분리한다.
- 입력이 특정 주제(심사·일정 등)에 치우쳐도, 프롬프트 맥락에서 **자연스럽게 파생되는 다른 관점의 장**(심사 기준, 운영 이후 계획, 기대 효과 등)으로 채워 흐름과 다양성을 확보한다.
- 기존 행사·기존 업무를 개선하는 문서라면 **기존 실행 현황/운영 결과/기준선**을 초반에 배치한다. 개선 과제와 적용 방향은 이 근거 다음에 와야 하며, 핵심 방향·운영 구조는 개선 논리가 확인된 뒤 제시한다.
- 사업 기획안의 기본 흐름은 **결론 → 시장/수요 → 공급/제약 → 구조적 한계 → 핵심 난제 → 재구성 모델 → 실행 구조 → 경제성 → 로드맵 → 리스크 → 의사결정 권고**를 우선 검토한다. 리스크는 의사결정 직전에 두고, 핵심 난제는 문제와 해법 사이에 둔다.
- 순서 검증 질문: "이 장표가 빠지면 다음 장표의 필요성이 약해지는가?" 약해지지 않으면 순서나 역할이 느슨한 것이므로 재배치·통합한다.
- 레이아웃은 의미 구조를 따라야 한다. **좌우 구성은 비교·대조·선택지 병렬**에 쓰고, **상하 구성은 문제 → 해결방안, 전/후, 원인 → 결과**에 쓴다. 문제와 해결방안을 말하는 장표를 좌우 카드로 배치하면 비교 장표처럼 오해되므로 상단 문제·하단 해결방안 구조를 우선한다.
- 장표의 위치가 아니라 **구성의 의미**가 템플릿 선택 기준이다. 같은 장표군 안에서 의미 구조가 같은 장표(예: 진단 행, 리스크-해결방안, 문제-해결방안, 수치 요약)는 같은 레이아웃 문법을 공유한다. 단순히 연속된 장표라는 이유만으로 맞추지 말고, 독자가 "같은 종류의 판단"으로 읽어야 하는 장표끼리 템플릿 결을 맞춘다.

### Step 2. 콘텐츠 보강 (중요 — 빈약한 장표 금지)

입력이 짧아도 장표가 휑하면 안 된다. 다음 원칙으로 **자연스럽고 풍부하게** 채운다:

- **모든 글머리 항목은 `(리드, 설명)` 쌍**으로 구성한다. 리드만 던지지 말고, 한 줄 설명을 붙여 맥락을 준다. 둘 다 **명사형 종결**.
- 입력 사실들 사이를 잇는 **연결 문장**을 추가한다. 단, **온도는 낮게** — 기획안에서 누구나 납득할 일반론·당위 수준만. 새로운 사실/수치/고유명사를 창작하지 않는다.
  - 좋음: "직접 다뤄본 경험이 곧 경쟁력. 문서로 읽는 것을 넘어 짧은 시간 안에 구현하며 체득하는 적용 감각"
  - 나쁨(서술형): "문서로 보는 것과 만들어 보는 것은 다릅니다. 직접 구현하며 적용 감각을 체득합니다."
  - 나쁨(창작): "작년 대비 참가율이 40% 늘었습니다." ← 근거 없는 수치 금지
- 한 텍스트박스에 주장·근거·권고가 모두 들어가 3줄 이상 이어지면 줄글로 두지 않는다. **주장 1줄 + 불릿 3개 내외 + 결론 1줄** 또는 **좌측 주장/우측 근거 카드**로 분해한다.
- 불릿은 단순 나열이 아니라 `리드: 설명` 단위로 작성한다. 예: `공급 제약: 채용만으로 해소되지 않는 전문 인력 공급 부족`.
- 핵심 결론·의사결정·시장 한계 장표는 긴 문단보다 claim-evidence 구조를 우선한다. 독자가 첫 5초 안에 "무슨 말을 하는 장표인지" 알 수 없으면 문장 구조를 다시 쓴다.
- 해결방안, 도입 효과, 적용 후 변화, 핵심 결론처럼 의사결정자가 가져가야 할 메시지는 디자인에서도 강조한다. Navy 밴드, 강조 컬럼, 결론 화살표 밴드, 상단/하단 대비 등으로 시각적 무게를 주되 장식 과잉은 피한다.
- stats·timeline·table 같은 시각 레이아웃에는 **보조 설명 문장**을 한 줄 곁들여 여백과 맥락을 함께 채운다.
- 각 슬라이드의 본문 영역(약 y 2.0~6.7인치, 높이 ~4.7인치)이 **시각적으로 채워지도록** 항목 수·카드 크기·줄간격을 조절한다.

### Step 3. 환경 준비
```bash
pip install python-pptx 2>/dev/null || pip3 install python-pptx
```
(렌더링 검증용으로 LibreOffice·poppler가 있으면 좋다. macOS: `brew install --cask libreoffice && brew install poppler`)

### Step 4. 생성 스크립트 작성 및 실행
`/tmp/generate_ppt.py`에 아래 **디자인 시스템 + 공통 코드 패턴**을 그대로 활용해 작성·실행한다.
출력 경로: `./output/{문서유형}-{날짜}.pptx`

### Step 5. PDF 변환 + 렌더링 검증 (필수)
`.pptx`와 **같은 경로·같은 이름의 `.pdf`를 항상 함께 저장**한다(`./output/{문서유형}-{날짜}.pdf`). 이 PDF를 이미지로 렌더링해 **눈으로 확인**한다 — 깨짐·넘침·빈 장표·그림자·정렬·명사형 종결을 점검하고, 문제가 있으면 스크립트를 고쳐 재생성한다.
```bash
SOFFICE=/Applications/LibreOffice.app/Contents/MacOS/soffice   # 또는 PATH의 soffice
# pptx → pdf (output 폴더에 영구 저장)
"$SOFFICE" --headless --convert-to pdf --outdir ./output ./output/파일.pptx
# 검증용 이미지는 임시 폴더에
pdftoppm -png -r 110 ./output/파일.pdf /tmp/render/slide
```
그 후 `/tmp/render/slide-01.png …`를 Read로 확인한다. **검증 없이 완료 보고하지 않는다.**

검증에는 텍스트 추출 기반의 **register audit**도 포함한다. 일반 텍스트 박스뿐 아니라 표 셀까지 추출해 제목·표제·캡션·리스크 문구가 Executive Register를 만족하는지 확인한다. 문제가 있으면 단어만 치환하지 말고 해당 장표의 역할과 주장 문장부터 다시 정리한다.

레이아웃 검증에는 **collision audit**도 포함한다. 결론 화살표 밴드, 하단 takeaway, footer가 있는 장표는 바로 위 카드/행과 최소 0.25인치 이상 간격을 둔다. 렌더에서 붙어 보이면 행 높이를 줄이거나 y 좌표를 재배치하고, 텍스트가 많은 경우 행을 압축하지 말고 문장을 줄인다.

### Step 6. 출력
생성된 **`.pptx` + `.pdf`** 두 경로와 슬라이드 수·유형·검증 결과를 사용자에게 알린다.

---

## 디자인 시스템 (담백/미니멀/플랫)

### 컬러 팔레트
| 이름 | HEX | 용도 |
|------|-----|------|
| Navy | `#003569` | 제목, 핵심 텍스트, 강조 카드 배경 |
| Blue | `#1B365D` | 본문 |
| Sky | `#4DA8DA` | 키커·악센트·강조·뱃지·노드 |
| Light Sky | `#B8DCF0` | cover/end 장식, 강조 카드 서브텍스트 |
| Sub Text | `#8CA0B3` | 캡션·설명·날짜 |
| Card BG | `#F5F8FB` | 카드/패널 배경 |
| Border | `#E3EAF1` | 구분선·카드 외곽선 |
| Table Header | `#E8EEF3` 또는 Navy | 표 헤더 |
| White | `#FFFFFF` | 배경 |

### 지오메트리 (16:9)
- 슬라이드: `Inches(13.333) × Inches(7.5)`
- 여백: 좌 `0.9`, 우 `0.9` (콘텐츠 폭 `11.533`, 우측 끝 `12.433`)
- 헤더: 키커 top `0.62` / 제목 top `0.96` / 악센트 바 top `1.66`
- 본문 영역: top `~2.1` ~ bottom `~6.7`
- 푸터 구분선: y `6.92`, 페이지: y `~6.96`
- **써머리 등 장표 전체 강조 테두리는 footer 구분선(`6.92`) 위에서 끝낸다**(예: bottom `~6.68`). 테두리가 footer와 겹치면 안 됨.

### 타이포그래피 (Pretendard)
- 모든 run에 latin + `a:ea` 모두 `Pretendard` 지정 (한글 깨짐 방지)
- 제목 28~32pt Bold(Navy) · 본문 14~18pt(Blue) · 키커 11pt Bold(Sky, 자간 넓게) · 캡션 11~13pt(Sub)
- cover 제목 40~46pt

### 공통 크롬 (모든 콘텐츠 슬라이드)
- **키커 + 제목**: 좌상단에 영문 카테고리 키커(예: `OVERVIEW`, `SCHEDULE`)를 Sky로, 그 아래 한글 제목을 Navy로. **키커와 제목 텍스트를 중복시키지 않는다** (예전 "섹션 라벨 = 제목" 중복 금지).
- **악센트 바**: 제목 아래 짧은 Sky 바(0.55×0.045인치).
- **소제목(선택)**: 장표의 핵심 결론·원칙을 한 줄로 보여줄 때, 하단 결론 밴드(`takeaway`) 대신 **제목 밑(악센트 바 아래, y `~1.92`)에 소제목 한 줄**(Blue 14~15pt, 명사형)로 둘 수 있다. 본문이 라벨·표·카드로 이미 꽉 차거나 하단 밴드가 군더더기로 보이면 이 방식을 우선한다.
- **푸터**: 얇은 Border 구분선 + 좌측 문서명(Sub 9pt) + 우측 페이지 인디케이터(`02 / 11`, 우측 끝 `12.433` 정렬). 로고는 사용하지 않는다.
- cover/end: 우측에 반투명 하늘색 원형 장식 2개(Light Sky 14%, Sky 8%).

### 플랫 규칙 (그림자 금지)
autoshape는 테마 `<p:style>`의 effectRef 때문에 기본 그림자가 생긴다. **모든 도형에서 `<p:style>`을 제거**해 완전 플랫로 만든다(아래 `_noshadow` 참조). `shadow.inherit=False`만으로는 부족하다.

---

## 콘텐츠 enrichment 예시 (저온 연결 문장 · 명사형 종결)

빈약한 입력을 풍부하게 만드는 정도의 기준:

> 입력: "주제는 claude api로 프로덕트에 접목할 서비스 만들기"

> 보강(OK):
> - 리드: "완성이 아니라 가능성의 증명"
> - 설명: "제품 수준의 완성도보다, 아이디어가 실제로 동작함을 보여주는 '작동하는 데모'에 집중"

일반적 당위·맥락 설명은 허용, 구체 수치·고유명사·일정 창작은 금지. 모든 문장은 명사형으로 종결.

---

## 템플릿 카탈로그 (업무 기획안·보고서 중심)

입력을 분석해 가장 적합한 문서 유형을 선택한다. 아래 구성은 출발점이며, 실제 장표 수와 순서는 **문서의 의사결정 맥락**에 맞춰 조정한다. 짧은 운영 제안서에 불필요한 한 장 요약·권고 장표를 넣지 않는다.

### 1. `hr-work-plan` — HR 신규업무·운영 기획안
기존 업무를 확장하거나 신규 HR 프로그램을 제안하는 문서. 짧고 실행 중심으로 구성한다.

권장 흐름:
cover · contents · core thesis(문제→해결방안) · current work/extension · operating model · program detail×N · roadmap · risk mitigation · success criteria · end

원칙:
- 한 장 요약은 복잡한 다부문 보고가 아니면 생략
- 의사결정 권고 장표는 로드맵·리스크·성과 기준이 이미 충분하면 생략
- 프로그램별 장표는 같은 의미 구조이면 같은 레이아웃 문법 적용
- 성과 기준처럼 독립 항목은 분리 카드로 배치하고 선으로 연결하지 않음

### 2. `business-plan` — 신규사업·전략 기획안
시장 진입, 사업모델, 수익 구조, 리스크, 의사결정 조건을 검토하는 문서. 경영진 보고용으로 구조와 문체를 가장 엄격히 관리한다.

권장 흐름:
cover · contents · executive summary(필요 시) · core thesis · market/demand · supply/capability · structural limits · key challenge · redesigned model · model detail · differentiated assets · revenue/business viability · roadmap · risk mitigation · decision conditions · team/owner(필요 시) · end

원칙:
- 구조적 한계 → 핵심 난제 → 재구성 모델을 인접 배치
- 리스크와 해결방안은 의사결정 직전에 배치
- 수익성·사업성·해결방안 등 의사결정에 필요한 메시지는 디자인으로 강조
- 전문 용어는 청중이 실제로 쓰는 경우에만 유지

### 3. `internal-program-plan` — 사내 프로그램·행사 기획안
해커톤, 교육, 캠페인, 워크숍, 사내 이벤트처럼 참여자 경험과 운영 설계가 중요한 문서.

권장 흐름:
cover · contents · summary(필요 시) · overview · purpose/background · theme/mission · key stats · overall schedule · detailed timetable · evaluation/criteria · participant value · follow-up operation · closing message · end

원칙:
- 기존 행사의 2회차·개선안이면 `overview → prior execution status → issue/improvement direction → core direction → operating structure → program detail → communication/poster → schedule → completion criteria` 흐름을 우선 검토
- 목차는 실제 장표 제목을 그대로 반영하고, 장표 제목과 다른 요약 라벨로 대체하지 않음
- 기존 실행 현황은 개선안의 근거이므로 개선 과제·2회 운영 방향보다 앞에 배치
- 일정 개요와 상세 타임테이블의 역할을 분리
- 평가·심사 기준은 발표·운영 흐름 직후 배치
- 혜택·참여 가치 이후 후속 운영 계획으로 연결

### 4. `operating-report` — 운영 현황·개선 보고서
현황, 문제, 원인, 개선안, 실행 계획, 관리 지표를 보고하는 문서.

권장 흐름:
cover · contents · report purpose · current status · issue diagnosis · root causes · improvement model · action plan · owner/timeline · risk mitigation · success criteria · next steps · end

원칙:
- 현황과 문제를 섞지 말고 각각 한 장이 책임짐
- 원인과 개선안은 문제→해결방안 구조로 배치
- 독립 기준은 분리 카드, 절차는 가로 흐름 또는 타임라인

### 5. `hr-report` — HR 분석·조직 보고서
조직문화, 인력 운영, 온보딩, 유지·이탈, 구성원 경험 등 HR 의사결정을 위한 보고서.

권장 흐름:
cover · contents · key findings · context · people/organization signals · diagnosis · priority issues · recommended interventions · implementation plan · risk mitigation · metrics · end

원칙:
- 감성적 조직문화 문구보다 관찰 가능한 신호와 실행 가능한 개입안 중심
- 구성원 인터뷰·설문·운영 데이터는 근거와 해석을 분리
- 민감 이슈는 공유 범위·관리 기준·후속 조치가 함께 보이도록 구성

### 6. `general-brief` — 범용 보고·제안서
위 유형에 명확히 들어가지 않는 일반 보고서. 내용에 맞춰 가장 가까운 구조를 차용하되, 장표를 나열하지 말고 하나의 판단 흐름으로 재구성한다.

권장 흐름:
cover · contents · core thesis · context · diagnosis or opportunity · proposal/model · details · roadmap · risk/mitigation · criteria or next steps · end

---

## 레이아웃 카탈로그

모두 `prs.slide_layouts[6]`(Blank) 위에 직접 배치. 모든 콘텐츠 슬라이드는 **키커+제목+악센트 바(헤더)**, **푸터**를 포함한다.

- **cover** — 반투명 원형 장식 / 키커(영문·연도) / 악센트 바 / 대제목(Navy 46) / 부제목(Navy 27) / 캐치프레이즈(Sky) / 구분선 / 날짜·장소·주최(Sub)
- **overview** — 좌 60% 본문(리드 Navy Bold + 연결 문단 Blue) / 우 40% "핵심 포인트" 카드(Card BG, Sky 라벨 + 항목 3개: Sky 바 + Navy 라벨 + Sub 설명)
- **bullets (numbered)** — 번호(Sky 22pt) + 리드(Navy 16.5 Bold) + 설명(Blue 13) 행 반복, 행 사이 Border 구분선. 4~5개 권장. (`numbered()` 헬퍼)
- **stats** — 2~4개 Card BG 카드 가로 배치(상단 Sky 바 + 숫자 Navy 40 + 단위 16 + 설명 Sub) + 하단 보조 설명 문장 1줄
- **timeline** — Card BG 패널 안에 가로 연결선(Light Sky) + 노드(Navy 원+흰 점) + 날짜 뱃지(Sky 알약, 흰 텍스트) + 단계명(Navy) + 설명(Sub). 3~5개
- **two-col** — 좌/우 카드 2개(좌: White+Border, 우: Card BG). 각 카드: 상단 악센트 바 + 헤더(좌 Navy/우 Sky) + 항목 리스트(`· `)
- **table** — 헤더 Navy 배경·흰 텍스트, 본문 지브라(White/Card BG), 넉넉한 행높이(≥0.6인치), 셀 여백 충분. 테마 스타일 제거 후 셀 fill 직접 지정 (`_table_clean`)
- **agenda (목차)** — 표지 다음 1장. 실제 장표 제목과 같은 문구·순서로 구성한다. 대분류 목차가 필요한 긴 문서가 아니라면 추상 섹션명으로 재명명하지 않는다. 장표 제목과 목차 문구가 다르면 목차가 아니라 장표 제목 또는 전체 흐름을 먼저 수정한다.
- **summary (한 장 요약)** — 목차 다음 1장. 전체 덱을 **2×2 카드 그리드** 또는 **핵심 수치 stats**로 압축(Card BG + 상단 Sky 바 + 카테고리 라벨 Navy + 핵심 항목 `· ` Blue). 카테고리는 목적/주제/운영/심사·혜택·이후 등 덱의 대주제. 경영진·바쁜 독자가 한 장만 봐도 전체를 파악하게. **초반 써머리 장표임을 강조하려면 장표 전체에 Sky 라운드 테두리 + 좌측 강조 바**를 두를 수 있다 — 단 테두리는 footer 구분선(`6.92`) 위(bottom `~6.68`)에서 끝내 footer와 겹치지 않게 한다.
- **label-row** — 좌측 라벨칩(Header BG, Navy Bold 중앙) + 우측 설명 카드(Card BG, Blue) 행을 3개 내외 쌓고, 하단에 **결론 화살표 밴드**(`takeaway`: Navy 오른쪽 화살표 + Header BG 밴드 + Navy Bold 결론). 목적·기준·근거를 라벨로 정렬할 때. (`label_rows()` + `takeaway()`)
- **process-flow** — 원형 노드(Navy 원 + 흰 단계명) 가로 배치 + 사이 Sky 오른쪽 화살표 + 노드 아래 설명(Sub). 진행 단계/프로세스 시각화. 3~6개. (`process_flow()`)
- **statement** — 중앙 정렬. 상단 짧은 Sky 바 + 메시지(Navy 31 Bold) + 부제(Sky 17). 극도로 담백
- **profile** — 좌: 이름(Navy 28 Bold)·직함·요약·소개 / 우: 경력 리스트 / 하단 stats 카드
- **end** — cover와 동일 장식. 악센트 바 + "감사합니다"(Navy 42) + 부제(Sky) + 날짜·작성자(Sub)

> `label-row`(라벨칩+설명+결론 밴드) · `process-flow`(원형 노드 플로우) · `table`(준비물/타임테이블 체크리스트)는 실무 운영계획서에서 자주 쓰는 구성이다. 결론 화살표 밴드(`takeaway`)는 목적·근거 슬라이드 하단에 "→ 그래서 이렇게" 한 줄로 마무리할 때 어느 레이아웃에든 얹을 수 있다.

---

## python-pptx 구현 규칙

### MUST
1. 슬라이드 16:9 (`Inches(13.333)×Inches(7.5)`), Blank 레이아웃 직접 배치
2. **폰트 Pretendard** — 모든 run에 latin + `a:ea` 모두 지정 (`_style` 사용)
3. 지정 팔레트만 사용
4. 여백 좌우 0.9인치, 본문 영역을 시각적으로 채울 것
5. 모든 콘텐츠 슬라이드: 키커+제목+악센트 바 헤더, 푸터(구분선+문서명+페이지)
6. **키커 ≠ 제목** (중복 라벨 금지)
7. **플랫**: 모든 autoshape에서 `<p:style>` 제거(`_noshadow`)로 그림자 0
8. 글머리 항목은 (리드, 설명) 쌍 + 저온 연결 문장으로 보강
9. 핵심 수치 날조 금지 → `[확인 필요]`
10. 생성 후 렌더링 이미지로 자체 검증

### SHOULD
- 제목 28~32pt(Navy), 본문 14~18pt(Blue), 줄간격 1.3~1.45
- 텍스트 박스 margin 0으로 정밀 배치
- 강조는 Sky 색상으로(볼드 남용 금지)
- 한 슬라이드에 항목 과밀/넘침 금지
- cover/end 반투명 원형 장식

### MUST NOT
- 외부 이미지 URL 다운로드 금지
- 마스터/테마 수정, VBA 매크로
- 그림자·3D·워드아트 등 입체 효과
- 제목 중앙 정렬(statement/end 제외)
- 키커에 제목과 같은 텍스트

### 검증된 레이아웃·정렬 교훈 (실측 컨펌 기반)
렌더 검증에서 반복적으로 잡힌 문제와 해결책. 새 덱에서 같은 구조를 쓸 때 처음부터 적용한다.

1. **여러 줄 텍스트는 `\n` 한 run에 넣지 말고 줄마다 `para()`로 분리한다.** 단일 run에 `\n`을 넣으면 중앙 정렬이 줄마다 어긋난다(표 셀·stats 라벨·원형 노드 라벨·타임라인 설명 전부 해당). 표 셀은 `table_cell`이 `text.split('\n')`로 단락 분리 + `cell.vertical_anchor=MIDDLE`까지 처리하도록 둔다. 원형 노드/카드 라벨도 동일하게 `for line in label.split('\n'): para(..., align=CENTER, first=(i==0))`.
2. **label-row + 하단 takeaway는 행 박스 높이와 결론 밴드 높이를 통일한다.** `takeaway` 밴드는 0.66" 고정이므로 `label_rows(row_h=0.66, gap=0.26)`로 맞춰야 마지막 결론 박스만 얇아 보이는 현상이 사라진다. 행이 4개면 `top=2.35, row_h=0.66, gap=0.26, takeaway top≈6.03`이 footer(6.92)와 안 겹치는 표준값.
3. **써머리 강조 테두리는 매끄러운 단일 라운드 사각형 하나만.** 라운드 테두리(`rounded=True, radius≈0.035`) 안쪽에 좌측 사각 강조 바(square rect)를 덧대면 라운드 코너와 어긋나 지저분해진다. 좌측 바를 빼고 테두리 하나로 끝낸다.
4. **process-flow(원형 노드)와 그 아래 상세 박스/설명은 같은 열 중심축(center)에 정렬한다.** 헬퍼 `process_flow`는 자체 gap으로 노드를 배치하므로 아래 카드와 중심이 어긋난다. 4열이면 `col_w=CW/4; centers=[ML+col_w*(i+0.5)]`를 한 번 계산해 노드·노드 설명·하단 일정 박스 모두 같은 `centers[i]` 기준으로 그린다. 노드는 작으면(지름 1.15") 2줄 라벨이 위로 붙으므로 **지름 1.3" 이상** 권장.
5. **카드 안 설명은 줄글 한 문장이 아니라 `· 리드` 불릿 단위로 줄바꿈한다.** 시나리오/효과 카드의 본문은 `['문장1','문장2']` 리스트로 받아 불릿마다 `space_before≈8`로 분리하면 가독성이 크게 오른다.
6. **표 본문 행 높이는 텍스트에 맞춰 좁게.** 2줄 셀 기준 `row_h_body≈0.66~0.74`면 충분. 0.85+는 빈 공간이 과해 보인다. 표 아래 결론 문장은 plain 텍스트로 두면 표 마지막 줄과 겹치기 쉬우므로 **`takeaway` 밴드로 하이라이팅**하고 `top≈6.05`에 배치한다.
7. **전용 주제 장표와 표 한 행의 내용 중복 금지.** 예: 보안·개인정보를 한 장표가 전담하면, 리스크 매트릭스에서 같은 '보안' 행을 반복하지 말고 다른 실제 리스크(연동 지연·수용도·ROI 등)로 채운다.
8. **써머리 2×2 그리드의 강조 테두리는 카드와 동일 padding으로 감싸고, 카드 안 불릿은 시작 y를 충분히 올린다.** 테두리 rect를 `(ML, top, CW, H)`로 두고 내부 카드는 사방으로 같은 padding `p`(≈0.26")만큼 들여 배치한다. 카드 폭·시작 x를 `CW` 기준으로만 잡으면 우측 카드가 테두리에 닿거나 겹친다 — 반드시 `cw=(CW-2*p-gap)/2`, `x=ML+p+c*(cw+gap)`로 계산한다. 테두리는 `top≈1.95, H≈4.72`(bottom 6.67, footer 6.92 위)로 크게 잡아 카드 높이 `ch≈1.97"` 확보. **하단 텍스트 넘침의 진짜 원인은 카드 높이보다 "불릿이 너무 낮게 시작"하는 것** — 라벨을 카드 상단(`y+0.26`)에 붙이고, **소제목과 불릿 사이에 가로 구분선(hline)을 넣는다**(`y+0.74`, 카드 폭에서 좌우 0.38" inset, 색 `DIV≈#D3DEE8`·0.9pt). 불릿 textbox는 구분선 바로 아래 `y+0.88`에서 시작(`y+1.0` 이상이면 3번째 불릿이 카드 밖으로 밀림), 불릿 폰트 12pt·`line_spacing 1.2`·`space_before 6`로 압축한다. 소제목 위 작은 sky 악센트바는 구분선과 중복되므로 생략한다(구분선이 그 역할을 대신).
9. **알약(pill) 뱃지는 모두 같은 크기(균일 고정폭)로 통일한다.** 텍스트 길이에 맞춘 가변폭은 박스 크기가 제각각이라 "여백 동일"하게 안 보인다 — 가장 긴 라벨이 들어갈 폭 하나(예: `BW=1.7", BH=0.42`)로 **모든 뱃지를 동일 크기**로 만들고 텍스트만 중앙 정렬(`anchor=MIDDLE`)한다. 동일한 박스가 나란히 서야 시각적으로 정돈돼 보인다. 노드 위에 둘 땐 노드 top보다 `~0.2"` 위에서 끝나게 띄운다.
10. **같은 성격의 연속 장표(시점별 상세 등)는 목차에서 대주제 1개 + 소주제로 묶고, 목차 행 구분선은 제거한다.** 4개 이상의 동일 구조 장표(예: 입사 전/당일/1주/1개월 phase 상세)를 목차에 평면 나열하지 말고, `05 온보딩 플랜` 같은 대주제 한 줄 아래 각 장표 제목을 소주제 불릿(좌측 세로 강조선 + `· 제목`)으로 들여 배치한다. 소주제 텍스트는 실제 장표 제목과 1:1 일치시킨다. phase 상세 장표들의 영문 키커도 `ONBOARDING PLAN · DAY 1`처럼 공통 대주제를 접두로 달아 묶음을 시각적으로 드러낸다. **대주제+소주제 그룹이 섞인 목차에서는 행마다 hline 구분선을 넣지 않는다** — 들여쓰기 단계가 달라 구분선이 어긋나 보인다(구분선을 쓰려면 동일 레벨 행끼리만, 아니면 전부 생략). **묶음의 기준은 "레이아웃이 같은가"가 아니라 "의미상 한 주제인가"다** — 레이아웃이 제각각인 장표(예: 컨셉=카드 / 일정=timeline / 모집=two-col / 진행=flow)라도 독자가 한 덩어리로 읽는 상위 주제(예: `운영 계획`)면 묶는다. 반대로 단독으로 서야 할 장표(한 장 요약, 예산, 핵심 메시지 등)는 억지로 묶지 말고 top-level로 둔다. 보통 8장 넘는 평면 목차면 2~3개 상위 묶음으로 정리할 여지가 있는지 먼저 검토한다.
11. **하단 밴드의 화살표는 "결론·방안" 전용 신호다.** 좌측 Navy 오른쪽 화살표 + 밴드(`takeaway`)는 "→ 그래서 이렇게"라는 결론/해결방안/권고에만 쓴다. 공통 항목·단서·범례처럼 **중립적 보조 정보**를 담는 밴드에는 화살표를 빼고 밴드만 둔다(`note_band`: 화살표 없이 `ML..RX` 폭 HEAD 라운드 밴드 + Navy Bold 텍스트). 예: 예산 "공통 항목 —", 표 아래 "상품 —"은 결론이 아니므로 화살표 금지.
12. **statement(중앙 메시지) 장표의 메시지 위 짧은 가운데 Sky 바는 외따로 떠 보이면 생략한다.** 헤더(키커+제목+악센트바)가 이미 있는 장표에서 본문 중앙 위에 짧은 바를 또 두면 길 잃은 선처럼 보인다 — 메시지(Navy 30)와 부제(Sky)만으로 충분하다. 바 없이 중앙 정렬 2줄 + 부제 1줄 구조를 기본으로 한다.
13. **써머리 등 한 페이지를 통째로 강조할 땐 카드 주변 타이트 테두리 대신 "화면 가장자리 프레임"이 더 시원하다.** 헤더(키커·제목)까지 포함해 슬라이드 전체를 감싸는 라운드 프레임을 `rect(0.34, 0.34, SW-0.68, 6.5, line=SKY, lw=1.5, rounded, radius=0.018)`로 둔다(상·좌·우는 엣지 0.34", 하단은 footer 구분선 6.92 위 6.84에서 끝나 footer와 안 겹침). 카드 그리드는 프레임 안쪽에서 헤더 아래(`y≈2.05`)부터 배치. 카드 자체엔 별도 테두리를 주지 않는다(프레임 하나로 강조).
14. **타임라인/단계 노드의 뱃지·설명·제목 박스가 패널 경계를 넘지 않게 첫/끝 노드 중심을 안쪽으로 inset한다.** (이 좌우 넘침은 process-flow·timeline에서 반복되던 고질 이슈다.) 노드를 `inner_l=ML+작은값` 식으로만 배치하면, 노드 위 뱃지(`BW`)와 노드 아래 설명 박스(`DW`, 보통 가장 넓음)가 첫·끝 노드에서 패널 밖으로 삐져나간다. 해결: **가장 넓은 하위 요소의 절반폭 기준으로 가장자리 여유를 잡는다** — `inset = DW/2 + 0.2`, `first = ML+inset`, `last = ML+CW-inset`, `centers=[first+(last-first)*i/(n-1)]`. 모든 박스(뱃지·노드·제목·설명)는 같은 `centers[i]`를 중심으로 그리고, 연결선(hline)도 `first..last`로 긋는다. 뱃지·설명 박스 폭은 노드 간격(`(last-first)/(n-1)`)에서 0.3" 이상 여유가 남게 잡는다. 뱃지 텍스트가 길면 폭을 키우지 말고 폰트를 낮춘다(11pt 전후, 한 줄 고정).
15. **제목 밑 소제목(subtitle)과 본문 첫 리드 문장이 같은 말을 반복하지 않게 한다.** (한 장표 안에서 같은 주장을 두 번 쓰는 중복이 자주 발생한다 — 특히 소제목과 본문 강조 리드.) 역할을 분리한다: **소제목 = 이 장표의 한 줄 핵심 주장**, **본문 리드 = 그 아래 카드/패널/불릿을 끌어오는 다른 정보**(대비·근거·구성 축·전제 등). 두 문장에 같은 키워드 덩어리(예: "가공 DB 위 자연어 탐색", "자발적으로 등록한 관심 후보")가 모두 나오면 한쪽을 다시 쓴다. 본문 리드가 카드 묶음을 끌어올 땐 카드 제목을 그대로 나열하지 말고, 카드들을 하나로 묶는 상위 관점("모집 시작 시점에 이미 유리한 세 조건" 등)으로 쓴다. 생성 직후 **각 장표에서 소제목·리드·캡션을 나란히 읽어 같은 뜻이 반복되는지 점검**한다.

---

## 공통 코드 패턴 (검증된 헬퍼 — 그대로 사용)

```python
import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.oxml.ns import qn
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE

FONT = 'Pretendard'

NAVY=RGBColor(0x00,0x35,0x69); BLUE=RGBColor(0x1B,0x36,0x5D); SKY=RGBColor(0x4D,0xA8,0xDA)
LSKY=RGBColor(0xB8,0xDC,0xF0); SUB=RGBColor(0x8C,0xA0,0xB3); CARD=RGBColor(0xF5,0xF8,0xFB)
BORDER=RGBColor(0xE3,0xEA,0xF1); HEAD=RGBColor(0xE8,0xEE,0xF3); WHITE=RGBColor(0xFF,0xFF,0xFF)
SW,SH=13.333,7.5; ML,MR=0.9,0.9; CW=SW-ML-MR; RX=SW-MR; TOTAL=11

def _style(run, size, color, bold=False, spacing=None):
    run.font.size=Pt(size); run.font.bold=bold; run.font.color.rgb=color; run.font.name=FONT
    rPr=run._r.get_or_add_rPr()
    ea=rPr.find(qn('a:ea'))
    if ea is None:
        ea=rPr.makeelement(qn('a:ea'),{}); latin=rPr.find(qn('a:latin'))
        (latin.addnext(ea) if latin is not None else rPr.append(ea))
    ea.set('typeface',FONT)
    if spacing is not None: rPr.set('spc',str(int(spacing*100)))

def textbox(slide,l,t,w,h,anchor=MSO_ANCHOR.TOP):
    tb=slide.shapes.add_textbox(Inches(l),Inches(t),Inches(w),Inches(h)); tf=tb.text_frame
    tf.word_wrap=True; tf.margin_left=tf.margin_right=tf.margin_top=tf.margin_bottom=0
    tf.vertical_anchor=anchor; return tf

def para(tf,text,size,color,bold=False,align=PP_ALIGN.LEFT,line_spacing=None,
         space_before=None,space_after=None,spacing=None,first=False):
    p=tf.paragraphs[0] if first and not tf.paragraphs[0].runs else tf.add_paragraph()
    p.alignment=align
    if line_spacing: p.line_spacing=line_spacing
    if space_before is not None: p.space_before=Pt(space_before)
    if space_after is not None: p.space_after=Pt(space_after)
    r=p.add_run(); r.text=text; _style(r,size,color,bold,spacing); return p

def _noshadow(sp):                     # 핵심: 완전 플랫 (테마 그림자 제거)
    sp.shadow.inherit=False
    st=sp._element.find(qn('p:style'))
    if st is not None: sp._element.remove(st)

def rect(slide,l,t,w,h,fill=None,line=None,lw=1.0,rounded=False,radius=0.06):
    shape=MSO_SHAPE.ROUNDED_RECTANGLE if rounded else MSO_SHAPE.RECTANGLE
    sp=slide.shapes.add_shape(shape,Inches(l),Inches(t),Inches(w),Inches(h))
    if rounded:
        try: sp.adjustments[0]=radius
        except Exception: pass
    if fill is None: sp.fill.background()
    else: sp.fill.solid(); sp.fill.fore_color.rgb=fill
    if line is None: sp.line.fill.background()
    else: sp.line.color.rgb=line; sp.line.width=Pt(lw)
    _noshadow(sp); return sp

def oval(slide,l,t,w,h,fill,alpha=None):
    sp=slide.shapes.add_shape(MSO_SHAPE.OVAL,Inches(l),Inches(t),Inches(w),Inches(h))
    sp.fill.solid(); sp.fill.fore_color.rgb=fill; sp.line.fill.background(); _noshadow(sp)
    if alpha is not None:
        srgb=sp._element.spPr.find(qn('a:solidFill')).find(qn('a:srgbClr'))
        a=srgb.makeelement(qn('a:alpha'),{}); a.set('val',str(int(alpha*1000))); srgb.append(a)
    return sp

def hline(slide,l,t,w,color,weight=0.75):
    ln=slide.shapes.add_connector(2,Inches(l),Inches(t),Inches(l+w),Inches(t))
    ln.line.color.rgb=color; ln.line.width=Pt(weight); _noshadow(ln); return ln

def header(slide,kicker,title):        # 키커(영문) ≠ 제목(한글)
    para(textbox(slide,ML,0.62,CW,0.32),kicker.upper(),11,SKY,bold=True,spacing=2.2,first=True)
    para(textbox(slide,ML,0.96,CW,0.7),title,29,NAVY,bold=True,first=True)
    rect(slide,ML,1.66,0.55,0.045,fill=SKY)

def footer(slide,deck='문서명'):
    page=len(prs.slides._sldIdLst)     # 자동: 방금 추가된 이 슬라이드의 1-based 위치 (수동 번호 X)
    hline(slide,ML,6.92,CW,BORDER,0.75)
    para(textbox(slide,ML,6.99,7,0.3),deck,9,SUB,first=True)
    tf=textbox(slide,RX-2.0,6.99,2.0,0.3,anchor=MSO_ANCHOR.MIDDLE)  # 우측 끝 정렬 (로고 없음)
    p=tf.paragraphs[0]; p.alignment=PP_ALIGN.RIGHT
    r=p.add_run(); r.text=f'{page:02d}'; _style(r,10,NAVY,bold=True)
    r=p.add_run(); r.text=f'  /  {TOTAL:02d}'; _style(r,10,SUB)   # TOTAL은 전체 장수 상수

def deco_circles(slide):               # cover / end
    oval(slide,9.1,2.0,6.6,6.6,LSKY,alpha=14); oval(slide,11.0,0.5,3.3,3.3,SKY,alpha=8)

def numbered(slide,items,top=2.1,bottom=6.6):   # bullets/agenda 레이아웃: (리드, 설명) 쌍
    n=len(items); rh=(bottom-top)/n
    for i,(lead,desc) in enumerate(items):
        y=top+i*rh
        para(textbox(slide,ML,y,0.9,rh),f'{i+1:02d}',22,SKY,bold=True,first=True)
        tf=textbox(slide,ML+0.95,y,CW-0.95,rh)
        para(tf,lead,16.5,NAVY,bold=True,first=True)
        if desc: para(tf,desc,13,BLUE,line_spacing=1.3,space_before=4)
        if i<n-1: hline(slide,ML,y+rh-0.06,CW,BORDER,0.5)

def label_rows(slide,rows,top=2.2,row_h=1.0,gap=0.22,chip_w=2.7):  # 라벨칩 + 설명 카드
    for i,(label,desc) in enumerate(rows):
        y=top+i*(row_h+gap)
        rect(slide,ML,y,chip_w,row_h,fill=HEAD,rounded=True,radius=0.08)
        para(textbox(slide,ML+0.18,y,chip_w-0.36,row_h,anchor=MSO_ANCHOR.MIDDLE),
             label,15,NAVY,bold=True,align=PP_ALIGN.CENTER,first=True,line_spacing=1.1)
        dx=ML+chip_w+0.25; dw=RX-dx
        rect(slide,dx,y,dw,row_h,fill=CARD,rounded=True,radius=0.05)
        para(textbox(slide,dx+0.4,y,dw-0.8,row_h,anchor=MSO_ANCHOR.MIDDLE),
             desc,13.5,BLUE,first=True,line_spacing=1.3)

def takeaway(slide,text,top):          # 하단 결론 화살표 밴드 ("→ 그래서")
    ar=slide.shapes.add_shape(MSO_SHAPE.RIGHT_ARROW,Inches(ML),Inches(top+0.06),Inches(0.55),Inches(0.54))
    ar.fill.solid(); ar.fill.fore_color.rgb=NAVY; ar.line.fill.background(); _noshadow(ar)
    bx=ML+0.78; rect(slide,bx,top,RX-bx,0.66,fill=HEAD,rounded=True,radius=0.12)
    para(textbox(slide,bx+0.45,top,RX-bx-0.9,0.66,anchor=MSO_ANCHOR.MIDDLE),text,14,NAVY,bold=True,first=True)

def process_flow(slide,nodes,top=2.6,node_d=1.5,fill=NAVY):   # 원형 노드 + 화살표 프로세스
    n=len(nodes); gap=(CW-node_d*n)/(n-1) if n>1 else 0; cy=top+node_d/2
    for i,(label,desc) in enumerate(nodes):
        x=ML+i*(node_d+gap); oval(slide,x,top,node_d,node_d,fill)
        para(textbox(slide,x+0.1,top,node_d-0.2,node_d,anchor=MSO_ANCHOR.MIDDLE),
             label,14,WHITE,bold=True,align=PP_ALIGN.CENTER,first=True,line_spacing=1.15)
        if i<n-1:
            ax=x+node_d+gap*0.18
            ar=slide.shapes.add_shape(MSO_SHAPE.RIGHT_ARROW,Inches(ax),Inches(cy-0.13),Inches(gap*0.64),Inches(0.26))
            ar.fill.solid(); ar.fill.fore_color.rgb=SKY; ar.line.fill.background(); _noshadow(ar)
        if desc:
            para(textbox(slide,x-gap*0.4,top+node_d+0.2,node_d+gap*0.8,1.1),
                 desc,11,SUB,align=PP_ALIGN.CENTER,line_spacing=1.25,first=True)

def _table_clean(table):               # 테마 스타일 제거 → 셀 직접 제어
    tbl=table._tbl; tblPr=tbl.find(qn('a:tblPr'))
    if tblPr is None: tblPr=tbl.makeelement(qn('a:tblPr'),{}); tbl.insert(0,tblPr)
    tblPr.set('firstRow','0'); tblPr.set('bandRow','0')
    for c in list(tblPr):
        if c.tag==qn('a:tableStyleId'): tblPr.remove(c)
    sid=tblPr.makeelement(qn('a:tableStyleId'),{}); sid.text='{2D5ABB26-0587-4C30-8999-92F81FD0307C}'
    tblPr.append(sid)   # No Style, No Grid
```

타임라인·stats·table·two-col 등 각 레이아웃의 전체 구현은 위 헬퍼로 조립한다 (대표 구현은 본 스킬이 생성한 기획안 스크립트 참조).

---

## PDF 저장 + 렌더링 검증 패턴

`.pdf`는 산출물로 `./output`에 영구 저장하고, 검증 이미지는 `/tmp/render`에 임시 생성한다.

```bash
SOFFICE=/Applications/LibreOffice.app/Contents/MacOS/soffice   # 또는 PATH의 soffice
rm -rf /tmp/render && mkdir /tmp/render
# pptx → pdf (output 폴더에 산출물로 저장)
"$SOFFICE" --headless --convert-to pdf --outdir ./output ./output/파일.pptx
# pdf → png (검증용 임시 이미지)
pdftoppm -png -r 110 ./output/파일.pdf /tmp/render/slide
# 생성된 /tmp/render/slide-*.png 를 Read로 한 장씩 점검
```
점검 항목: 폰트 깨짐 / 텍스트 넘침·잘림 / 빈 영역 과다 / 그림자 잔존 / 정렬·간격 / **명사형 종결**.

---

## 출력 예시

```
✅ PPT 생성 완료!

📄 PPTX: ./output/general-2026-06-01.pptx
📑 PDF:  ./output/general-2026-06-01.pdf
📊 슬라이드: 14장
📋 유형: 범용 기획안 (general)
🎨 테마: 기본 스타일 (Pretendard · Navy/Sky · 플랫 · 명사형 종결)
🔍 검증: 14장 전체 렌더링 확인 완료

파일을 열어서 확인해보세요.
```

---

## 컨펌 사례 벤치마크 (Approved Deck Benchmarks)

컨펌된 덱 사례는 **별도 파일 `~/.claude/commands/ppt_benchmarks.md`** 에서 관리한다(사례가 늘어도 이 본체는 가볍게 유지). Step 0에서 그 파일을 Read로 읽어 품질 기준으로 삼고, 새 덱이 컨펌되면 **그 파일에** 한 항목을 추가한다(이 파일이 아니라). 일반화 가능한 레이아웃·정렬 교훈은 위 "검증된 레이아웃·정렬 교훈" 섹션에 추가한다.

이식 시 함께 가야 하는 파일: `ppt.md` + `ppt_benchmarks.md`.
