@echo off
rem Arctic 데이터 뷰어 로컬 서버 실행
rem index.html 이 catalog.json / COG 를 fetch 로 읽기 때문에
rem file:// 로는 동작하지 않고 로컬 HTTP 서버가 필요합니다.
rem range_server.py 는 COG 부분 읽기(HTTP Range)를 지원해 로딩이 빠릅니다.
cd /d "%~dp0"
echo.
echo  Arctic 데이터 뷰어 서버 시작: http://localhost:8000
echo  종료하려면 Ctrl+C
echo.
start "" http://localhost:8000
python range_server.py 8000
