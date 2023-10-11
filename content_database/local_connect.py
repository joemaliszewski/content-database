import mysql.connector
from dotenv import load_dotenv
import os
from loguru import logger
import pandas as pd 

# Load environment variables from .env file
load_dotenv('/Users/vinegar/code/content-database/.env')

# Use local or cloud RDS credentials
use_local = True  # Set to False to use cloud credentials



if use_local:
    host = os.getenv("LOCAL_DB_HOST")
    user = os.getenv("LOCAL_DB_USER")
    password = os.getenv("LOCAL_DB_PASSWORD")
else:
    host = os.getenv("CLOUD_DB_HOST")
    user = os.getenv("CLOUD_DB_USER")
    password = os.getenv("CLOUD_DB_PASSWORD")

logger.info(f"Host: {host}, User: {user}, Password: {password}")

conn = mysql.connector.connect(host=host, user=user, password=password)
