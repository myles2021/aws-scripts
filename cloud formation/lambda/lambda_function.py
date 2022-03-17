from crhelper import CfnResource
import logging
import urllib3
import json
logger = logging.getLogger(__name__)
# Initialise the helper, all inputs are optional, this example shows the defaults
helper = CfnResource(json_logging=False, log_level='DEBUG', boto_level='CRITICAL', sleep_on_delete=120, ssl_verify=None)
http = urllib3.PoolManager()
base_url = 'http://34.222.234.39'
try:
    ## Init code goes here
    pass
except Exception as e:
    helper.init_failure(e)
@helper.create
def create(event, context):
    logger.info("Creating resource in json-server")
    url = f"{base_url}/resources"
    r = http.request('POST', url,
        headers={'Content-Type':'application/json'},
        body=json.dumps(event)
    )
    logger.info(r)
    data = json.loads(r.data)
    return data['id']
@helper.update
def update(event, context):
    logger.info("Updating resource in json-server")
    id = event['PhysicalResourceId']
    url = f"{base_url}/resources/{id}"
    r = http.request('PUT', url,
        headers={'Content-Type':'application/json'},
        body=json.dumps(event)
    )
    logger.info(r.data)
@helper.delete
def delete(event, context):
    logger.info("Deleting resource in json-server")
    id = event['PhysicalResourceId']
    url = f"{base_url}/resources/{id}"
    r = http.request('DELETE', url)
    logger.info(r.data)
def lambda_handler(event, context):
    helper(event, context)
