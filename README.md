# 🛡️ AWS S3 Public Access Auto-Remediation using Terraform (IaC)

[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)

---

## 🗺️ Project Overview

In a cloud environment, misconfigured S3 buckets are a leading cause of data breaches. To mitigate this risk, I developed an **Automated Auto-Remediation System**. This project uses Infrastructure as Code (IaC) to continuously scan an AWS account and automatically "self-heal" any S3 bucket that has public access enabled, ensuring corporate data remains private by default.

## ☁️ Technical Architecture

![Architecture](images/architecture.png)

I used **Terraform** to provision a serverless, event-driven architecture consisting of:

* **Amazon EventBridge:** Triggers the remediation logic every 5 minutes (Scheduled Rule).
* **AWS Lambda:** A Python-based function that audits bucket configurations.
* **Amazon S3:** The target service being monitored and secured.
* **CloudWatch Logs:** For real-time auditing of remediation actions.

## ⚙️ Infrastructure as Code

Instead of manual "click-ops," the entire security stack is defined in Terraform. This ensures the security policy is reproducible, version-controlled, and can be deployed across multiple regions or accounts instantly.

![Terraform Logic](images/terraform-apply.png)
*Figure 1: Terraform execution output ensuring all security resources are provisioned.*

---

## ✅ Validation & Proof of Work

To verify the system's effectiveness, I simulated a configuration drift by manually making a bucket public.

### Step 1: Baseline / Vulnerability State
Initially, a test bucket was configured with public access allowed—a critical security high-risk finding.

![Public Bucket Settings](images/bucket-before.png)

### Step 2: Automated Detection & Remediation
Within 5 minutes, EventBridge triggered the Lambda function. The function identified the insecure bucket and applied the **Public Access Block** settings immediately.

![Lambda Logs](images/lambda-logs.png)
*Figure 2: CloudWatch logs showing the identification and fixing of the insecure bucket.*

### Step 3: Verified Secure State
The bucket settings were automatically updated to "Block all public access." Any attempt to revert these settings will be corrected in the next 5-minute cycle.

![Public Block Enabled](images/bucket-after.png)

---

## 🔐 Security & Permissions

This project adheres to the **Principle of Least Privilege (PoLP)**. The IAM role assigned to the Lambda function is strictly limited to:
* `s3:ListAllMyBuckets`
* `s3:GetBucketPublicAccessBlock`
* `s3:PutBucketPublicAccessBlock`

---

## 📈 Key Skills Demonstrated

* **Cloud Security:** Implementing automated remediation for S3 security best practices.
* **Automation (IaC):** Using Terraform to manage serverless security workflows.
* **Serverless Computing:** Developing Python/Boto3 logic for AWS Lambda.
* **Observability:** Utilizing CloudWatch for auditing and tracking security changes.

---
