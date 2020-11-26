### Serveless S3 CDN 
The stack secures the serveless s3 application by enabling ssl, cdn, and restrict origin access.

![stack-topology](https://github.com/comp9447-team4/soar/blob/master/services/route-53/images/topology.png)

**Note:** For WAF configuration in the topology above, please refer to the WAF configuration folder found here: https://github.com/comp9447-team4/soar/tree/master/services/WAF

For adding the services to WAF (optional) after deployment, go to the management console and add the service under the asssosciation table. Refer to the screenshots below:
![Add-WAF-to_API-GW](https://github.com/comp9447-team4/soar/blob/master/services/route-53/images/waf-cloudfront.png)
![Add-WAF-to_CDN](https://github.com/comp9447-team4/soar/blob/master/services/route-53/images/waf-api-gw.png)

### Prequisites:
- Owns and have administrative access to a domain name
- Basic knowledge of DNS
 
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
5. Add the cloudfront distribution to route 53.

### Required Parameters for the cloudformation table.
- DomainName: Domain name used in the route 53 hosted zone (Recommend pointing your domain dns server to AWS).
- CertificateArn: the newly generated ACM certificate ARN (aws resource idenfitier).
- BucketName: The name of the bucket that is hosting the website.
- S3Region: The region where the S3 bucket is located.

### To Run:

1. Deploy the certificate.
```bash
#Replace export variable values found in DomainSSL.sh
#Then execute:
./DomainSSL.sh

```

2. Get the certificate ARN from the management console. Deploy the stack, and hook it up to WAF.

Refer to the screenshot below:
![get-certificate-arn](https://github.com/comp9447-team4/soar/blob/master/services/route-53/images/certificate-arn.png)


```bash
#Replace export variable values found in CDN.sh
#Then execute:
./cdn.sh
```
