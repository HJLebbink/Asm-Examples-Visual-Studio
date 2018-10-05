echo off
cls
del *.log

set JAVA_PATH="C:\Program Files (x86)\Java\jdk1.8.0_73"
rem set JAVA_PATH="C:\Program Files (x86)\Java\jdk1.8.0_73"
rem echo [%JAVA_PATH%]

copy ..\..\..\Release\ExampleAppJni1.dll .\ExampleAppJni1_32.dll

%JAVA_PATH%\bin\java -version
echo ----------------------------
rem %JAVA_PATH%\bin\javah JniTest1
echo ----------------------------
%JAVA_PATH%\bin\javac JniTest1.java
echo ----------------------------
%JAVA_PATH%\bin\java JniTest1
echo ----------------------------

@pause