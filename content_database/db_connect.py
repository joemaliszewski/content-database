import mysql.connector
from dotenv import load_dotenv
import os
from loguru import logger
import argparse

# Argument parser setup
parser = argparse.ArgumentParser(description="Connect to a database.")
parser.add_argument('--connect', choices=['local', 'rds'], required=True, help='Choose which database to connect to: local or rds')
args = parser.parse_args()

# Load environment variables from .env file
load_dotenv('/Users/vinegar/code/content-database/.env')

# Database configurations
db_configs = {
    "local": {
        "host": os.getenv("LOCAL_DB_HOST"),
        "user": os.getenv("LOCAL_DB_USER"),
        "password": os.getenv("LOCAL_DB_PASSWORD")
    },
    "rds": {
        "host": os.getenv("CLOUD_DB_HOST"),
        "user": os.getenv("CLOUD_DB_USER"),
        "password": os.getenv("CLOUD_DB_PASSWORD")
    }
}

# Extract selected config based on command line argument
config = db_configs[args.connect]

try:
    conn = mysql.connector.connect(host=config["host"], user=config["user"], password=config["password"])
    if conn.is_connected():
        logger.info(f"Successfully connected to {args.connect} database!")
        conn.close()
    else:
        logger.error(f"Failed to connect to {args.connect} database.")
except mysql.connector.Error as err:
    logger.error(f"Error while connecting to {args.connect} database: {err}")
