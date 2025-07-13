import boto3
from botocore.exceptions import ClientError
from datetime import datetime

TABLE_NAME = "pokemon-collection"
REGION = "us-west-2"

dynamodb = boto3.resource('dynamodb', region_name=REGION)

def create_table_if_not_exists():
    try:
        table = dynamodb.Table(TABLE_NAME)
        table.load()
        print(f"Table '{TABLE_NAME}' already exists")
        return table
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            print(f"Creating table '{TABLE_NAME}'...")
            table = dynamodb.create_table(
                TableName=TABLE_NAME,
                KeySchema=[
                    {
                        'AttributeName': 'name',
                        'KeyType': 'HASH'
                    }
                ],
                AttributeDefinitions=[
                    {
                        'AttributeName': 'name',
                        'AttributeType': 'S'
                    }
                ],
                BillingMode='PAY_PER_REQUEST'
            )
            table.wait_until_exists()
            print(f"Table '{TABLE_NAME}' created successfully!")
            return table
        else:
            raise e

def load_pokemon():
    try:
        create_table_if_not_exists()
        table = dynamodb.Table(TABLE_NAME)
        
        response = table.scan()
        pokemon_list = response.get('Items', [])
        
        return {"pokemon": pokemon_list}
        
    except ClientError as e:
        print(f"Error loading pokemon from DynamoDB: {e}")
        return {"pokemon": []}

def save_data(pokemon_details):
    try:
        table = dynamodb.Table(TABLE_NAME)
        
        pokemon_details['created_at'] = datetime.utcnow().isoformat()
        pokemon_details['name'] = pokemon_details['name'].lower()
        
        table.put_item(Item=pokemon_details)
        
        print(f"The pokemon {pokemon_details['name']} saved successfully!")
        
    except ClientError as e:
        print(f"Error saving pokemon to DynamoDB: {e}")

def get_pokemon_by_name(name):
    try:
        table = dynamodb.Table(TABLE_NAME)
        
        response = table.get_item(
            Key={'name': name.lower()}
        )
        
        return response.get('Item', None)
        
    except ClientError as e:
        print(f"Error getting pokemon {name} from DynamoDB: {e}")
        return None