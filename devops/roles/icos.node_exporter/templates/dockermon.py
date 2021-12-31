#!/usr/bin/python3
import time
import docker

repo = 'alpine:latest'
dock = docker.from_env()

try:
    img = dock.images.get(repo)
except docker.errors.ImageNotFound:
    img = dock.images.pull(repo)


start = time.time()
try:
    # Using the auto_remove flag caused spurious docker.errors.
    r = dock.containers.run(repo, 'echo hello', remove=True)
    elapsed = (time.time() - start) * 1000
    assert(r == b'hello\n')
except docker.errors.DockerException:
    elapsed = None

print("""\
# HELP dockermon_up Docker could execute image
# TYPE dockermon_up gauge

# HELP dockermon_hello_ms Milliseconds to execute 'alpine echo hello'
# TYPE dockermon_hello_ms gauge""")

if elapsed is None:
    print("dockermon_up 0")
    print("dockermon_hello_ms 0")
else:
    print("dockermon_up 1")
    print("dockermon_hello_ms ", elapsed)
