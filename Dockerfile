ARG PY_VER=3.10
ARG OS_VER=jammy
ARG BASE_DATE=20230328

ARG BUILD_TAG=${PY_VER}-${OS_VER}-build-${BASE_DATE}
ARG RUN_TAG=${PY_VER}-${OS_VER}-run-${BASE_DATE}

FROM balenalib/raspberrypi4-64-ubuntu-python:${BUILD_TAG} as userland
# install deps to build userland
RUN install_packages \
    cmake

# copy userland git and build
RUN mkdir -p /usr/local/src/userland
COPY userland /usr/local/src/userland
WORKDIR /usr/local/src/userland
RUN ./buildme --aarch64

FROM balenalib/raspberrypi4-64-ubuntu-python:${RUN_TAG} as carrunner

COPY --from=userland /opt/vc/ /opt/vc/
ENV LD_LIBRARY_PATH=/opt/vc/lib


FROM carrunner as development
RUN install_packages \
    openssh-server \
    build-essential \
    git


RUN mkdir /var/run/sshd \
    && echo 'root:mypassword' | chpasswd \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && mkdir /root/.ssh/ \
    && echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnofKbghuYBeVxHxJiOfBsiSAiVMyRvlorSncmKyS8x shermanm@msh-laptop" > /root/.ssh/authorized_keys
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
