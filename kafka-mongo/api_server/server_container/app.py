from pymongo import MongoClient
from flask import Flask, render_template, request
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
    userid=request.args['userid']
    cur=collection.find({'userid':userid})
    return render_template('collections.html', cur=list(cur))
