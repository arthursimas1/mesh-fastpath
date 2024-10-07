#!/usr/bin/env python3

import os
import sys
import socket
import time
import signal

import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS

assert len(sys.argv) == 2, 'wrong argument count. expected `python3 sock_client.py 127.0.0.1:8080`'

url = os.environ['INFLUX_URL']
token = os.environ['INFLUX_TOKEN']
org = os.environ['INFLUX_ORG']
bucket = os.environ['INFLUX_BUCKET']

influx = influxdb_client.InfluxDBClient(
  url=url,
  token=token,
  org=org,
)

influx_write_api = influx.write_api(write_options=SYNCHRONOUS)

#[HOST, PORT] = '192.168.0.112:6300'.split(':')
[HOST, PORT] = sys.argv[1].split(':')
PORT = int(PORT)

times = []

should_exit = 0
def signal_handler(signum, frame):
  global should_exit
  global sock
  should_exit += 1
  signame = signal.Signals(signum).name
  print(f'got signal: {signame} ({signum})')
  if should_exit >= 2:
    sock.close()
    sys.exit()

signal.signal(signal.SIGINT, signal_handler)

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((HOST, PORT))

while should_exit == 0:
  start = time.time_ns()
  try:
    data = f'ping-{start}'.encode()
    sock.sendall(data)
    data_recv = sock.recv(1024)
    if not data_recv: break
  except Exception as e:
    print(e)
    break

  end = time.time_ns()
  diff = end - start

  print(f'{len(times)},{diff}')

  datapoint = influxdb_client
    .Point('latency')
    .tag('workload', 'ping-echo')
    .field('start', start)
    .field('end', end)
    .field('diff', diff)
    .time(end, write_precision='ns')
  write_api.write(org=org, bucket=bucket, record=[datapoint])

  times.append(diff)
  time.sleep(.1 - diff * 1e+9)

print('\nclosing socket')
sock.close()
if len(times) > 0:
  metrics = {}
  metrics['sum'] = sum(times)
  metrics['count'] = len(times)
  metrics['min'] = min(times)
  metrics['max'] = max(times)
  metrics['avg'] = metrics['sum'] / metrics['count']
  print(metrics)
