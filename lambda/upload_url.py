import json
import os
import uuid

import boto3
from botocore.config import Config


s3 = boto3.client(
    "s3",
    region_name="ap-south-1",
    endpoint_url="https://s3.ap-south-1.amazonaws.com",
    config=Config(signature_version="s3v4")
)

BUCKET_NAME = os.environ["BUCKET_NAME"]


def lambda_handler(event, context):
    try:
        file_name = f"uploads/{uuid.uuid4()}.csv"

        upload_url = s3.generate_presigned_url(
            ClientMethod="put_object",
            Params={
                "Bucket": BUCKET_NAME,
                "Key": file_name,
                "ContentType": "text/csv",
            },
            ExpiresIn=300,
        )

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "GET,OPTIONS",
            },
            "body": json.dumps({
                "uploadUrl": upload_url,
                "fileKey": file_name,
            }),
        }

    except Exception as error:
        print(f"Error generating upload URL: {error}")

        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
            "body": json.dumps({
                "error": str(error)
            }),
        }
