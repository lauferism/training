from pymongo import MongoClient
from flask import Flask

app = Flask(__name__)

client = MongoClient('mongodb.default.svc.cluster.local:27017',username='root',password='DHTo6Szt67')
collection = client.numtest.numtest

@app.route('/buyList')
def produce_buy_request():
    return 'placeholder'