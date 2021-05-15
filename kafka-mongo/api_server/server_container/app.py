from pymongo import MongoClient
from flask import Flask
import os

app = Flask(__name__)

# getting mongodb root password from environment variables
password = os.environ['MONGODB_ROOT_PASSWORD']

# connecting to mongodb server
client = MongoClient('mongodb.default.svc.cluster.local:27017',username='root',password=password)
# setting the db and collection and write to test
collection = client.test.test

@app.route('/buyList')
def produce_buy_request():
    for x in collection.find():
        # wasn't able to return the result of collection.find so i left it here.
        # i would have query to find by userid that was sent by the web-server and return the records.
        pass

    return 'placeholder'
