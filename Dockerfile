FROM ubuntu:18.04 AS minimal
LABEL maintainer=martin@gnuradio.org

RUN DEBIAN_FRONTEND=noninteractive apt-get update -q
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python-pip python-apt apt-utils
RUN pip install --upgrade pip
RUN pip install pybombs
RUN pybombs auto-config
RUN pybombs config makewidth 2

FROM minimal AS prefix
LABEL maintainer=martin@gnuradio.org
# Create a prefix in /pybombs
RUN pybombs prefix init /pybombs -a default
# Add all the default recipe locations
RUN pybombs recipes add-defaults

FROM prefix AS commondeps
LABEL maintainer=martin@gnuradio.org

# This allows setting the makewidth temporarily to a higher value
ARG makewidth=2

RUN pybombs config makewidth $makewidth
# Now list all the dependencies that we want to ship in this container:
# (I use separate RUN commands so I can maybe have an easier time building)
RUN pybombs install boost doxygen
RUN pybombs install libtool autoconf automake
RUN pybombs install qwt5 sip lxml
RUN pybombs install pygtk pycairo pyqwt5 python-requests six mako numpy
RUN pybombs install gsl fftw
RUN pybombs install zeromq python-zmq
RUN pybombs install libusb alsa
RUN pybombs install cppunit liblog4cpp

# We set it back to safe value before we finish
RUN pybombs config makewidth 2
