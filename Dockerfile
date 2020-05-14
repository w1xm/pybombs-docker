FROM ubuntu:20.04 AS minimal
MAINTAINER w1xm-officers@mit.edu
LABEL maintainer=w1xm-officers@mit.edu

RUN DEBIAN_FRONTEND=noninteractive apt-get update -q
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip python3-apt apt-utils
RUN pip3 install --upgrade pip
RUN pip3 install pybombs
RUN pybombs auto-config
RUN pybombs config makewidth 2


FROM minimal AS prefix
# Create a prefix in /pybombs
RUN pybombs prefix init /pybombs -a default
# Add all the default recipe locations
RUN pybombs recipes add-defaults


FROM prefix AS commondeps

# This allows setting the makewidth temporarily to a higher value
ARG makewidth=2

# tzdata requires configuration
#RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# Install dependencies of gnuradio
# libcodec2-dev enables gr-vocoder
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3-requests \
    python3-setuptools \
    libqt5svg5-dev \
    qt5-default \
    pyqt5-dev \
    pyqt5-dev-tools \
    liborc-0.4-dev \
    libgmp3-dev \
    libcodec2-dev \
    git cmake g++ libboost-all-dev libgmp-dev swig python3-numpy \
    python3-mako python3-sphinx python3-lxml doxygen libfftw3-dev \
    libsdl1.2-dev libgsl-dev libqwt-qt5-dev libqt5opengl5-dev python3-pyqt5 \
    liblog4cpp5-dev libzmq3-dev python3-yaml python3-click python3-click-plugins \
    python3-zmq python3-scipy python3-gi python3-gi-cairo gobject-introspection gir1.2-gtk-3.0

# python-pyqt5 python-click-plugins python-pyqtgraph python-yaml python-gi-dev python-gi-cairo python-gobject-2-dev

RUN pybombs config makewidth $makewidth
# Now list all the dependencies that we want to ship in this container:
# (I use separate RUN commands so I can maybe have an easier time building)
RUN DEBIAN_FRONTEND=noninteractive pybombs install boost doxygen
RUN DEBIAN_FRONTEND=noninteractive pybombs install libtool autoconf automake
RUN DEBIAN_FRONTEND=noninteractive pybombs install sip lxml
RUN DEBIAN_FRONTEND=noninteractive pybombs install pycairo python-requests six mako numpy
RUN DEBIAN_FRONTEND=noninteractive pybombs install gsl fftw
RUN DEBIAN_FRONTEND=noninteractive pybombs install zeromq python-zmq
RUN DEBIAN_FRONTEND=noninteractive pybombs install libusb alsa
RUN DEBIAN_FRONTEND=noninteractive pybombs install cppunit liblog4cpp

# Removed for 20.04: qwt5 pyqwt5 pygtk

# We set it back to safe value before we finish
RUN pybombs config makewidth 2
