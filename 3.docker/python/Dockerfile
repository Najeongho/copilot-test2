# 베이스 이미지 설정
FROM python:3.8-slim-buster

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 파일들을 작업 디렉토리로 복사
COPY requirements.txt .

# 의존성 설치
RUN pip install --no-cache-dir -r requirements.txt

# 소스 코드를 작업 디렉토리로 복사
COPY . .

# 애플리케이션 실행
CMD ["python", "./your-script.py"]