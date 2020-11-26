### Serveless S3 CDN 
The stack secures the serveless s3 application by enabling ssl, cdn, and restrict origin access.

### AWS Technologies
- S3 origins
- ACM
- Cloudfront distribution
- Route 53

### Workflow of the script
1. Creates a new ssl certificate for *.domain.com.
2. Enters the cname entry and value to route 53 to validate the ssl certificate request.
3. Creates a cloudfront distribution for S3 serveless site.
4. Deploys origin policy on the s3 bucket, allowing traffic to only originate from the cloud distribute domain.
5. Add the cloudfront distribution to route 53

### Required Parameters
- DomainName: domain name used in the route 53 hosted zone (Recommend pointing your domain dns server to AWS).
- CertificateArn: the newly generated ACM certificate ARN (aws resource idenfitier).
- BucketName: The name of the bucket that is hosting the website.
- S3Region: The region where the S3 bucket is located.


### CLI-Tool options
TBA