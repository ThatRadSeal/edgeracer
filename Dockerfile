ARG BUILD_TAG=3.10-jammy-build-20230328
ARG RUN_TAG=3.10-jammy-run-20230328

FROM balenalib/raspberrypi4-64-ubuntu-python:${BUILD_TAG} as userland
# install deps to build userland
RUN install_packages \
    cmake

# copy userland git and build
RUN mkdir -p /usr/local/src/userland
COPY userland /usr/local/src/userland
WORKDIR /usr/local/src/userland
RUN ./buildme --aarch64

FROM balenalib/raspberrypi4-64-ubuntu-python:${RUN_TAG} as run
COPY --from=userland /opt/vc/ /opt/vc/

ENV LD_LIBRARY_PATH=/opt/vc/lib
CMD "/opt/vc/bin/raspistill"
