#!/usr/bin/env python3
import json
import socket
import requests


with open("ips.json", mode="r", encoding="utf-8") as read_file:
    ips = json.load(read_file)["data"]

#IP=socket.gethostbyname(socket.gethostname())
IP="10.7.6.54"

print("La IP local es %s y pertenece a %s" % (IP,  )

for ip in ips:
    if IP == ip["ip"]:
        estado = ip["estado"]
        if estado == "RESERVADA":
            print("OK: Estado reservada")
            break
        elif estado == "ASIGNADA":
            print("OK: Estado asignada")
            break
        elif estado in ("ADVERTENCIA", "ADVERTENCIA1", "ADVERTENCIA2"):
            print("ATENCION: IP con estado de advertencia")
            break
        elif estado =="DUPLICADA":
            print("ATENCION: IP duplicada")
            break
        elif estado == "DESCUBIERTA":
            print("ATENCIÓN: IP descubierta")
            break
