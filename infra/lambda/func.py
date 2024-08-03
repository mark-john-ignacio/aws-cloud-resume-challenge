import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('cloud-resume-terraform')

def decimal_default(obj):
    """Convert Decimal to float"""
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError

def lambda_handler(event, context):
    try:
        # Fetch the item from the DynamoDB table
        response = table.get_item(Key={'id': '1'})
        item = response.get('Item')
        
        if not item:
            return {
                'statusCode': 404,
                'body': json.dumps('Item not found')
            }
        
        # Increment the views count
        views = item['views'] + 1
        
        # Update the item in the DynamoDB table
        table.put_item(Item={'id': '1', 'views': views})
        
        # Return the updated view count
        return {
            'statusCode': 200,
            'body': json.dumps(views, default=decimal_default)
        }
        
    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)}, default=decimal_default)
        }