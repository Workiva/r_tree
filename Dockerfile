FROM google/dart:2.13 as dart2

WORKDIR /build/
ADD pubspec.yaml /build/
COPY --from=dart2 /usr/lib/dart /usr/lib/dart2
RUN _PUB_TEST_SDK_VERSION=2.13.4 /usr/lib/dart2/bin/pub get --no-precompile
ARG BUILD_ARTIFACTS_BUILD=/build/pubspec.lock
FROM scratch
