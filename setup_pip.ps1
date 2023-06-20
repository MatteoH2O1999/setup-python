$Version = $env:PYTHON_VERSION
$PythonPath = $env:SETUP_PYTHON_PATH
$Semver = $Version.Split('.')
Write-Output "Setting up pip for python $Version in path $PythonPath"
if (!($Semver[0] -like 'pypy*') -and ([int]$Semver[0] -eq 3 -and [int]$Semver[1] -lt 5)) {
    if ([int]$Semver[1] -gt 2) {
        Write-Output "Using get_pip.py..."
        $VersionNumber = $Semver[0]
        $Major = $Semver[1]
        $GetPipFile = New-TemporaryFile
        Invoke-WebRequest -Uri "https://bootstrap.pypa.io/pip/$VersionNumber.$Major/get-pip.py" -OutFile $GetPipFile
        Invoke-Expression -Command "$PythonPath $GetPipFile"
        Write-Output "Installing typing for old Python versions..."
        Invoke-Expression -Command "$PythonPath -m pip install typing"
        Remove-Item $GetPipFile
        if ([int]$Semver[1] -eq 4) {
            Invoke-Expression -Command "$PythonPath -m pip install --upgrade wheel setuptools"
        }
    } else {
        Write-Output "Pip is not available for version $Version"
        Write-Output "Proceed with manual installation at own risk"
    }
} else {
    Write-Output "Using ensurepip..."
    Invoke-Expression -Command "$PythonPath -m ensurepip"
    Invoke-Expression -Command "$PythonPath -m pip install --upgrade pip"
    Write-Output "Installing wheel and setuptools..."
    Invoke-Expression -Command "$PythonPath -m pip install --upgrade wheel setuptools"
}