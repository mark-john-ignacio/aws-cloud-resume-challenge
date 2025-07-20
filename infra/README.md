# Cloud Resume Challenge - Terraform Module

A reusable Terraform module that creates a complete serverless resume website with visitor counter on AWS.

## Architecture

- **S3**: Static website hosting
- **CloudFront**: CDN for global distribution  
- **API Gateway**: REST API for visitor counter
- **Lambda**: Serverless function to handle requests
- **DynamoDB**: Visitor count storage

## Quick Start

### 1. Basic Usage
```bash
# Clone and customize
git clone <your-repo>
cd infra

# Deploy with default settings
terraform init
terraform plan -var="project_name=my-resume"
terraform apply
```

### 2. Environment-Specific Deployment
```bash
# Development environment
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"

# Production environment  
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

### 3. Custom Configuration
```bash
terraform apply \
  -var="project_name=jane-doe-resume" \
  -var="environment=prod" \
  -var="aws_region=us-west-2" \
  -var="domain_name=janedoe.com"
```

## Required Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Name of your project | `"cloud-resume"` |
| `aws_region` | AWS region | `"us-east-1"` |
| `build_directory_path` | Path to website files | `"../build"` |

## Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `environment` | Environment name | `"prod"` |
| `domain_name` | Custom domain | `null` |
| `acm_certificate_arn` | SSL certificate ARN | `null` |
| `github_actions_user_arn` | GitHub Actions IAM user | `null` |

## Outputs

- `website_url`: CloudFront URL for your website
- `api_endpoint`: API Gateway endpoint  
- `s3_bucket_name`: S3 bucket name
- `cloudfront_distribution_id`: CloudFront distribution ID

## Customization Examples

### Different Person's Resume
```hcl
project_name = "sarah-smith-resume"
environment = "prod"
domain_name = "sarahsmith.dev"
```

### Different Company Portfolio  
```hcl
project_name = "acme-corp-portfolio"
environment = "staging"
aws_region = "eu-west-1"
```

### Personal Blog
```hcl
project_name = "my-tech-blog"
environment = "prod"
domain_name = "blog.example.com"
```

## File Structure
```
infra/
├── main.tf                 # Main configuration
├── variables.tf            # Variable definitions
├── outputs.tf             # Output values
├── environments/          # Environment-specific configs
│   ├── dev.tfvars
│   └── prod.tfvars
└── modules/               # Reusable modules
    ├── s3/
    ├── cloudfront/
    ├── dynamodb/
    ├── lambda/
    └── api_gateway/
```

## Deployment Steps

1. **Prepare your website files** in the `build/` directory
2. **Configure variables** in `environments/` or pass via CLI
3. **Initialize Terraform**: `terraform init`
4. **Plan deployment**: `terraform plan -var-file="environments/prod.tfvars"`
5. **Apply changes**: `terraform apply -var-file="environments/prod.tfvars"`
6. **Get outputs**: Your website URL and API endpoint

## Clean Up
```bash
terraform destroy -var-file="environments/prod.tfvars"
```

## Use Cases

- ✅ Personal resume websites
- ✅ Portfolio sites  
- ✅ Landing pages
- ✅ Static blogs
- ✅ Company portfolios
- ✅ Event websites
