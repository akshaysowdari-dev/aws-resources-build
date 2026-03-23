import boto3
import csv
import os
from datetime import datetime
from io import StringIO

import os

REGION = os.environ["REGION"]
PROJECT = os.environ["PROJECT"]
ENV = os.environ["ENV"]
ACCOUNT_ID = os.environ["ACCOUNT_ID"]

TABLE_NAME = f"{PROJECT}-{ENV}-{ACCOUNT_ID}-MCT-adjusted"

dynamodb = boto3.resource('dynamodb', region_name=REGION)
table = dynamodb.Table(TABLE_NAME)

s3 = boto3.client('s3')

def clean_row(row):
    return {
        "id": str(row["id"]),
        "AreaType": row["Area Type"],
        "AreaName": row["Area Name"],
        "Date": datetime.strptime(row["Date"], "%m/%d/%Y").strftime("%Y-%m-%d"),
        "Year": int(row["Year"]),
        "Month": row["Month"],
        "Age16_19": float(row["Age 16-19"]),
        "Age20_24": float(row["Age 20-24"]),
        "Age25_34": float(row["Age 25-34"]),
        "Age35_44": float(row["Age 35-44"]),
        "Age45_54": float(row["Age 45-54"]),
        "Age55_64": float(row["Age 55-64"]),
        "Age65Plus": float(row["Age 65+"]),
    }

def lambda_handler(event, context):
    # Get S3 details from event
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = event["Records"][0]["s3"]["object"]["key"]

    # Read file from S3
    response = s3.get_object(Bucket=bucket, Key=key)
    content = response["Body"].read().decode("utf-8")

    csv_file = StringIO(content)
    reader = csv.DictReader(csv_file)

    # Process and insert into DynamoDB
    for row in reader:
        item = clean_row(row)
        table.put_item(Item=item)

    return {
        "statusCode": 200,
        "body": f"Processed file {key}"
    }