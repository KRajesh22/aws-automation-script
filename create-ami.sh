
#!/bin/bash

# This script will build a Custom Amazon EC2 Machine Image 

export EC2_HOME=/opt/ec2/tools                           # Your EC2 tools folder
export EC2_URL=https://ec2.amazonaws.com
export AWS_ACCOUNT_NUMBER='aws-account-number'           # Your Amazon S3 User Id
export AWS_ACCESS_KEY_ID='your_access_key_id'            # Your Amazon S3 Access Key
export AWS_SECRET_ACCESS_KEY='your_secret_access_key'    # Your Amazon S3 Secret Key
export EC2_PRIVATE_KEY='path-to-amazon pem-file'
# If you have not already created an X.509 Certificate, you need to create or upload one from the AWS Management Console. Navigate to Security Credentials,
# click on the X.509 Certificates tab under Access Credentials, and click "Create a new Certificate".
export EC2_CERT='path-to-X.509-Certificate'
export AWS_AMI_BUCKET='s3-bucket-name'                    #Your Amazon S3 bucket name
export PATH=$PATH:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:$EC2_HOME/bin
export JAVA_HOME=/usr/local/java/jre1.7.0_75              # have to edit ec2-cmd file to disable java environment check




#Create the server image filename and manifest filename with todays date filename.21.02.2015 and filename.21.02.2015.manifest.xml
filename=ami-image		#change filename to your necessity



excludes=/proc

#bundle the server, upload it, export necessary variables and register it,
ec2-bundle-vol -d /mnt -k $EC2_PRIVATE_KEY -c $EC2_CERT -u $AWS_ACCOUNT_NUMBER -r x86_64 -p $filename.$(date +%d.%m.%Y) 
ec2-upload-bundle -b $AWS_AMI_BUCKET -m /mnt/ami-$filename.$(date +%d.%m.%Y).manifest.xml -a $AWS_ACCESS_KEY_ID -s $AWS_SECRET_ACCESS_KEY 
ec2-register -n $AWS_AMI_BUCKET -prd -K $EC2_PRIVATE_KEY -C $EC2_CERT $AWS_AMI_BUCKET/$filename.$(date +%d.%m.%Y).manifest.xml
# You can now launch an instance of the new AMI using ec2-run-instances and specifying the image identifier (AMI ID) you received when you registered the image in the previous step.



# This variable is for deleting the files from the /mnt/ directory after bundling make sure you set the below var with intial image name which is common through all the files 
commonName=name
#Deleting the bundle files from the /mnt directory
rm -Rf /mnt/$commonName*