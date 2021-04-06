"""
Craft a web request to the AWS rest API and hit an endpoint that actually works but isn't supported in the boto3 or AWS CLI

Based on https://gist.github.com/andrewmackett/5f73bdd29aeed4728ecaace53abbe49b

Usage :- python3 rds_log_downloader.py --s3_bucket <bucket> --region <region> --db <db_name> --logfile <log_file_to_download>  --output <output_file_path>

Note:-

The above command also supports profile. You can pass profile name using --profile or -p paramater. It's an optional parameter though.
"""
import boto3
import os
import sys, os, base64, datetime, hashlib, hmac, urllib
import requests
import time
import argparse
# import tinys3


def get_credentials(profile_name=None):
    if profile_name:
        session = boto3.Session(profile_name=profile_name)
    else:
        session = boto3.Session()
    return session.get_credentials()

def get_log_file_via_rest(profile_name, region, filename, db_instance_identifier, output_file):
    def sign(key, msg):
        return hmac.new(key, msg.encode('utf-8'), hashlib.sha256).digest()

    def getSignatureKey(key, dateStamp, regionName, serviceName):
        kDate = sign(('AWS4' + key).encode('utf-8'), dateStamp)
        kRegion = sign(kDate, regionName)
        kService = sign(kRegion, serviceName)
        kSigning = sign(kService, 'aws4_request')
        return kSigning

    # ************* REQUEST VALUES *************
    method = 'GET'
    service = 'rds'
    region = region
    host = 'rds.'+ region +'.amazonaws.com'
    endpoint = 'https://' + host

    # Key derivation functions. See:
    # http://docs.aws.amazon.com/general/latest/gr/signature-v4-examples.html#signature-v4-examples-python
    credentials = get_credentials(profile_name=profile_name)
    access_key = credentials.access_key
    secret_key = credentials.secret_key
    session_token = credentials.token
    if access_key is None or secret_key is None:
        print('No access key is available in current environment. Exiting ..')
        return

    # Create a date for headers and the credential string
    t = datetime.datetime.utcnow()
    amz_date = t.strftime('%Y%m%dT%H%M%SZ') # Format date as YYYYMMDD'T'HHMMSS'Z'
    datestamp = t.strftime('%Y%m%d') # Date w/o time, used in credential scope

    # sample usage : '/v13/downloadCompleteLogFile/DBInstanceIdentifier/error/postgresql.log.2017-05-26-04'
    canonical_uri = '/v13/downloadCompleteLogFile/'+ db_instance_identifier + '/' + filename

    # Step 3: Create the canonical headers and signed headers. Header names
    # and value must be trimmed and lowercase, and sorted in ASCII order.
    # Note trailing \n in canonical_headers.
    # signed_headers is the list of headers that are being included
    # as part of the signing process. For requests that use query strings,
    # only "host" is included in the signed headers.
    canonical_headers = 'host:' + host + '\n'
    signed_headers = 'host'

    # Match the algorithm to the hashing algorithm you use, either SHA-1 or
    # SHA-256 (recommended)
    algorithm = 'AWS4-HMAC-SHA256'
    credential_scope = datestamp + '/' + region + '/' + service + '/' + 'aws4_request'

    # Step 4: Create the canonical query string. In this example, request
    # parameters are in the query string. Query string values must
    # be URL-encoded (space=%20). The parameters must be sorted by name.
    canonical_querystring = ''
    canonical_querystring += 'X-Amz-Algorithm=AWS4-HMAC-SHA256'
    canonical_querystring += '&X-Amz-Credential=' + urllib.parse.quote_plus(access_key + '/' + credential_scope)
    canonical_querystring += '&X-Amz-Date=' + amz_date
    canonical_querystring += '&X-Amz-Expires=30'
    if session_token is not None :
        canonical_querystring += '&X-Amz-Security-Token=' + urllib.parse.quote_plus(session_token)
    canonical_querystring += '&X-Amz-SignedHeaders=' + signed_headers

    # Step 5: Create payload hash. For GET requests, the payload is an
    # empty string ("").
    payload_hash = hashlib.sha256(''.encode("utf-8")).hexdigest()

    # Step 6: Combine elements to create create canonical request
    canonical_request = method + '\n' + canonical_uri + '\n' + canonical_querystring + '\n' + canonical_headers + '\n' + signed_headers + '\n' + payload_hash

    # ************* TASK 2: CREATE THE STRING TO SIGN*************
    string_to_sign = algorithm + '\n' +  amz_date + '\n' +  credential_scope + '\n' +  hashlib.sha256(canonical_request.encode("utf-8")).hexdigest()

    # ************* TASK 3: CALCULATE THE SIGNATURE *************
    # Create the signing key
    signing_key = getSignatureKey(secret_key, datestamp, region, service)

    # Sign the string_to_sign using the signing_key
    signature = hmac.new(signing_key, (string_to_sign).encode("utf-8"), hashlib.sha256).hexdigest()

    # ************* TASK 4: ADD SIGNING INFORMATION TO THE REQUEST *************
    # The auth information can be either in a query string
    # value or in a header named Authorization. This code shows how to put
    # everything into a query string.
    canonical_querystring += '&X-Amz-Signature=' + signature

    # ************* SEND THE REQUEST *************
    # The 'host' header is added automatically by the Python 'request' lib. But it
    # must exist as a header in the request.
    request_url = endpoint + canonical_uri + "?" + canonical_querystring

    r = requests.get(request_url, stream=True, allow_redirects=True)
    if r.status_code != 200:
        raise Exception("Something went wrong !! ")

    error = False
    with open(output_file, "wb") as f:
        for chunk in r.iter_content(100000):
            if r.status_code !=200:
                error = True
                break
            if chunk:
                f.write(chunk)
    if error:
        os.remove(output_file)
        raise Exception(" ")


parser = argparse.ArgumentParser(description='RDS Log Downloader')
parser.add_argument("-p", "--profile", help="name of the profile to be used")
parser.add_argument("-t", "--retries", help="number of retries in case of request failure", type=int, default=3)
parser.add_argument("-b", "--s3_bucket", required=True, help="s3 bucket target")
parser.add_argument("-r", "--region", required=True, help="region of the db instance")
parser.add_argument("-d", "--db", required=True, help="db instance")
parser.add_argument("-l", "--logfile", required=True, help="log file to download")
parser.add_argument("-o", "--output", required=True, help="local output file path to save the log")
parser.add_argument("-s", "--sleep", help="sleep / delay (in seconds) between retries", type=int, default=5)

args = parser.parse_args()

retries = args.retries
profile_name = args.profile
s3_bucket = args.s3_bucket
region = args.region
log_file = args.logfile
db_instance = args.db
output_file = args.output
sleep_time = args.sleep


while True:
    try:
        get_log_file_via_rest(profile_name, region, log_file, db_instance, output_file)
        #break
    except Exception as e:
        # The below is for handling retry for session expiry in case of usage of role based credentials. The retries basically waits and gets the next set of role credentials and retries downloading
        if retries <= 0:
            print("\nSomething went wrong !! Check if all of the below are configured correctly. \n\n1) The credentials is valid. \n2) The user / role being used has access to download the logs \n3) The target account has corresponding db instance and the logfile within the provided region")
            break
        else:
            retries -= 1
            time.sleep(sleep_time)

    # conn = tinys3.Connection('access_key','secret_key',tls=True)
    
    s3 = boto3.client('s3')
    with open(output_file, 'rb') as data:
        s3.upload_fileobj(data, s3_bucket, output_file)
    break
