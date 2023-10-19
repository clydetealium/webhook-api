#!/bin/bash
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pushd $script_dir/../lambdas
pip install -r requirements.txt -t .
find . -type f ! -name 'test_*' -exec zip -r lambda.zip {} \;
popd
