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
COPY sources/userland /usr/local/src/userland
WORKDIR /usr/local/src/userland
RUN ./buildme --aarch64

FROM balenalib/raspberrypi4-64-ubuntu-python:${BUILD_TAG} as donkeycar-build

WORKDIR /app
# Sets utf-8 encoding for Python et al
ENV LANG=C.UTF-8
# Turns off writing .pyc files; superfluous on an ephemeral container.
ENV PYTHONDONTWRITEBYTECODE=1
# Seems to speed things up
ENV PYTHONUNBUFFERED=1
# to make picamera build in docker
ENV READTHEDOCS=True

# Ensures that the python and pip executables used
# in the image will be those from our virtualenv.
ENV PATH="/venv/bin:$PATH"
# Setup the virtualenv
RUN python -m venv /venv \
    && /venv/bin/pip install wheel
COPY sources/donkeycar /donkeycar
WORKDIR /donkeycar

RUN /venv/bin/pip install --no-cache-dir \
    tensorflow==2.12 \
    -e .[pi]

# ensure we have userland
COPY --from=userland /opt/vc/ /usr/

RUN donkey createcar --path /root/mycar
COPY cars/chiaracer /root/chiaracer
WORKDIR /root/chiaracer
CMD python manage.py drive

