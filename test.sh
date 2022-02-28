#!/bin/bash

docker run -ti --rm -v /home/will/Gears/vcid-asl-pipeline/test/local:/opt/base/input -v /home/will/Gears/vcid-asl-pipeline/test/output:/opt/base/output --entrypoint=/bin/bash willtack/vcid-asl-pipeline:0.3.0

