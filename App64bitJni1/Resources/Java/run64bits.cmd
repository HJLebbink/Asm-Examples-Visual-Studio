echo off
cls
del *.log

set JAVA_PATH="C:\Program Files\Java\jdk1.8.0_71"
rem set JAVA_PATH="C:\Program Files\Java\jdk1.8.0_66"
rem echo [%JAVA_PATH%]

copy ..\..\..\x64\Release\ExampleAppJni1.dll .\ExampleAppJni1_64.dll

%JAVA_PATH%\bin\java -version
echo ----------------------------
%JAVA_PATH%\bin\javah JniTest1
echo ----------------------------
%JAVA_PATH%\bin\javac JniTest1.java
echo ----------------------------
%JAVA_PATH%\bin\java JniTest1
echo ----------------------------

@pause



