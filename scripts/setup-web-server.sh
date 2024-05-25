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
aws s3 cp s3://your-s3-bucket-name/eat-restaurant-bootstrap.zip /var/www/html/eat-restaurant-bootstrap.zip || { echo 'Failed to download S3 object'; exit 1; }
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
