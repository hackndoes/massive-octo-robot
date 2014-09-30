# Riak
# Version 0.1.0

# Use ubuntu base image provided by dotCloud
FROM ubuntu:latest
MAINTAINER Hector Castro hector@basho.com

# Update the APT CACHE
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

# Install and setup project dependencies
RUN apt-get install -y curl lsb-release supervisor openssh-server

RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

RUN locale-gen en_US en_US.UTF-8

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN echo 'root:basho' | chpasswd

RUN curl -s http://apt.basho.com/gpg/basho.apt.key | apt-key add --
RUN echo "deb http://apt.basho.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/basho.list
RUN apt-get udpate

# install riak and prepare it to run
RUN apt-get install -y riak
RUN sed -i.bak 's/127.0.0.1/0.0.0.0/' /etc/riak/app.config
RUN echo 'ulimit -n 4096' >> /etc/default/riak

# Hack for initctl
# see https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

# expose riak protocol buffers and HTTP interfaces, along with SSH
EXPOSE 8087 8098 22

CMD ["/usr/bin/supervisord"]
