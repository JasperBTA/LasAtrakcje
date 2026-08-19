@echo off
setlocal

:: Próba znalezienia wbudowanej Javy w Android Studio, jeśli JAVA_HOME nie jest ustawione
if "%JAVA_HOME%"=="" (
    if exist "C:\Program Files\Android\Android Studio\jbr" (
        set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
        echo [INFO] Znaleziono Jave w Android Studio: %JAVA_HOME%
    ) else if exist "C:\Program Files\Android\Android Studio\jre" (
        set "JAVA_HOME=C:\Program Files\Android\Android Studio\jre"
        echo [INFO] Znaleziono Jave w Android Studio: %JAVA_HOME%
    )
)

set MAVEN_VERSION=3.9.7
set MAVEN_DIR=.mvn\apache-maven-%MAVEN_VERSION%
if not exist "%MAVEN_DIR%" (
    echo [INFO] Pobieranie Apache Maven %MAVEN_VERSION%...
    if not exist ".mvn" mkdir .mvn
    powershell -Command "Invoke-WebRequest -Uri https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/%MAVEN_VERSION%/apache-maven-%MAVEN_VERSION%-bin.zip -OutFile maven.zip"
    echo [INFO] Rozpakowywanie Mavena...
    powershell -Command "Expand-Archive -Path maven.zip -DestinationPath .mvn -Force"
    del maven.zip
)

"%MAVEN_DIR%\bin\mvn.cmd" %*
