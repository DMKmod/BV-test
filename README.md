# bv-test
Repo with .tf files required to complete the task and its description. 

The goal of this task is to build an environment with a cluster of web servers to run basic web application. We will use   "Hello world!" index.html served by nginx web server as a base. To host our infrastructure we will use AWS cloud services, for creating and building our environment we will use Terraform "infrastructure as a code" software and for version control and as a source for the web application we will use github platform.
Our infrastructure will consist of autoscaling cluster of Nginx web servers behind ELB load balancer. Following AWS services will be used to set it up: 

AWS IAM to provide access for Terraform to our AWS account.

AWS EC2 instances for hosting Nginx web server with our "Hello world!" web app.

AWS Security Groups to manage incoming and outgoing traffic from/to an EC2 instance.

AWS Launch Configurations and its "User Data" function to template EC2 instances that will be used by our AWS Auto Scaling Group and run a script (to install nginx, place web app(index.html) into WEB root folder and set up ufw firewall) when an instance will be booting. 
AWS Auto Scaling Groups(ASG) to automatically launch a cluster of templated EC2 Instances, monitor their health, automatically restart failed nodes and adjust the size of the cluster in response to demand.

AWS Elastic Load Balancer(ELB) to distributed traffic across EC2 instances in our AWS ASG and perform health checks of our instances.

Following is a guide on how to run this code for environment replication:

1. Create AWS account and admin IAM user for this account and save its AWS Access and Secret Access keys. 

2. Prepare Terraform master node:
  
  1. Install unzip: 
  sudo apt-get update
  sudo apt-get install unzip
  2. Install terraform and add it to the OS(Linux Ubuntu have been used for this 	tutorial) PATH and test installation:
  wget https ://releases.hashicorp.com/terraform/0.11.3/terraform_0.11.3_linux_amd64.zip
  unzip  terraform_0.11.3_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  terraform --version
  
3. Export previously saved AWS Access and Secret Access keys as an env variables:
    
    export AWS_ACCESS_KEY_ID=YOUR AWS ACCESS KEY HERE
    export AWS_SECRET_ACCESS_KEY_ID=YOUR AWS SECRET ACCESS KEY HERE

4. Clone repository with  terraform files to create AWS environment, install nginx web servers and deploy our Hello World web app (index.html) from github:

    git clone https://github.com/DMKmod/bv-test.git

5. Create AWS environment, install nginx web servers and deploy our Hello World web app:

    cd bv-test
    terraform plan
    verify plan output 
    terraform apply

5. After terraform executes apply there will be an output with address of the AWS ELB load balancer, please use it to test availability of the web application(please note, it might take several minutes before it becomes available).  
