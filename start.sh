#!/bin/bash

cd infra
sh apply.sh

sleep 50

cd ../elb
sh register.sh

cd ../notify
sh notification.sh start
