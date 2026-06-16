@echo off
setlocal

:: Tenta encontrar o compilador do PureBasic nos lugares padroes
set "PB_COMPILER=C:\Program Files\PureBasic\Compilers\pbcompiler.exe"
if not exist "%PB_COMPILER%" (
    set "PB_COMPILER=C:\PureBasic\Compilers\pbcompiler.exe"
)

:: Se o PB estiver em outro lugar ou no PATH
if not exist "%PB_COMPILER%" (
    :: Vamos checar se esta no PATH (testando chamada)
    where pbcompiler >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set "PB_COMPILER=pbcompiler"
    ) else (
        echo [ERRO] O pbcompiler.exe nao foi encontrado!
        echo Abra este arquivo .bat no bloco de notas e edite o caminho do PB_COMPILER.
        pause
        exit /b 1
    )
)

echo ==========================================
echo       Compilador Jacazul - Collider       
echo ==========================================
echo.
set /p OUT_NAME="Digite o nome do executavel (ex: Collider_BR10.exe) ou de enter para 'Collider_BR.exe': "

if "%OUT_NAME%"=="" set "OUT_NAME=Collider_BR.exe"

echo.
echo [INFO] Compilando Collider.pb para -^> ..\x64\%OUT_NAME%
echo [INFO] Usando compilador: %PB_COMPILER%
echo.

"%PB_COMPILER%" Collider.pb /EXE "..\x64\%OUT_NAME%" /CONSOLE /THREAD

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [SUCESSO] %OUT_NAME% compilado e pronto pro abate!
) else (
    echo.
    echo [ERRO] A compilacao falhou. De uma olhada no console acima.
)

pause
