# FastAPIService
 FastAPI-based usermanagment service 

## Features
- User Registration
- Secure Login Authentication
- Profile Update for Authenticated Users
- Password Hashing
- Token-Based Authentication

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/dima31722/FastAPIService.git
   cd FastAPIService
   ```

2. Create virtual environment and Install packages:
   ```bash
   python -m venv venv 
   venv/Scripts/activate
   pip -m install --upgrade pip 
   pip install -r requirements.txt 
   ```

## SQL connection

1. create user in mysql:
   ```bash
   mysql -u root -p
   CREATE DATABASE users; 
   CREATE USER 'new_user'@'localhost' IDENTIFIED BY 'password'; 
   GRANT ALL PRIVILEGES ON users.* TO 'new_user'@'localhost'; 
   FLUSH PRIVILEGES;
   EXIT;
   ```

## redis connection 

1. test redis server is running:
   - check redis server is running
      - redis-cli ping (expected: PONG)
   - check server can run throw windows firewall

2. - check password and host in /path/to/redis.conf
      - password in line : requirepass "mypassword123"
      - host in line: bind 127.0.0.1

3. - if redis server won't run or assosiated to fastAPI server - will fetch data from database


## .env file
1. create .env file for the project with this env variables:
   ### enter missing variables or change according to your setup 
   ```bash
   MYSQL_USER = 
   MYSQL_PASSWORD = 
   MYSQL_HOST = localhost #default
   MYSQL_PORT = 3306 #default
   DATABASE_NAME = users

   SECRET_KEY = "SECRETKEY" 
   ALGORITHM = "HS256" 

   REDIS_HOST = 
   REDIS_PORT = "6379" #default
   REDIS_PASSWORD = 
   ```

## run the project 
   ```bash
   python main.py
   ```
   - should be: "http://127.0.0.1:8080"

## run test file curl
1. check that curl and jq installed in your bash
   ```bash
   curl --version
   jq --version
   chmod +x test_service.sh
   ./test_service.sh
   ```

   - test_service.log - file made with the logs from curl test











