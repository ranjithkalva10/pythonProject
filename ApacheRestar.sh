apache restart
vi restart.sh


#!/usr/bin/ksh

/etc/httpd/test.com/bin/control stop

sleep 20

/etc/httpd/test.com/bin/control start
~

==========

[n146244@xacldaemweb1q ~]$ vi /etc/httpd/qaaemdisp.aetna.com/bin/control stop
2 files to edit
#!/usr/bin/ksh

INSTANCE=qaaemdisp.aetna.com
INSTANCE_IP=10.208.214.134
export INSTANCE_IP
APACHE_ROOT=/etc/httpd
HTTPD_CONF=$APACHE_ROOT/$INSTANCE/conf/httpd.conf
LOGDIR=$APACHE_ROOT/$INSTANCE/logs
HTTPD=/usr/sbin/httpd

. /npopt/netegrity12/webagent64/ca_wa_env.sh

ARG="$@"
ULIMIT_MAX_FILES="ulimit -S -n `ulimit -H -n`"
export PWD=$APACHE_ROOT/$INSTANCE/logs

if [ "x$ULIMIT_MAX_FILES" != "x" ] ; then
    $ULIMIT_MAX_FILES
fi
print
#if [[ -f $ENV_VARS ]]
#  then
#   #print "INFO:\tFound envvars file.  Setting additional environment variables."
#    . $ENV_VARS
#  else
#    print "WARNING: Couldn't find envvars file - using current environment vars\n"
#fi

if [[ $# -ne 1 ]];
  then
    usemsg="\nError: no args.\n\nUsage: $0 status\n$0 stop\nstart\n\n"
    print $usemsg
    return 1
fi

case $ARG in
  status)
        if [[ -f $LOGDIR/httpd.pid ]]
         then
           print "APACHE started on pid: `cat $LOGDIR/httpd.pid`"
         else
           print "APACHE not started"
        fi
    ;;

  stop)
        HTTPDPID=`ps "guaxww" | grep "$APACHE_ROOT/$INSTANCE/conf" | grep -v nobody | grep -v grep | awk  '{ print $2 }'`
        if [[ $HTTPDPID -eq "" ]]
        then
          print "**********************"
          print "Server is stopped"
          print "**********************"
          break
        else
          HTTPDPIDFILE=`cat $LOGDIR/httpd.pid`
          if [[ $HTTPDPID -ne $HTTPDPIDFILE ]]
          then
                print "***************************************************************"
                print "Stopping APACHE $APACHE_ROOT/$INSTANCE on pid: $HTTPDPIDFILE"
                print "HTTPD PID is really: $HTTPDPID"
                print "Please Investigate why PID changed"
                print "***************************************************************"
          else
                $HTTPD -k stop -d $APACHE_ROOT/$INSTANCE -f $HTTPD_CONF
                while true
                  do
                    if [[ -e $LOGDIR/httpd.pid ]]
                    then
                        print "************************************************************************"
                        print "Stopping APACHE $APACHE_ROOT/$INSTANCE on pid: `cat $LOGDIR/httpd.pid`"
                        print "************************************************************************"
                        sleep 10
                    else
                        break
                    fi
                 done
          fi
        fi
    ;;
  start)

        if [[ -e $LOGDIR/httpd.pid ]]
           then
                HTTPDPID=`ps "guaxww" | grep "$APAHCE_ROOT/$INSTANCE/conf" | grep -v nobody | grep -v grep | awk  '{ print $2 }'`
                HTTPDPIDFILE=`cat $LOGDIR/httpd.pid`
                if [[ $HTTPDPID -eq "" ]]
                   then
                    rm $LOGDIR/httpd.pid
                fi
                if [[ $HTTPDPID -eq $HTTPDPIDFILE ]]
                   then
                        print "*********************************"
                        print "This instance is already started"
                        print "*********************************"
                        return 1
                fi
        fi


ulimit -n 2048
$HTTPD -f $APACHE_ROOT/$INSTANCE/conf/httpd.conf -k start
print "********************************************************"
$HTTPD -v
sleep 2
HTTPDPID=`ps "guaxww" | grep "$APACHE_ROOT/$INSTANCE/conf" | grep -v nobody | grep -v grep | awk  '{ print $2 }'`
print "`grep Listen $HTTPD_CONF | awk '{print $2}'`"
print "APACHE started on pid: `cat $LOGDIR/httpd.pid`"
print "********************************************************"
    ;;

esac