# AWS EC2 Website Hosting with Terraform

This repository provides a Terraform configuration to set up an AWS EC2 instance for hosting a website. It includes configuring a security group, key pair, IAM role, and setting up the necessary services on the EC2 instance.

# Web Server Setup with Terraform

This project sets up a web server on AWS EC2 using Terraform. The web server is configured to serve a website hosted on the EC2 instance. The setup script performs the following tasks:
- Installs necessary packages including Apache, PHP, AWS CLI, and unzip.
- Starts and enables the Apache web server.
- Ensures the `/var/www/html` directory exists for the website files.
- Removes the default Apache welcome page.
- Downloads the website content from an S3 bucket and unzips it on the EC2 instance.
- Moves the website content to the appropriate directory.
- Sets the proper permissions for the Apache web server to serve the website.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- AWS CLI configured with appropriate credentials.
- SSH key pair for accessing the EC2 instance.

## Setup Guide

### 1. Clone the Repository

```sh
git clone git@github.com:dhamsey3/aws-ec2-restaurant-website-terraform.git
