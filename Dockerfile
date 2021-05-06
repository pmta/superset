FROM apache/superset

ENV https_proxy=http://10.158.100.1:8080

# Switching to root to install the required packages
USER root

RUN /usr/local/bin/python -m pip install --upgrade pip
# Example: installing the MySQL driver to connect to the metadata database
# if you prefer Postgres, you may want to use `psycopg2-binary` instead
#RUN pip install mysqlclient
COPY ./database-dependencies.txt .
RUN mkdir -p /app/docker/
COPY ./docker/* /app/docker/
COPY ./docker/docker-entrypoint.sh /usr/bin/

RUN chmod +x /app/docker-bootstrap.sh && chown -R superset:superset /app/docker-bootstrap.sh

RUN pip install -r database-dependencies.txt

# Example: installing a driver to connect to Redshift
# Find which driver you need based on the analytics database
# you want to connect to here:
# https://superset.apache.org/installation.html#database-dependencies
RUN pip install sqlalchemy-redshift

# Switching back to using the `superset` user
USER superset

HEALTHCHECK CMD curl -f "http://localhost:$SUPERSET_PORT/health"

EXPOSE ${SUPERSET_PORT}

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

