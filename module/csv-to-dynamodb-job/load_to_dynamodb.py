import boto3
import csv

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

TABLE_NAME = "csv-data-dev"  # dynamic later
CSV_FILE = "data.csv"

table = dynamodb.Table(TABLE_NAME)

with open(CSV_FILE, mode='r') as file:
    reader = csv.DictReader(file)

    for row in reader:
        table.put_item(Item=row)

print("Data loaded successfully")