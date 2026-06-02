# /ppt 스킬 설치 (Windows / PowerShell) — 비개발자도 한 줄이면 끝.
#   한 줄 설치:  irm https://raw.githubusercontent.com/annie-recruit/claude-ppt-skill/main/install.ps1 | iex
#   Python · python-pptx · PyMuPDF · Pretendard 폰트 · (선택)LibreOffice 자동 설치 + 스킬 파일 복사.
#   git 불필요(레포 zip을 받아서 설치). 관리자 권한 불필요(사용자 단위 설치).

$ErrorActionPreference = 'Stop'
$Repo = 'annie-recruit/claude-ppt-skill'
$Dest = Join-Path $env:USERPROFILE '.claude\commands'

function Say($m){  Write-Host "▶ $m" -ForegroundColor Cyan }
function Ok($m){   Write-Host "  [OK] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }

function Get-Py {
    foreach($c in 'py','python','python3'){
        $cmd = Get-Command $c -ErrorAction SilentlyContinue
        if($cmd){ return $c }
    }
    return $null
}

# 1) Python 확인 / 설치 --------------------------------------------------
$py = Get-Py
if(-not $py){
    if(Get-Command winget -ErrorAction SilentlyContinue){
        Say 'Python 설치 (winget)'
        winget install -e --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent
        $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
        $py = Get-Py
    }
}
if(-not $py){
    Warn 'Python을 찾지 못했습니다. https://www.python.org/downloads/ 에서 설치(설치 시 "Add to PATH" 체크) 후 다시 실행하세요.'
    return
}
Ok "Python: $py"

# 2) 레포 내려받기 (zip, git 불필요) ------------------------------------
Say '스킬 레포 내려받기'
$tmp = Join-Path $env:TEMP ('pptskill_' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp -Force | Out-Null
$zip = Join-Path $tmp 'repo.zip'
$old = $ProgressPreference; $ProgressPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}  # 구버전 PowerShell 5.1 TLS 보강
Invoke-WebRequest -Uri "https://codeload.github.com/$Repo/zip/refs/heads/main" -OutFile $zip
Expand-Archive -Path $zip -DestinationPath $tmp -Force
$ProgressPreference = $old
$src = Join-Path $tmp 'claude-ppt-skill-main'
if(-not (Test-Path (Join-Path $src 'ppt.md'))){ Warn '레포 구조가 예상과 다릅니다.'; return }
Ok '내려받기 완료'

# 3) 스킬 파일 복사 -----------------------------------------------------
Say "스킬 파일 복사 -> $Dest"
New-Item -ItemType Directory -Path (Join-Path $Dest 'assets') -Force | Out-Null
Copy-Item (Join-Path $src 'ppt.md')            $Dest -Force
Copy-Item (Join-Path $src 'ppt_benchmarks.md') $Dest -Force
Copy-Item (Join-Path $src 'assets\*')          (Join-Path $Dest 'assets') -Force
Ok 'ppt.md · ppt_benchmarks.md · assets/ 복사 완료'

# 4) Python 패키지 (필수) -----------------------------------------------
Say 'Python 패키지 설치 (python-pptx · PyMuPDF)'
& $py -m pip install --quiet --upgrade pip 2>$null
& $py -m pip install --quiet python-pptx PyMuPDF
if($LASTEXITCODE -ne 0){
    & $py -m pip install --quiet --user python-pptx PyMuPDF
}
Ok 'python-pptx · PyMuPDF 설치 완료'

# 5) Pretendard 폰트 (사용자 단위 — 관리자 권한 불필요) -----------------
Say 'Pretendard 폰트 설치'
try{
    $fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    New-Item -ItemType Directory -Path $fontDir -Force | Out-Null
    $reg = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    if(-not (Test-Path $reg)){ New-Item -Path $reg -Force | Out-Null }
    Get-ChildItem (Join-Path $Dest 'assets') -Filter 'Pretendard-*.otf' | ForEach-Object {
        $target = Join-Path $fontDir $_.Name
        Copy-Item $_.FullName $target -Force
        New-ItemProperty -Path $reg -Name ("$($_.BaseName) (OpenType)") -Value $target -PropertyType String -Force | Out-Null
    }
    Ok '폰트 설치 완료'
}catch{
    Warn "폰트 설치 건너뜀: $($_.Exception.Message)"
}

# 6) LibreOffice (선택 — PDF 렌더 검증용) -------------------------------
$soffice = 'C:\Program Files\LibreOffice\program\soffice.exe'
if(-not (Test-Path $soffice)){
    if(Get-Command winget -ErrorAction SilentlyContinue){
        Say 'LibreOffice 설치 (렌더 검증용 · 용량 큼, 수 분 소요)'
        try{
            winget install -e --id TheDocumentFoundation.LibreOffice --accept-source-agreements --accept-package-agreements --silent
            Ok 'LibreOffice 설치 완료'
        }catch{ Warn 'LibreOffice 설치 실패 — 없어도 .pptx 생성은 됩니다.' }
    }else{
        Warn 'winget 없음 — LibreOffice는 수동 설치 (없어도 .pptx 생성은 됩니다).'
    }
}else{ Ok 'LibreOffice 확인됨' }

# 7) 정리 + 검증 --------------------------------------------------------
Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
Say '설치 검증'
$verify = $true
if(Test-Path (Join-Path $Dest 'ppt.md')){ Ok 'ppt.md 확인' } else { Warn 'ppt.md 없음'; $verify = $false }
if(Test-Path (Join-Path $Dest 'ppt_benchmarks.md')){ Ok 'ppt_benchmarks.md 확인' } else { Warn 'ppt_benchmarks.md 없음'; $verify = $false }
try{
    & $py -c "import pptx, fitz; print('deps ok')" | Out-Null
    if($LASTEXITCODE -eq 0){ Ok 'python-pptx · PyMuPDF import 확인' } else { Warn 'Python 패키지 import 실패'; $verify = $false }
}catch{ Warn 'Python 패키지 import 실패'; $verify = $false }

Write-Host ''
if($verify){
    Ok '설치 완료!  Claude Code에서   /ppt <기획 내용>   으로 사용하세요.'
}else{
    Warn '일부 항목이 누락됐습니다. 위 메시지를 확인하세요.'
}
