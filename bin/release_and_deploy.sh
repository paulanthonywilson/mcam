#!/usr/bin/env sh

set -e

cd `dirname $0`
cd ..

bash ./bin/make_release.sh
bash ./bin/deploy.sh
