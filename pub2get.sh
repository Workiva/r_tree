#!/bin/bash

set -e
if [ $TRAVIS_DART_VERSION = 1.24.3 ]
then
  curl -O https://storage.googleapis.com/dart-archive/channels/stable/release/2.5.0/sdk/dartsdk-linux-x64-release.zip
  unzip dartsdk-linux-x64-release.zip
  _PUB_TEST_SDK_VERSION=1.24.3 dart-sdk/bin/pub get --no-precompile
fi

