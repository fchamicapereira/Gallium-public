#!/bin/bash

set -eou pipefail

docker build -t gallium .
docker run -it gallium
