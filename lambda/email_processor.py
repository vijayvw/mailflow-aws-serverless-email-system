import csv
import io
import json
import logging
import os
import urllib.parse

import boto3


logger = logging.getLogger()
logger.setLevel(logging.INFO)


s3 = boto3.client("s3")
ses = boto3.client("ses")
sns = boto3.client("sns")


SENDER_EMAIL = os.environ["SENDER_EMAIL"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]


# Load the email template bundled with the Lambda function
TEMPLATE_PATH = os.path.join(
    os.path.dirname(__file__),
    "email_template.html"
)

with open(TEMPLATE_PATH, "r", encoding="utf-8") as file:
    EMAIL_TEMPLATE = file.read()


def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))

    total = 0
    sent = 0
    failed = 0

    try:
        for record in event.get("Records", []):
            bucket = record["s3"]["bucket"]["name"]

            key = urllib.parse.unquote_plus(
                record["s3"]["object"]["key"]
            )

            logger.info(
                "Processing file: s3://%s/%s",
                bucket,
                key
            )

            response = s3.get_object(
                Bucket=bucket,
                Key=key
            )

            content = response["Body"].read().decode("utf-8")

            csv_reader = csv.DictReader(
                io.StringIO(content)
            )

            for row in csv_reader:
                total += 1

                email = row.get("email", "").strip()
                name = row.get("name", "Customer").strip()

                if not email:
                    failed += 1

                    logger.warning(
                        "Skipping row without email address"
                    )

                    continue

                try:
                    # Personalize the HTML template
                    personalized_email = EMAIL_TEMPLATE.replace(
                        "{{name}}",
                        name
                    )

                    ses.send_email(
                        Source=SENDER_EMAIL,

                        Destination={
                            "ToAddresses": [email]
                        },

                        Message={
                            "Subject": {
                                "Data": "Welcome to MailFlow!",
                                "Charset": "UTF-8"
                            },

                            "Body": {
                                "Html": {
                                    "Data": personalized_email,
                                    "Charset": "UTF-8"
                                },

                                "Text": {
                                    "Data": (
                                        f"Hello {name},\n\n"
                                        "Thank you for joining us.\n"
                                        "We are excited to have you with us.\n\n"
                                        "Best regards,\n"
                                        "MailFlow Team"
                                    ),
                                    "Charset": "UTF-8"
                                }
                            }
                        }
                    )

                    sent += 1

                    logger.info(
                        "Email sent successfully to %s",
                        email
                    )

                except Exception:
                    failed += 1

                    logger.exception(
                        "Failed to send email to %s",
                        email
                    )

        summary = (
            "MailFlow Email Job Completed\n\n"
            f"Total recipients: {total}\n"
            f"Successfully sent: {sent}\n"
            f"Failed: {failed}"
        )

        logger.info(summary)

        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="MailFlow Email Job Completed",
            Message=summary
        )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "total": total,
                "sent": sent,
                "failed": failed
            })
        }

    except Exception as error:
        logger.exception(
            "MailFlow email job failed"
        )

        try:
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject="MailFlow Email Job Failed",
                Message=str(error)
            )
        except Exception:
            logger.exception(
                "Failed to publish failure notification"
            )

        raise
