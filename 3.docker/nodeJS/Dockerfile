# 베이스 이미지 설정
FROM node:14

# 작업 디렉토리 설정
WORKDIR /usr/src/app

# 의존성 파일들을 작업 디렉토리로 복사
COPY package*.json ./

# 의존성 설치
RUN npm install

# 소스 코드를 작업 디렉토리로 복사
COPY . .

# Node.js 서비스를 실행할 포트 번호를 지정
EXPOSE 8080

# 애플리케이션 실행
CMD [ "node", "server.js" ]