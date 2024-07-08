FROM bitnami/python:3.11
ARG TARGET

COPY ${TARGET} /app
COPY common/libs/poc /app/poc
RUN pip install -r requirements.txt

ENV PYTHONPATH=/app
ENTRYPOINT ["uvicorn", "--host", "0.0.0.0", "app.main:app"]
