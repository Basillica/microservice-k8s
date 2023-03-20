#!/bin/bash

for i in $(seq 1 100) # making a hundred requests to the server
    do
    curl "http://localhost:80/rates?date_from=2021-01-01&date_to=2021-01-31&orig_code=CNGGZ&dest_code=EETLL"
done