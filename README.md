# AWS S3 → SQS → Lambda pipeline (with VPC/EC2) — Terraform

This project provisions an event-driven pipeline on AWS using Terraform: an object uploaded to an S3 bucket triggers an SQS message, which invokes a Lambda function that parses the event and prints the uploaded object's name to CloudWatch Logs. It also provisions a VPC with an EC2 instance, used to demonstrate updating live infrastructure (toggling the instance's public IP) with Terraform.

**Flow:**
1. An object is uploaded to the S3 bucket (`sukhmay-demo-bucket-2026-001`).
2. S3 sends an `ObjectCreated:*` event notification to the SQS queue (`demo-queue`).
3. The SQS queue triggers the Lambda function (`s3-sqs-lambda`) via an event source mapping.
4. The Lambda function parses the SQS message body, extracts the S3 object key, and prints it to CloudWatch Logs.
5. A VPC with a public subnet hosts an EC2 instance used to run Terraform itself. The instance was first provisioned with a public IP (`associate_public_ip_address = true`), then updated to `false` and re-applied — Terraform detects this forces a replacement and recreates the instance without a public IP.

## Tech stack

- **Terraform** (AWS provider ~> 6.0) — infrastructure as code
- **Amazon S3** — object storage / event source
- **Amazon SQS** — decoupled message queue between S3 and Lambda
- **AWS Lambda** (Python 3.9) — event processing
- **Amazon CloudWatch Logs** — log output / verification
- **Amazon VPC + EC2** — network and compute, used to run Terraform from inside AWS

## Repository structure

```
.
├── README.md
├── .gitignore
├── docs/
│   └── architecture-diagram.svg
├── terraform/
│   ├── provider.tf      # AWS provider (ap-south-2)
│   ├── vpc.tf            # VPC, public subnet, IGW, route table
│   ├── security.tf       # security group (SSH ingress)
│   ├── ec2.tf              # EC2 instance + public-IP toggle
│   ├── s3_bucket.tf        # S3 bucket
│   ├── s3.tf                # S3 -> SQS event notification
│   ├── s3_sqs.tf             # SQS queue policy (allows S3 to send messages)
│   ├── sqs.tf                 # SQS queue
│   ├── iam.tf                  # Lambda execution role + policy attachments
│   ├── lambda.tf                 # Lambda function + event source mapping
│   └── outputs.tf
├── lambda/
│   └── function.py                # Lambda source code (final working version)
└── logs/
    ├── initial-lambda-code.txt       # First version - printed raw event, not object name
    └── fixed-lambda-run.txt            # Verified run after the fix, with CloudWatch output
```


## Prerequisites

- An AWS account with programmatic access configured (`aws configure`)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- An existing EC2 key pair if you intend to SSH into the instance

## Deployment

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Confirm with `yes` when prompted. Terraform provisions the VPC, EC2 instance, S3 bucket, SQS queue, IAM role, and Lambda function, and wires the S3 event notification and Lambda trigger between them.

## Testing the pipeline

Upload a file to the bucket:

```bash
echo "hello world" > test.txt
aws s3 cp test.txt s3://sukhmay-demo-bucket-2026-001
```

Tail the Lambda's logs:

```bash
aws logs tail /aws/lambda/s3-sqs-lambda --follow
```

Expected output:

```
Object uploaded: test.txt (bucket: sukhmay-demo-bucket-2026-001)
```

A full verified run is saved in [`logs/fixed-lambda-run.txt`](logs/fixed-lambda-run.txt). The earlier, less specific version of the Lambda code (which only dumped the raw event) is kept in [`logs/initial-lambda-code.txt`](logs/initial-lambda-code.txt) for reference — it shows the iteration from "the trigger works" to "the trigger works *and* prints exactly what was asked for."

## EC2 public IP toggle

To demonstrate updating live infrastructure with Terraform:

1. `ec2.tf` initially set `associate_public_ip_address = true` — the instance got a public IP and was reachable directly.
2. The value was then changed to `false` and `terraform apply` was re-run.
3. Terraform detected this change forces resource replacement, destroyed the old instance, and recreated it — now without a public IP — confirming the network configuration is fully managed through code, not the console.

## Cleanup

```bash
cd terraform
terraform destroy
```

## Author

Sukhmay — built as a hands-on Terraform/AWS project covering VPC networking, IAM, and an event-driven S3 → SQS → Lambda pipeline.
