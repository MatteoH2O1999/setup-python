$Version = $env:PYTHON_VERSION
$PythonPath = $env:SETUP_PYTHON_PATH
$Semver = $Version.Split('.')
$pip = 0
if ([int]$Semver[0] -eq 3 -and [int]$Semver[1] -ge 4) {
    Invoke-Expression -Command "$PythonPath -m ensurepip"
    if ([int]$Semver[1] -gt 4) {
        Invoke-Expression -Command "$PythonPath -m pip install --upgrade pip"
    }
    $pip = 1
} elseif ([int]$Semver[1] -ge 3) {
    $GetPipFile = New-TemporaryFile
    Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/pip/3.3/get-pip.py' -OutFile $GetPipFile
    Invoke-Expression -Command "$PythonPath $GetPipFile"
    Remove-Item $GetPipFile
    $pip = 1
}
if ($pip) {
    if ([int]$Semver[0] -eq 3 -and [int]$Semver[1] -lt 5) {
        Invoke-Expression -Command "$PythonPath -m pip install typing"
    }
    Invoke-Expression -Command "$PythonPath -m pip install --upgrade wheel setuptools"
}