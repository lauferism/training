from flask import Flask, render_template, request
from json import dumps
from kafka import KafkaProducer
from datetime import datetime
import logging
import sys
import requests



app = Flask(__name__)
print("setting up producer",file=sys.stderr)
producer = KafkaProducer(bootstrap_servers=['kafka-0.kafka-headless.default.svc.cluster.local:9092'],
                         value_serializer=lambda x: 
                         dumps(x).encode('utf-8'))

@app.route("/")
def index():
    return render_template("home.html", message="Welcome");

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
    username=request.args['username']
    x = requests.get('http://api-server.default.svc.cluster.local/buyList',params={'username':username})
    return x

