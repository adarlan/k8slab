FROM python:3.9-slim

WORKDIR /app

EXPOSE 80
EXPOSE 8000

COPY requirements.txt /app
RUN pip install -r requirements.txt

COPY app.py /app
CMD [ "python", "app.py" ]
