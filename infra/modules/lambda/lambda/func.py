import boto3
import logging
import json
from decimal import Decimal

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f"Received event: {event}")
    
    try:
        # Check if the event is from API Gateway
        if 'body' in event:
            body = json.loads(event['body'])
            item_id = str(body['id'])
        else:
            item_id = str(event['id'])
        
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table('cloud-resume-terraform')

        response = table.update_item(
            Key={
                'id': item_id
            },
            UpdateExpression='ADD #v :inc',
            ExpressionAttributeNames={
                '#v': 'views'
            },
            ExpressionAttributeValues={
                ':inc': 1
            },
            ReturnValues="UPDATED_NEW"
        )

        views = int(response['Attributes']['views'])
        logger.info(f"Views updated successfully: {views}")
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps({'views': views})
        }

    except Exception as e:
        logger.error(f"Error updating views: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Internal server error'})
        }