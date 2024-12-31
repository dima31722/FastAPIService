# Base URL of the API
BASE_URL="http://127.0.0.1:8080"

# Log file
LOG_FILE="test_service.log"

# -----------------------------
# Utility Functions
# -----------------------------

# Function to log messages with timestamps
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") : $1" | tee -a "$LOG_FILE"
}

# # Function to check if jq is installed
check_jq() {
  if ! command -v jq &> /dev/null
  then
    log "Error: jq could not be found. Please install jq to proceed."
    exit 1
  fi
}

# -----------------------------
# Initialization
# -----------------------------

# Clear previous log
> "$LOG_FILE"

log "Starting API tests..."

# Check if jq is installed
check_jq

# -----------------------------
# Test 1: Register a New User
# -----------------------------

log "1. Registering a new user..."

REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/register" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "dima",
    "last_name": "ku",
    "email": "dima.ku@example.com",
    "password": "pass"
  }')

echo "$REGISTER_RESPONSE" | tee -a "$LOG_FILE"

# -----------------------------
# Test 2: Register the Same User Again
# -----------------------------

log "2. Registering the same user again to get invalid message..."

REGISTER_DUP_RESPONSE=$(curl -s -X POST "$BASE_URL/register" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "dima",
    "last_name": "ku",
    "email": "dima.ku@example.com",
    "password": "pass"
  }')

echo "$REGISTER_DUP_RESPONSE" | tee -a "$LOG_FILE"


# # -----------------------------
# # Test 3: Login with Correct Credentials
# # -----------------------------

log "3. Logging in with correct credentials to obtain access token..."

LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "dima.ku@example.com",
    "password": "pass"
  }')

echo "$LOGIN_RESPONSE" | tee -a "$LOG_FILE"

# Extract Access Token using jq
ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.access_token')

# -----------------------------
# Test 4: Login with Invalid Email
# -----------------------------

log "4. Logging in with invalid email..."

LOGIN_INVALID_EMAIL_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "dima.dima@example.com",
    "password": "pass"
  }')

echo "$LOGIN_INVALID_EMAIL_RESPONSE" | tee -a "$LOG_FILE"


# -----------------------------
# Test 5: Login with Invalid Password
# -----------------------------

log "5. Logging in with invalid password..."

LOGIN_INVALID_PASSWORD_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "dima.ku@example.com",
    "password": "pass1"
  }')

echo "$LOGIN_INVALID_PASSWORD_RESPONSE" | tee -a "$LOG_FILE"


# -----------------------------
# Test 6: Update User Details with Valid Token
# -----------------------------

log "6. Updating user details with valid token..."

UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/update" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "first_name": "moshe",
    "last_name": "lo",
    "email": "moshe.lo@example.com"
  }')

echo "$UPDATE_RESPONSE" | tee -a "$LOG_FILE"



# -----------------------------
# Test 7: Update User Details with Invalid Token
# -----------------------------

log "7. Trying to update user details with invalid token..."

INVALID_TOKEN="invalid.token.value"

UPDATE_INVALID_TOKEN_RESPONSE=$(curl -s -X PUT "$BASE_URL/update" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $INVALID_TOKEN" \
  -d '{
    "first_name": "moshe",
    "last_name": "lo",
    "email": "moshe.lo@example.com"
  }')

echo "$UPDATE_INVALID_TOKEN_RESPONSE" | tee -a "$LOG_FILE"



# -----------------------------
# Test 8: Retrieve User Profile with Valid Token
# -----------------------------

log "8. Retrieving user profile with valid token..."

PROFILE_RESPONSE=$(curl -s -X GET "$BASE_URL/profile" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

echo "$PROFILE_RESPONSE" | tee -a "$LOG_FILE"

# Extract Email using jq
ACTUAL_EMAIL=$(echo "$PROFILE_RESPONSE" | jq -r '.email')



# -----------------------------
# Test 9: Retrieve User Profile with Invalid Token
# -----------------------------

log "9. Retrieving user profile with invalid token..."

PROFILE_INVALID_TOKEN_RESPONSE=$(curl -s -X GET "$BASE_URL/profile" \
  -H "Authorization: Bearer $INVALID_TOKEN")

echo "$PROFILE_INVALID_TOKEN_RESPONSE" | tee -a "$LOG_FILE"


# -----------------------------
# Completion
# -----------------------------

log "API tests completed."

# Optional: Display the log file content
echo "===== API Test Log ====="
cat "$LOG_FILE"
