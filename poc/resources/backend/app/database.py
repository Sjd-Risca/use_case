import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

if os.environ.get('POSTGRES_PASSWORD'):
    DB_NAME = os.environ['POSTGRES_DB']
    DB_PASSWD = os.environ['POSTGRES_PASSWORD']
    USER = os.environ['POSTGRES_USER']
    SQLALCHEMY_DATABASE_URL = f"postgresql://{USER}:{DB_PASSWD}@postgresql/{DB_NAME}"
    # SQLALCHEMY_DATABASE_URL = "postgresql://user:password@postgresserver/db"
    CONN_ARGS = {}
else:
    SQLALCHEMY_DATABASE_URL = os.environ.get('DATABASE', "sqlite:///./sql_app.db")
    CONN_ARGS = {"check_same_thread": False}

engine = create_engine(SQLALCHEMY_DATABASE_URL,
                       connect_args=CONN_ARGS)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
