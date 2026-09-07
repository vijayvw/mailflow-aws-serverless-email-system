# 📧 MailFlow — AWS Serverless Email Campaign System

<p align="center">
  <strong>A fully serverless email campaign platform built with AWS and Terraform</strong>
</p>

<p align="center">
  Upload a CSV → Generate Secure Upload URL → Store in S3 → Trigger Lambda → Send Emails with SES → Receive SNS Report
</p>

---

## 🛠️ Tech Stack

<p align="center">
<img src="https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white" />
<img src="https://img.shields.io/badge/Amazon%20S3-569A31?style=for-the-badge&logo=amazons3&logoColor=white" />
<img src="https://img.shields.io/badge/AWS%20Lambda-FF9900?style=for-the-badge&logo=awslambda&logoColor=white" />
<img src="https://img.shields.io/badge/API%20Gateway-FF4F8B?style=for-the-badge&logo=amazonapigateway&logoColor=white" />
<img src="https://img.shields.io/badge/Amazon%20SES-DD344C?style=for-the-badge&logo=amazonses&logoColor=white" />
<img src="https://img.shields.io/badge/Amazon%20SNS-DD344C?style=for-the-badge&logo=amazonsns&logoColor=white" />
<br>
<img src="https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white" />
<img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" />
<img src="https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white" />
<img src="https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white" />
<img src="https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black" />
<img src="https://img.shields.io/badge/IAM-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white" />
<img src="https://img.shields.io/badge/CloudWatch-FF4F8B?style=for-the-badge&logo=amazonaws&logoColor=white" />
</p>

---

# 🚀 Project Overview

**MailFlow** is a serverless email campaign system built on Amazon Web Services.

Users upload a CSV containing recipient information through a web interface. The CSV is securely uploaded to Amazon S3 using a temporary presigned URL. An S3 `ObjectCreated` event automatically triggers an AWS Lambda function that reads the recipient list, loads a customizable HTML email template, personalizes the message, and sends emails through Amazon SES.

After processing the campaign, Amazon SNS sends a summary containing the total recipients, successful sends, and failures.

The complete AWS infrastructure is provisioned and managed using **Terraform Infrastructure as Code (IaC)**.

---

# 🏗️ Architecture

```text
                         ┌──────────────────────────┐
                         │       MailFlow Web       │
                         │     S3 Static Website    │
                         └────────────┬─────────────┘
                                      │
                                      │ GET /upload-url
                                      ▼
                         ┌──────────────────────────┐
                         │      Amazon API Gateway  │
                         │        HTTP API          │
                         └────────────┬─────────────┘
                                      │
                                      ▼
                         ┌──────────────────────────┐
                         │    Upload URL Lambda     │
                         │                          │
                         │ Generates Presigned URL │
                         └────────────┬─────────────┘
                                      │
                                      │ Secure PUT
                                      ▼
                         ┌──────────────────────────┐
                         │       Amazon S3           │
                         │     Private Upload        │
                         │         Bucket            │
                         └────────────┬─────────────┘
                                      │
                                      │ ObjectCreated
                                      ▼
                         ┌──────────────────────────┐
                         │   Email Processor Lambda  │
                         │                          │
                         │  • Read CSV              │
                         │  • Load HTML Template    │
                         │  • Personalize Email     │
                         │  • Send Through SES      │
                         └────────────┬─────────────┘
                                      │
                           ┌──────────┴──────────┐
                           │                     │
                           ▼                     ▼
                  ┌─────────────────┐   ┌─────────────────┐
                  │  Amazon SES     │   │   Amazon SNS    │
                  │  Email Delivery │   │  Job Summary    │
                  └────────┬────────┘   └────────┬────────┘
                           │                     │
                           ▼                     ▼
                      Recipients             Notification
```

---

# ✨ Features

- 📤 CSV-based recipient upload
- 🖱️ Drag-and-drop file upload
- 🔐 Secure S3 uploads using presigned URLs
- 🌐 Static frontend hosted on Amazon S3
- ⚡ Serverless API using Amazon API Gateway
- 🧩 AWS Lambda-based processing
- 📧 Amazon SES email delivery
- 🎨 Custom HTML email templates
- 👤 Personalized emails using `{{name}}`
- 📢 Amazon SNS campaign notifications
- 📊 Automatic success/failure statistics
- 🔒 Private S3 bucket for uploaded CSV files
- 🔄 Event-driven S3 → Lambda processing
- 🏗️ Infrastructure fully managed using Terraform
- 📝 Email content separated from application logic
- ☁️ No EC2 servers required

---

# 🔄 How MailFlow Works

## 1️⃣ User Uploads CSV

Example:

```csv
name,email
Vijay,vijay@example.com
Rahul,rahul@example.com
```

The frontend validates the selected CSV file.

## 2️⃣ Request Presigned URL

The frontend calls:

```text
GET /upload-url
```

API Gateway invokes the Upload URL Lambda.

## 3️⃣ Generate Secure S3 URL

The Lambda generates a temporary presigned URL. The browser uses it to upload the CSV directly to S3 without exposing AWS credentials.

