#! /usr/bin/env python
# -*- coding=utf-8 -*-
import os,sys
import time,datetime

def remove_log(dir, days_ago):

    today = datetime.datetime.now()
    ndays = datetime.timedelta(days=days_ago)
    ndays_ago = today - ndays
    ndays_ago_timestamps = time.mktime(ndays_ago.timetuple())
    files = os.listdir(dir)
    for f in files:

        if f.startswith('.'):
            continue
        if os.path.isdir(os.path.join(dir,f)):
            continue
        
        file_timestamp = os.path.getmtime(os.path.join(dir, f))
        if float(file_timestamp) <= float(ndays_ago_timestamps):
                os.remove(os.path.join(dir,f))


if __name__ == '__main__':

    if os.path.exists(sys.argv[1]):
        remove_log(sys.argv[1],int(sys.argv[2]))
