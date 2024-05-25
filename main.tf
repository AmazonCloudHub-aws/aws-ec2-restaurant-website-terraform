
# Security Group for EC2 instance
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP, HTTPS, and SSH traffic"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair for SSH access
resource "aws_key_pair" "deployer" {
  key_name   = var.deployer_key_name
  public_key = file("~/.ssh/id_rsa.pub") # Path to your public key
}

# IAM Role for EC2 instance to access S3
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# S3 bucket to store website files
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# S3 bucket object to upload website files
resource "aws_s3_bucket_object" "website_files" {
  bucket = aws_s3_bucket.website_bucket.bucket
  key    = "eat-restaurant-bootstrap.zip"
  source = "eat-restaurant-bootstrap.zip"
  etag   = filemd5("eat-restaurant-bootstrap.zip")
}

# EC2 instance to host the website
resource "aws_instance" "web" {
  ami                    = "ami-08188dffd130a1ac2" # Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              set -e
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              echo "Starting user data script"

              # Update and install necessary packages
              sudo yum update -y || { echo 'Failed to update package list'; exit 1; }
              sudo yum install -y httpd unzip aws-cli php php-mysqlnd || { echo 'Failed to install packages'; exit 1; }

              echo "Apache, PHP, and other packages installed"

              # Start and enable Apache
              sudo systemctl start httpd || { echo 'Failed to start Apache'; exit 1; }
              sudo systemctl enable httpd || { echo 'Failed to enable Apache'; exit 1; }

              echo "Apache started and enabled"

              # Ensure /var/www/html directory exists
              if [ ! -d /var/www/html ]; then
                sudo mkdir -p /var/www/html || { echo 'Failed to create /var/www/html directory'; exit 1; }
                echo "/var/www/html directory created"
              fi

              # Remove default Apache welcome page
              sudo rm -rf /var/www/html/* || { echo 'Failed to remove default Apache content'; exit 1; }

              echo "Default Apache content removed"

              # Download and unzip the website content from S3
              echo "Attempting to download from S3"
              aws s3 cp s3://${var.bucket_name}/eat-restaurant-bootstrap.zip /var/www/html/eat-restaurant-bootstrap.zip || { echo 'Failed to download S3 object'; exit 1; }
              echo "Downloaded S3 object"

              cd /var/www/html || { echo 'Failed to change directory to /var/www/html'; exit 1; }
              unzip eat-restaurant-bootstrap.zip || { echo 'Failed to unzip file'; exit 1; }
              rm -f eat-restaurant-bootstrap.zip || { echo 'Failed to remove zip file'; exit 1; }

              echo "Unzipped website content"

              # Move contents of eat-restaurant-bootstrap to /var/www/html
              mv /var/www/html/eat-restaurant-bootstrap/* /var/www/html/ || { echo 'Failed to move website content'; exit 1; }
              rm -rf /var/www/html/eat-restaurant-bootstrap || { echo 'Failed to remove temporary directory'; exit 1; }

              echo "Moved website content to /var/www/html"

              # Set proper permissions
              sudo chown -R apache:apache /var/www/html || { echo 'Failed to set ownership'; exit 1; }
              sudo chmod -R 755 /var/www/html || { echo 'Failed to set permissions'; exit 1; }

              echo "Permissions set"
              EOF

  depends_on = [aws_s3_bucket_object.website_files]

  tags = {
    Name = "web-server"
  }
}


