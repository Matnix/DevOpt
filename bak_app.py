#!/usr/bin/python

import sys
import os
import os.path
import time
import datetime

source_dir=str(sys.argv[1])
target_dir=str(sys.argv[2])
bak_dir = os.path.join(target_dir,time.strftime('%Y%m%d'))
tar_file = os.path.basename(source_dir)+time.strftime('%Y%m%d%H%M%S')+'.tar.gz'
source = os.path.join(os.path.dirname(source_dir),tar_file)

def remove_bak(days_ago):
    t = datetime.datetime.now() - datetime.timedelta(days_ago)
    t_stamp = time.mktime(t.timetuple())
    for fd in os.listdir(target_dir):
        rm_cmd = 'rm -rf %s' % (os.path.join(target_dir, fd))
        fd_timestamp = os.path.getmtime(os.path.join(target_dir, fd))        
        if not os.path.isdir(os.path.join(target_dir,fd)):
            continue
        if float(fd_timestamp) <= float(t_stamp):
            if os.system(rm_cmd) == 0:
                print 'rm success!'

def bak():
    if not os.path.exists(bak_dir):
        os.mkdir(bak_dir)
    log_file = os.path.join(bak_dir,time.strftime('%Y%m%d')+'.log')
    tar_cmd = 'tar zcvf %s %s >>  %s 2>&1' % (tar_file,os.path.basename(source_dir),log_file)
    mv_cmd = 'mv %s %s >> %s 2>&1' % (source,bak_dir,log_file)
    if source_dir:
        os.chdir(os.path.dirname(source_dir))
        if os.system(tar_cmd) == 0:
            print 'successful tar!' 
        else:
            print 'failed tar!'
            sys.exit()
        if os.system(mv_cmd) == 0:
            print 'mv success!'
        else:
            print 'mv failed!' 
            sys.exit()
    return 0
if __name__ == '__main__':
    if bak() == 0:
        remove_bak(7)

