# 베이스 이미지 설정
FROM golang:1.16-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 소스 코드를 작업 디렉토리로 복사
COPY . .

# Go 모듈 다운로드
RUN go mod download

# 애플리케이션 빌드
RUN go build -o main .

# 애플리케이션 실행
CMD ["/app/main"]