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

2. Install packages:
   ```bash
    python -m venv venv 
    venv/Scripts/activate
    pip -m install --upgrade pip 
    pip install -r requirements.txt 

## SQL connection

1. create user in mysql:
   ```cmd
   mysql -u root -p
   CREATE DATABASE users; 
   CREATE USER 'new_user'@'localhost' IDENTIFIED BY 'password'; 
   GRANT ALL PRIVILEGES ON users.* TO 'new_user'@'localhost'; 
   FLUSH PRIVILEGES;
   EXIT;

## redis connection 

1. test redis is running:
    if using ububtu - run "redis-cli ping"
    expected return: PONG

## run the project 
    ```
    python main.py







