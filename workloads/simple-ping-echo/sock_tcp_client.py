#!/usr/bin/env python3

import sys
import socket
import time
import signal

assert len(sys.argv) == 2, 'wrong argument count. expected `python3 sock_client.py 127.0.0.1:8080`'

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
    sock.sendall(b'ping')
    data = sock.recv(1024)
    if not data: break
  except Exception as e:
    print(e)
    break
  end = time.time_ns()
  diff = end - start
  times.append(diff)
  print(data)
  print(diff, len(times))
  time.sleep(.1)

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
