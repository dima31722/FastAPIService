from fastapi import FastAPI, HTTPException, Depends, Request, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
import uvicorn
from contextlib import asynccontextmanager

from database import Base, engine, get_db
from models import User
from schemas import UserCreate, UserLogin, UserUpdate, UserProfile
from authentication import (
    create_hash_password,
    verify_hashing,
    create_token,
    TokenAuthorizationMiddleware
)
from caching import check_cache, update_cache

#on startup of the application - run the database
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Create all tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    
app = FastAPI(lifespan=lifespan)

#create CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  #because we dont have fronend app, we use postman so we allow all
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
#create token middleware - made at authentication.py
app.add_middleware(TokenAuthorizationMiddleware)


@app.post("/register", response_model=str, status_code=status.HTTP_201_CREATED)
async def register_user(req:UserCreate, db: AsyncSession = Depends(get_db)):
    
    #if password or username won't enter, fastapi will raise exception 422
    result = await db.execute(select(User).filter_by(email=req.email))
    user = result.scalars().first()
    if user:
        raise HTTPException(status_code=400, detail=f"user's email already exists")
    
    hashed_password = create_hash_password(req.password)
    
    new_user = User(
        first_name=req.first_name,
        last_name=req.last_name,
        email=req.email,
        password=hashed_password
    )

    db.add(new_user)
    db.refresh(new_user)

    return f"user with email: {new_user.email} - created successfully"
    

@app.post("/login", response_model=dict, status_code=status.HTTP_200_OK)
async def login_user(req:UserLogin, db: AsyncSession = Depends(get_db)):
    #check email
    result = await db.execute(select(User).filter_by(email=req.email))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=400, detail=f"Invalid email")
    
    #check password
    if not verify_hashing(req.password, user.password):
        raise HTTPException(status_code=400, detail=f"Invalid password")
    
    # the default for delta_minutes is 10 - change value here if you want to 
    token = create_token({"sub":user.email, "user_id":user.id}, delta_minutes=30)
    return {"access_token":token, "token_type":"bearer"}


@app.put("/update", response_model=dict, status_code=status.HTTP_200_OK)
async def update_user(req:UserUpdate, request:Request, db: AsyncSession = Depends(get_db)):
    #req - the body - means here getting the data to update
    #request - the headers - means here checking the authorization of the middleware
    user_id = getattr(request.state, "user_id", None)
    if not user_id:
        # If somehow no user_id is set, raise 401
        raise HTTPException(status_code=401, detail=f"no user_id in token")
    
    result = await db.execute(select(User).filter_by(id=user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail=f"User not found")
    
    #for every variable - checking if exists in the request
    if req.email is not None:
        result = await db.execute(select(User).filter_by(email=req.email))
        check_user = result.scalars().first()
        if check_user:
            raise HTTPException(status_code=500, detail=f"email already exists in database")
        user.email = req.email
    if req.first_name is not None:
        user.first_name = req.first_name
    if req.last_name is not None:
        user.last_name = req.last_name
    if req.password is not None:
        # You might want to hash the new password before storing
        user.password = create_hash_password(req.password)
    try:
        await update_cache(user)
    except Exception as e:
        pass

    return {"message": "User updated successfully", "username": f"{user.first_name} {user.last_name}"}

@app.get("/profile", response_model=UserProfile, status_code=status.HTTP_200_OK)
async def get_user_profile(request: Request, db: AsyncSession = Depends(get_db)):
    user_id = getattr(request.state, "user_id", None)
    if not user_id:
        # If somehow no user_id is set, raise 401
        raise HTTPException(status_code=401, detail=f"no user_id in token") 
    user = None
    try:
        user = await check_cache(user_id=user_id)
    except Exception as e:
        pass
    if not user:
        result = await db.execute(select(User).filter_by(id=user_id))
        user = result.scalars().first()   
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

    # fastapi automatically gets from user just the relevant fields for UserProfile pydantic schema
    return user

def start():
    config = uvicorn.Config("main:app", host="127.0.0.1", port=8080, reload=True)
    server = uvicorn.Server(config)
    server.run()

if __name__ == "__main__":
    start()


# if __name__ == "__main__":
#     uvicorn.run("main:app", host="127.0.0.1", port=8080, reload=True)
