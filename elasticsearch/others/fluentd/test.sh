#!/bin/bash
echo "Start : `date +"%Y年%m月%d日 %H:%M:%S"`" >> my.log
for i in `seq 1 20000`
do
   cat 1 >> ./log/1.log
done
echo "End : `date +"%Y年%m月%d日 %H:%M:%S"`" >> my.log
