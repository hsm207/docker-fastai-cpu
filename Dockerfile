# from https://docs.docker.com/engine/examples/running_ssh_service/
FROM ubuntu:16.04

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
# note the root password you set!
RUN echo 'root:abc123' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# install miniconda
RUN apt install bzip2
# from https://github.com/ContinuumIO/docker-images/blob/master/miniconda/debian/Dockerfile
ENV PATH /opt/conda/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# install fastai
RUN conda install -y -c pytorch pytorch-cpu torchvision-cpu  && \
    conda install -y -c fastai fastai && \
    conda install -y jupyter notebook && \
    conda install -y -c conda-forge jupyter_contrib_nbextensions

# also from  https://docs.docker.com/engine/examples/running_ssh_service/
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]