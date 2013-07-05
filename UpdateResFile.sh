#!/bin/bash

if [ $# != "1" ]; then
	echo "请输入要检验的文件或目录!"
	exit 2;
fi

function check()
{
	for m_file in $*; do
		if [ -d $m_file ]; then
			check ${m_file%/}/*
		else
			echo $m_file 
			md5 -r $m_file | cut -d' ' -f1 
			wc -c $m_file | awk '{print int($1)}' 

		fi
	done
}

check $1
exit $?