## 4️⃣ S3 Event Triggers Lambda

After the upload, S3 generates an `ObjectCreated` event and invokes the Email Processor Lambda.

## 5️⃣ Process CSV

The processor extracts:

```text
name
email
```

for each recipient.

## 6️⃣ Load HTML Template

Email content is maintained separately in:

```text
lambda/email_template.html
```

Example:

```html
<h1>Welcome to MailFlow!</h1>
<p>Hello {{name}},</p>
<p>Thank you for joining us.</p>
```

MailFlow replaces `{{name}}` with the recipient's actual name.

## 7️⃣ Send Email

The personalized HTML email, with a plain-text fallback, is sent through Amazon SES.

## 8️⃣ Send Campaign Summary

After processing, Lambda publishes a summary to Amazon SNS:

```text
MailFlow Email Job Completed

Total recipients: 10
Successfully sent: 9
Failed: 1
```

---

# 📁 Project Structure

```text
mass-email-system/
│
├── frontend/
│   ├── index.html
│   └── config.js
│
├── lambda/
│   ├── email_processor.py
│   ├── email_template.html
│   └── upload_url.py
│
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── iam.tf
│   ├── s3.tf
│   ├── frontend_s3.tf
│   ├── frontend_policy.tf
│   ├── frontend_files.tf
│   ├── lambda.tf
│   ├── api_gateway.tf
│   ├── ses.tf
│   ├── sns.tf
│   └── ...
│
└── README.md
```

> `config.js` is generated automatically by Terraform and should not be committed to Git.

---

# ☁️ AWS Services

| AWS Service | Purpose |
|---|---|
| Amazon S3 | Frontend hosting and CSV storage |
| AWS Lambda | Presigned URL generation and email processing |
| Amazon API Gateway | HTTP API endpoint |
| Amazon SES | Email delivery |
| Amazon SNS | Campaign completion notifications |
| AWS IAM | Access control |
| Amazon CloudWatch | Lambda logging and monitoring |
| Terraform | Infrastructure as Code |

---

# 🔐 Security

### Presigned URLs

The frontend never receives AWS access keys.

```text
Frontend
   ↓
API Gateway
   ↓
Upload URL Lambda
   ↓
Temporary Presigned URL
   ↓
S3
```

### Private Upload Bucket

The CSV upload bucket is kept private and is not publicly accessible.

### IAM

Lambda functions use IAM execution roles to access the AWS services required by the application.

### S3 Encryption

S3 server-side encryption is enabled using AES256.

### S3 Versioning

S3 versioning is enabled to provide protection against accidental object deletion or overwriting.

---

# 🖥️ Frontend

The MailFlow frontend is a static web application hosted directly on Amazon S3.

It provides:

- CSV file selection
- Drag-and-drop upload
- Upload status
- Error handling
- Success confirmation

Terraform automatically generates:

```text
frontend/config.js
```

containing the API Gateway endpoint. This prevents manually editing the API URL after deployment.

---

# ⚙️ Infrastructure as Code

All AWS infrastructure is managed using Terraform.

```text
Terraform
    │
    ├── S3
    ├── Lambda
    ├── API Gateway
    ├── SES
    ├── SNS
    ├── IAM
    └── CloudWatch
```

Benefits:

- Reproducible infrastructure
- Version-controlled configuration
- Automated deployment
- Easier maintenance
- Easier environment recreation

---

# 🚀 Deployment

## Prerequisites

Install:

- AWS CLI
- Terraform
- Python 3
- Git

Verify:

```bash
aws --version
terraform --version
aws sts get-caller-identity
```

## 1️⃣ Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/mass-email-system.git
cd mass-email-system
```

## 2️⃣ Configure Terraform Variables

```bash
cd terraform
```

Create `terraform.tfvars`:

```hcl
aws_region         = "ap-south-1"
project_name       = "mailflow-email-system"
sender_email       = "your-verified-email@example.com"
notification_email = "your-email@example.com"
```

## 3️⃣ Initialize Terraform

```bash
terraform init
```

## 4️⃣ Format and Validate

```bash
terraform fmt
terraform validate
```

## 5️⃣ Review Infrastructure

```bash
terraform plan
```

## 6️⃣ Deploy

```bash
terraform apply
```

Confirm with:

```text
yes
```

---

# 📤 Deployment Outputs

After deployment:

```bash
terraform output
```

Example outputs include:

```text
api_gateway_url
aws_region
frontend_url
lambda_function_name
s3_bucket_name
ses_sender_email
sns_topic_arn
```

---

# 🧪 Testing

Create a test CSV:

```csv
name,email
Test User,your-verified-email@example.com
```

Upload the CSV through the MailFlow frontend.

Expected workflow:

```text
CSV Selected
     ↓
GET /upload-url
     ↓
Presigned URL Generated
     ↓
CSV Uploaded to S3
     ↓
S3 ObjectCreated Event
     ↓
Lambda Triggered
     ↓
CSV Processed
     ↓
HTML Template Loaded
     ↓
{{name}} Personalized
     ↓
