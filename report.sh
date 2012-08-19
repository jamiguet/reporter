#!/bin/bash

# check for paths config if not available create config file
if [ ! -f ~/.reporter.rc ]; then
    echo "~/.reporter.rc not found configuring reporter"
    journaldir=`find ~/ -name template.org`
    set -- $journaldir
    journaldir=`dirname $1`
    echo "journaldir="$journaldir"/" > ~/.reporter.rc
    echo "# Edit the next line with the path to your org files" >> ~/.reporter.rc
    echo "# Leave as is if you do not want org mode agenda to remind you" >> ~/.reporter.rc
    echo "orgdir=NO_PATH" >> ~/.reporter.rc


    if [ ! -f ~/bin/report.sh ]; then
    #creating link to the bin dir for better access
	ln -s $journaldir/report.sh ~/bin/report.sh
    fi

   $EDITOR ~/.reporter.rc
fi

source ~/.reporter.rc

#echo $journaldir
#echo $orgdir

today=`date --iso $@`
weekday=`date +%A`
day=`date +%d`
month=`date -d yesterday +%m`
monthName=`date -d yesterday +%B-%Y`
filename=$today.org
timestamp=`date  "+%Y-%m-%d %a" $@`


# check if today has already been created
if [ ! -f $journaldir/$filename ]; then
    echo "No file for " $today " found. Creating one  "
    echo "* Day: " $timestamp  > $journaldir/$filename
    echo "DEADLINE: <" $timestamp  ">" >> $journaldir/$filename 
    cat $journaldir/template.org >> $journaldir/$filename

    if [ $day -eq 01 ]; then
	echo "New month archiving files"
	cat $journaldir/*-$month-*.org > $journaldir/$monthName.org
	rm $journaldir/*-$month-*.org
	# TODO add here creation of summary of monthly expenses file
    fi
fi

if [ $orgdir != "NO_PATH" ]; then
    rm $orgdir/today.org
    ln -s $journaldir/$filename $orgdir/today.org
fi

#if the emacs server is running call that instead of starting a new emacs

EMACS="emacs"

# After all the setup invoke emacs to edit the file
echo "Starting emacs for editing"
if [ $orgdir != "NO_PATH" ]; then
    $EMACS $orgdir/today.org &
 else
    $EMACS $journaldir/$filename &
fi
