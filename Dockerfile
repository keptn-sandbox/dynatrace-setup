FROM curlimages/curl:7.75.0

COPY create_project.sh /

ENTRYPOINT ["/bin/sh", "/create_project.sh"]