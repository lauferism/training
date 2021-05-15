from kafka import KafkaConsumer
from pymongo import MongoClient
from json import loads
import sys
import os
password = os.environ['MONGODB_ROOT_PASSWORD']

consumer = KafkaConsumer(
    'test',
     bootstrap_servers=['kafka-0.kafka-headless.default.svc.cluster.local:9092'],
     auto_offset_reset='earliest',
     enable_auto_commit=True,
     group_id='my-group',
     value_deserializer=lambda x: loads(x.decode('utf-8')))

client = MongoClient('mongodb.default.svc.cluster.local:27017',username='root',password=password)
collection = client.numtest.numtest

for message in consumer:
    message = message.value
    print(message,file=sys.stderr)
    collection.insert_one(message)
    print('{} added to {}'.format(message, collection),file=sys.stderr)