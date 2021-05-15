from pymongo import MongoClient
from flask import Flask
import os

app = Flask(__name__)

password = os.environ['MONGODB_ROOT_PASSWORD']

client = MongoClient('mongodb.default.svc.cluster.local:27017',username='root',password=password)
collection = client.numtest.numtest

@app.route('/buyList')
def produce_buy_request():
    return 'placeholder'
