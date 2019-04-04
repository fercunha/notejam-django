FROM 851348844139.dkr.ecr.us-west-2.amazonaws.com/notejambase-django

COPY ./requirements.txt .

RUN pip install -r requirements.txt

COPY ./notejam /notejam

WORKDIR /notejam

EXPOSE 8000

# CMD ["python", "manage.py", "runserver"]
#CMD ["gunicorn", "-w 4", "-b :8000", "runserver:app"]
CMD exec gunicorn notejam.wsgi:application --bind 0.0.0.0:8000 --workers 3