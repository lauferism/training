from flask import Flask, render_template, request
from json import dumps
from kafka import KafkaProducer
from datetime import datetime
import logging
import sys
import requests


# setting up flask. Used flask for the api endpoints
app = Flask(__name__)

print("setting up producer",file=sys.stderr)
# setting kafka producer
producer = KafkaProducer(bootstrap_servers=['kafka-0.kafka-headless.default.svc.cluster.local:9092'],
                         value_serializer=lambda x: 
                         dumps(x).encode('utf-8'))

# setting up flask default route to template home.html file
@app.route("/")
def index():
    return render_template("home.html", message="Welcome");

# setting up flask /buy endpoint. It gets argument from the request and write data to kafka, to test topic
@app.route('/buy')
def produce_buy_request():
    username=request.args['username']
    userid=request.args['userid']
    price=request.args['price']
    data = {'username':username,'userid':userid,'price':price,'timestamp': datetime.now().strftime("%d-%m-%Y (%H:%M:%S.%f)")}
    print("sending message to kafka",file=sys.stderr)
    producer.send('test', value=data)
    print("message sent",file=sys.stderr)
    return 'message sent'


@app.route('/getAllUserBuys')
def getAllUserBuys():
    # getting userid from the form
    userid=request.args['userid']
    # sending a get request to api-server with userid as parameter
    x = requests.get('http://api-server.default.svc.cluster.local/buyList',params={'userid':userid})
    return x

