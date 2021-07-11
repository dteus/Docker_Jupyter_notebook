# syntax=docker/dockerfile:1

FROM ubuntu:20.04
ENV TZ=America
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get -y update

RUN apt-get install -y python3.8 python3-pip nodejs npm
RUN npm update -g
RUN pip3 -q install pip --upgrade
RUN mkdir src

WORKDIR root/

COPY . .

RUN pip3 install jupyter
RUN npm install -g node-gyp
RUN npm --unsafe-perm install -g ijavascript && ijsinstall
WORKDIR /root/notebooks
# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]


CMD ["ijsnotebook", "notebook", "--port=10000:8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]