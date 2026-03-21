import boto3
import csv
import os
from datetime import datetime

# ✅ Dynamic config
REGION = os.getenv("AWS_REGION", "ap-south-2")
ENV = os.getenv("TF_VAR_env", "dev")
ACCOUNT_ID = boto3.client("sts").get_caller_identity()["Account"]

TABLE_NAME = f"csvtodynamo-{ENV}-{ACCOUNT_ID}-dynamodb"
CSV_FILE = "unemployment_rate_by_age_groups.csv"

dynamodb = boto3.resource('dynamodb', region_name=REGION)
table = dynamodb.Table(TABLE_NAME)

def clean_row(row):
    return {
        "id": str(row["id"]),  # ✅ must be string

        "AreaType": row["Area Type"],
        "AreaName": row["Area Name"],

        # ✅ Normalize date
        "Date": datetime.strptime(row["Date"], "%m/%d/%Y").strftime("%Y-%m-%d"),

        "Year": int(row["Year"]),
        "Month": row["Month"],

        # ✅ Clean column names
        "Age16_19": float(row["Age 16-19"]),
        "Age20_24": float(row["Age 20-24"]),
        "Age25_34": float(row["Age 25-34"]),
        "Age35_44": float(row["Age 35-44"]),
        "Age45_54": float(row["Age 45-54"]),
        "Age55_64": float(row["Age 55-64"]),
        "Age65Plus": float(row["Age 65+"]),
    }

with open(CSV_FILE, mode='r') as file:
    reader = csv.DictReader(file)

    for row in reader:
        cleaned_item = clean_row(row)
        table.put_item(Item=cleaned_item)

print("Data loaded successfully")