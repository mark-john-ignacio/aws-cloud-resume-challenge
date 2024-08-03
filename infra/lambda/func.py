import json
import boto3

def lambda_handler(event, context):
    # Initialize DynamoDB resource
    dynamodb = boto3.resource('dynamodb')
    
    # Select the table
    table = dynamodb.Table('cloud-resume-terraform')
    
    # Define the ID for which we want to increment views
    item_id = event['id']
    
    # Update the item, incrementing the 'views' attribute
    response = table.update_item(
        Key={
            'id': item_id
        },
        UpdateExpression="SET views = if_not_exists(views, :start) + :inc",
        ExpressionAttributeValues={
            ':start': 0,
            ':inc': 1
        },
        ReturnValues="UPDATED_NEW"
    )
    
    # Return the updated item
    return {
        'statusCode': 200,
        'body': json.dumps(response['Attributes'])
    }
