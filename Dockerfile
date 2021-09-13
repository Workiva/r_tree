FROM google/dart:2.13
WORKDIR /build/
ADD pubspec.yaml /build/
RUN dart pub get
FROM scratch