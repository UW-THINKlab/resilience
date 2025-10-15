FROM python:3.12-slim

# Set the working directory inside the container
WORKDIR /app

# Below ENV values are overridden when running the via K8s Job else the above arg values are used.
ENV DB_HOST=localhost
ENV DB_PORT=5432
ENV DB_USERNAME=postgres
ENV DB_PASSWORD=example123456
ENV DB_NAME=postgres
ENV SUPABASE_KONG_HOST=supabase-supabase-kong
ENV SUPABASE_KONG_PORT=8000
ENV ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE


# Install any necessary dependencies
RUN pip3 install --no-cache-dir --extra-index-url https://test.pypi.org/simple --only-binary=:all: support_sphere_py

# Command to run the Python script
ENTRYPOINT ["sh", "-c", "support_sphere execute_sql run-all && support_sphere db_init run-all"]