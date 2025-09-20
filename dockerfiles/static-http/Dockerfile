FROM busybox:latest

# Create user and workspace
RUN adduser -D user \
  && mkdir -p /home/user/www \
  && chown -R user:user /home/user

# Drop in a starter index.html (optional)
COPY ./dockerfiles/static-http/default.html /home/user/www/index.html

# Tiny startup script
RUN printf '#!/bin/sh\ncd /home/user/www\nexec busybox httpd -f -p 8080\n' \
  > /usr/local/bin/start-httpd \
  && chmod +x /usr/local/bin/start-httpd

USER user
WORKDIR /home/user
ENV HOME=/home/user TERM=xterm

CMD ["/usr/local/bin/start-httpd"]

