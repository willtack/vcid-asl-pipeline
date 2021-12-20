#!/bin/bash

docker run -ti --rm -v /home/will/Gears/vcid-asl-pipeline/Nifti:/opt/base/input -v /home/will/Gears/vcid-asl-pipeline/output:/opt/base/output --entrypoint=/bin/bash willtack/vcid-asl-pipeline:0.0.2

