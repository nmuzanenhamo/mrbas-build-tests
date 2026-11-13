FROM busybox:1.36
RUN dd if=/dev/urandom of=/big1.bin bs=1M count=150
RUN dd if=/dev/urandom of=/big2.bin bs=1M count=150
RUN mkdir -p /www && echo ok > /www/index.html
CMD ["httpd", "-f", "-p", "80", "-h", "/www"]
