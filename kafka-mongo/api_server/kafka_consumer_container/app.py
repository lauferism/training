from kafka import KafkaConsumer
from pymongo import MongoClient
from json import loads
import sys
import os
# getting mongodb root password from environment variables
password = os.environ['MONGODB_ROOT_PASSWORD']

# setting kafka consumer, writing to test topic and my-group group
consumer = KafkaConsumer(
    'test',
     bootstrap_servers=['kafka-0.kafka-headless.default.svc.cluster.local:9092'],
     auto_offset_reset='earliest',
     enable_auto_commit=True,
     group_id='my-group',
     value_deserializer=lambda x: loads(x.decode('utf-8')))

# connecting to mongodb server
client = MongoClient('mongodb.default.svc.cluster.local:27017',username='root',password=password)

# setting the db and collection and write to test
collection = client.test.test

for message in consumer:
    message = message.value
    print(message,file=sys.stderr)
    # adding the message to mongodb collection object.
    collection.insert_one(message)
    print('{} added to {}'.format(message, collection),file=sys.stderr)
