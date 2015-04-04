#!/bin/sh

# Quick and dirty graph generator. Should be rewritten at some point.

cd /home/closure

rm -f SHARD1
rm -f SHARD1.geolist
rm -f SHARD1.clientconnsperhour

wget -q  http://iabak.archiveteam.org/stats/SHARD1
wget -q  http://iabak.archiveteam.org/stats/SHARD1.geolist
wget -q  http://iabak.archiveteam.org/stats/SHARD1.clientconnsperhour       

if [ -f SHARD1 ]
   then
   IA1=`cat SHARD1 | grep 'numcopies +0' | cut -f2 -d':'`
   IA2=`cat SHARD1 | grep 'numcopies +1' | cut -f2 -d':'`
   IA3=`cat SHARD1 | grep 'numcopies +2' | cut -f2 -d':'`
   IA4=`cat SHARD1 | grep 'numcopies +[3-6]' | cut -f2 -d':' | awk '{ sum+=$1} END {print sum}'`
   CHRONOS=`date`

   # Fix color problem for missing numbers.
   if [ -z "$IA1" ]; then IA1=0.001; fi
   if [ -z "$IA2" ]; then IA2=0.001; fi
   if [ -z "$IA3" ]; then IA3=0.001; fi
   if [ -z "$IA4" ]; then IA4=0.001; fi

# Head!

   cat html/graph.template.head | sed "s/IA1/${IA1}/g" | sed "s/IA2/${IA2}/g" | sed "s/IA3/${IA3}/g" | sed "s/IA4/${IA4}/g" | sed "s/TIME/${CHRONOS}/g" > html/graph.html

# Let's do GEO.....
    
   CLICOUNT=`cat SHARD1.geolist | wc -l`
   COUNTRYS=`cat SHARD1.geolist | sed 's/.*\"country_name\":\"//g' | sed 's/ /_/g' | cut -f1 -d'"' | sort -u | wc -l`
   
   for country in `cat SHARD1.geolist | sed 's/.*\"country_name\":\"//g' | sed 's/ /_/g' | cut -f1 -d'"' | sort -u`
       do
       PUNKY=`echo ${country} | sed 's/_/ /g'`
       COUNT=`grep "\"country_name\":\"${PUNKY}" SHARD1.geolist | wc -l `
       echo "['${PUNKY}', ${COUNT}]," >> html/graph.html
       done

       cat html/graph.template.middle >> html/graph.html

   for city in `cat SHARD1.geolist | grep "United States" | sed 's/.*\"zip_code\":\"//g' | sed 's/ /_/g' | cut -f1 -d'"' | sort -u`
       do
       PUNKY=`echo ${city} | sed 's/_/ /g'`
       COUNT=`grep "\"zip_code\":\"${PUNKY}" SHARD1.geolist | wc -l `
       echo "['${PUNKY}', ${COUNT}]," >> html/graph.html
       done

cat SHARD1.clientconnsperhour | sed -e 's/^[ \t]*//' | awk '{print $2, $3, $4, "Z", $1}'  | sed "s/^/['/g" | sed "s/ Z /', /g" | sed "s/$/],/g" | tail -24 > SHARD1.clientday

   cat html/graph.template.tail | sed "s/IA1/${IA1}/g" | sed "s/IA2/${IA2}/g" | sed "s/IA3/${IA3}/g" | sed "s/IA4/${IA4}/g" | sed "s/TIME/${CHRONOS}/g" | sed "s/CLICOUNT/${CLICOUNT}/g" | sed "s/CLAMBAKE/${COUNTRYS}/g" >> html/graph.html

fi
