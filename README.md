# AWS EC2 Website Hosting with Terraform

This repository provides a Terraform configuration to set up an AWS EC2 instance for hosting a static website. It includes configuring a security group, key pair, IAM role, S3 bucket for website files, and setting up the necessary services on the EC2 instance.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine
- AWS CLI configured with appropriate credentials
- An existing SSH key pair (`~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub`)

## Setup Guide

### 1. Clone the Repository

```sh
git clone https://github.com/your-username/your-repo.git
cd your-repo
