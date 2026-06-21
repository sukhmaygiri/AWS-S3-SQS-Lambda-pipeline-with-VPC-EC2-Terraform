import json

def lambda_handler(event, context):
    print("Event received:", json.dumps(event))

    for record in event['Records']:
        body = json.loads(record['body'])

        for s3_record in body.get('Records', []):
            bucket_name = s3_record['s3']['bucket']['name']
            object_key = s3_record['s3']['object']['key']
            print(f"Object uploaded: {object_key} (bucket: {bucket_name})")

    return {
        'statusCode': 200
    }
