#!/usr/bin/env python3

import os
import sys
import socket
import time
import signal
import random

import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS

url = "http://192.168.0.112:8086"
token = "GhGLo9mRgy6E9p2WLu87nxp3m8Drx67BZSYPtr3l"
org = "main"
bucket = "eztunnel-benchmark"

influx = influxdb_client.InfluxDBClient(
  url=url,
  token=token,
  org=org,
)

influx_write_api = influx.write_api(write_options=SYNCHRONOUS)

run_id = random.randbytes(5).hex()

node_pairs = [
  [0, 1],
  [0, 2],
  [0, 3],
  [1, 4],
  [2, 4],
  [3, 4],
  [4, 5],
  [5, 6],
  [5, 7],
  [6, 8],
  [7, 8],
]

nodes = {
  0: { 'fixedx': 0., 'fixedy': 1.  },

  1: { 'fixedx': 1., 'fixedy': 0.  },
  2: { 'fixedx': 1., 'fixedy': 1.  },
  3: { 'fixedx': 1., 'fixedy': 2.  },

  4: { 'fixedx': 2., 'fixedy': 1.  },

  5: { 'fixedx': 3., 'fixedy': 1.  },

  6: { 'fixedx': 4., 'fixedy': 0.5 },
  7: { 'fixedx': 4., 'fixedy': 1.5 },

  8: { 'fixedx': 5., 'fixedy': 1.  },
}

influx_write_api.write(
  org=org,
  bucket=bucket,
  record=[
    influxdb_client.Point.from_dict({
      'measurement': 'network-topology',
      'fields': {
        'id': str(id),
        'title': f'node-{id}',
        'fixedx': fields['fixedx'] * 150,
        'fixedy': fields['fixedy'] * 150,
      },
      'time': time.time_ns() + id
    }) for (id, fields) in nodes.items()
  ],
)

while True: 
  end = time.time_ns()

  random_value = random.randint(1, 123456)
  random.shuffle(node_pairs)
  pair = node_pairs[0]
  #random.shuffle(pair)

  datapoint = influxdb_client \
    .Point('network') \
    .field('source', str(pair[0])) \
    .field('target', str(pair[1])) \
    .field('run-id', run_id) \
    .field('end', end) \
    .field('random_value', random_value) \
    .time(end, write_precision='ns')

  influx_write_api.write(org=org, bucket=bucket, record=[datapoint])
  time.sleep(.5)
  print('.', end='')
  sys.stdout.flush()
