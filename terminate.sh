#!/bin/bash

cd elb
sh deregister.sh

sleep 30

cd ../infra
sh terminate.sh

cd ../notify
sh notification.sh terminate