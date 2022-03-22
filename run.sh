#!/bin/bash

set -eou pipefail

docker build -t gallium .
docker run --rm -it gallium 
