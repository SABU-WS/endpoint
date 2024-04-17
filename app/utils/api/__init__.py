from flask import jsonify
import requests
import socketio
from socketio.exceptions import TimeoutError
import logging

import urllib3

urllib3.disable_warnings()

log_format = "%(levelname)s [%(asctime)s] %(name)s  %(message)s"
logging.basicConfig(format=log_format,level=logging.INFO,filename="/sabu/logs/endpoint/sabu.log",filemode="a")
log = logging.getLogger("sabu.endpoint.apî")

class Api:
    def __init__(self,app,server_url,token,hostname):
        self.app = app
        self.server_url = server_url
        self.token = token
        self.hostname = hostname
        self.namespace = "/api/v2"
        
        http_session = requests.Session()
        http_session.verify = False
        self.sio = socketio.SimpleClient(http_session=http_session)
        self.headers = {"X-SABUAPITOKEN":self.token,
                "X-SABUHOSTNAME":self.hostname}
        self.cookies = {}
    
    def connect(self):
        self.sio.connect(self.server_url,namespace=self.namespace,headers=self.headers,transports="websocket")
        self.sio.emit("join")
    
    def receive(self):
        try:
            event = self.sio.receive(timeout=3)
            callback_event = event[1]
        except TimeoutError:
            return None
        # except Error:
            # return None
        else:
            return callback_event
    
    def login(self,username,code):
        data = {"username":username,"code":code} 
        req = requests.post("https://172.16.24.69/api/v2/set_connection", verify=False,data=data,headers=self.headers)
        if req.cookies:
            self.cookies = req.cookies
        return req.json()
    
    def logout(self):
        req = requests.post("https://172.16.24.69/api/v2/set_deconnection", verify=False,headers=self.headers,cookies=self.cookies)
        if req.cookies:
            self.cookies = req.cookies
        return req.json()

    
    def status_user(self):
        req = requests.get("https://172.16.24.69/api/v2/status_user", verify=False,headers=self.headers,cookies=self.cookies)
        return req.json()