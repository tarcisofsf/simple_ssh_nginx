# Use a base image
FROM ubuntu:latest

# Install OpenSSH, Nginx and supervisor
RUN apt-get update && apt-get install -y \
    openssh-server \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Setup SSH server
RUN mkdir /var/run/sshd
RUN echo 'root:P@ssW0rd##' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# to avoid issue with key exchange on macos ssh clients
RUN echo "KexAlgorithms=ecdh-sha2-nistp521" >> /etc/ssh/sshd_config

# SSH login fix. Otherwise, the user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# Copy supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose the SSH port and the HTTP port for Nginx
EXPOSE 22 80

# Start supervisord
CMD ["/usr/bin/supervisord"]
