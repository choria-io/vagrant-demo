#!/bin/bash

uuid=`cat /proc/sys/kernel/random/uuid`
/usr/bin/curl "http://www.google-analytics.com/collect?v=1&tid=UA-10152852-12&cid=${uuid}&t=event&ec=vagrant_demo&ea=up&ni=1"