SES Sends Email
     ↓
SNS Sends Job Summary
```

---

# 📊 Monitoring

View Lambda logs:

```bash
aws logs tail   /aws/lambda/mailflow-email-system-processor   --since 10m   --region ap-south-1
```

CloudWatch can be used to investigate:

- Lambda execution errors
- CSV processing errors
- Failed email sends
- S3 trigger problems
- SES errors

---

# 📧 Amazon SES Sandbox

During development, Amazon SES may operate in Sandbox mode.

In Sandbox mode, recipients generally need to be verified before receiving emails.

For production use, request SES production access for the selected AWS region.

Production campaigns should only be sent to legitimate, appropriately opted-in recipients and should follow AWS SES policies and applicable regulations.

---

# 🔔 SNS Notifications

After a campaign finishes, SNS sends a summary similar to:

```text
MailFlow Email Job Completed

Total recipients: 100
Successfully sent: 98
Failed: 2
```

---

# 🧹 Destroy Infrastructure

To remove the infrastructure:

```bash
terraform destroy
```

Because S3 versioning is enabled, buckets containing object versions may need to be emptied before Terraform can delete them.

---

# 💰 Cost Considerations

MailFlow uses AWS serverless services and does not require continuously running EC2 instances.

Potential charges include:

- S3 storage and requests
- Lambda invocations
- API Gateway requests
- SES email delivery
- SNS notifications
- CloudWatch Logs

Monitor AWS usage and service quotas before production deployment.

---

# 🔮 Future Improvements

- [ ] Campaign management dashboard
- [ ] User authentication
- [ ] Multiple email templates
- [ ] Rich email template editor
- [ ] Subject customization
- [ ] Campaign scheduling
- [ ] Campaign history
- [ ] Delivery tracking
- [ ] Bounce handling
- [ ] Complaint handling
- [ ] SES Configuration Sets
- [ ] DynamoDB campaign database
- [ ] Custom domain
- [ ] HTTPS frontend using CloudFront
- [ ] GitHub Actions CI/CD
- [ ] Automated Terraform deployment
- [ ] CloudWatch alarms
- [ ] Custom CloudWatch metrics
- [ ] Advanced monitoring and alerting
- [ ] Role-based access control

---

# 🎯 DevOps & Cloud Concepts Demonstrated

- Infrastructure as Code
- Terraform
- AWS serverless architecture
- Event-driven architecture
- AWS Lambda
- Amazon S3
- Amazon API Gateway
- Amazon SES
- Amazon SNS
- AWS IAM
- Amazon CloudWatch
- Presigned URLs
- S3 event notifications
- Secure cloud storage
- Serverless application deployment
- Configuration management
- Cloud resource automation
- HTML email templating
- AWS service integration

---

# 🧠 Key Learning

MailFlow demonstrates how multiple AWS managed services can be combined to build a complete serverless application without managing traditional servers.

The project follows an event-driven architecture:

```text
User
 ↓
S3 Frontend
 ↓
API Gateway
 ↓
Upload URL Lambda
 ↓
Presigned S3 Upload
 ↓
S3 ObjectCreated Event
 ↓
Email Processor Lambda
 ↓
SES
 ↓
Recipient
```

SNS provides asynchronous campaign reporting, while Terraform provides reproducible infrastructure.

The architecture demonstrates:

```text
Serverless
Event-Driven
Infrastructure as Code
Least-Privilege Access
Managed Services
Automation
Scalability
```

---

# 📌 Project Highlights

```text
┌─────────────────────────────────────────────┐
│                  MAILFLOW                   │
├─────────────────────────────────────────────┤
│                                             │
│  ✔ Serverless AWS Architecture              │
│  ✔ Terraform Infrastructure as Code         │
│  ✔ S3 Static Website                        │
│  ✔ Secure Presigned Uploads                 │
│  ✔ API Gateway                              │
│  ✔ AWS Lambda                               │
│  ✔ S3 Event-Driven Processing               │
│  ✔ Amazon SES Email Delivery                │
│  ✔ Custom HTML Email Templates              │
│  ✔ Personalized Emails                      │
│  ✔ Amazon SNS Notifications                 │
│  ✔ IAM Security                             │
│  ✔ CloudWatch Monitoring                    │
│  ✔ No EC2 Servers                           │
│                                             │
└─────────────────────────────────────────────┘
```

---

# 👨‍💻 Author

## Vijay Waghmare

**Cloud & DevOps Enthusiast**

### Areas of Interest

```text
AWS
DevOps
Cloud Infrastructure
Terraform
Linux
CI/CD
Cloud Security
Serverless Architecture
```

---

# ⭐ Support

If you found this project useful, consider giving the repository a ⭐ on GitHub.

---

## ⚠️ Disclaimer

MailFlow is intended for legitimate email campaigns, development, and testing.

Production email campaigns should comply with:

- AWS SES policies
- Applicable privacy and anti-spam regulations
- Recipient consent requirements
- Email opt-in/opt-out requirements

Do not use the system to send unsolicited or abusive email.
