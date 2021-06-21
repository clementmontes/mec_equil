FROM ubuntu:latest

# (c) Alfred Galichon (math+econ+code) with contributions from Keith O'Hara and Jules Baudet


RUN apt-get update && apt-get -y update
RUN apt-get install -y build-essential python3.7 python3-pip python3-dev wget
RUN pip3 -q install pip --upgrade
RUN apt-get -y install git

RUN mkdir src
WORKDIR src/
COPY ./content .

RUN pip3 install -r requirements.txt
RUN rm requirements.txt

RUN apt-get install -y --fix-missing curl autoconf libtool
# RUN curl -L https://github.com/libspatialindex/libspatialindex/archive/1.8.5.tar.gz | tar -xz
# RUN cd libspatialindex-1.8.5 && ./autogen.sh && ./configure && make && make install && ldconfig
# RUN pip3 install osmnx

RUN pip3 install jupyter

# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]


RUN mkdir -p /src/notebooks && \
    cd /src/notebooks && \
    git clone https://github.com/math-econ-code/mec_equil.git


CMD cd /src/notebooks/mec_equil && \
    git pull origin master && \
    cd .. && \
    jupyter notebook --port=8888 --no-browser --ip=0.0.0.0 --allow-root
	
# CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
