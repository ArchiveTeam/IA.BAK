#!/bin/sh

# Quick and dirty graph generator. Should be rewritten at some point.

NUMSHARDS=2

cd /home/closure

CHRONOS=`date`

rm -f stats.tar.gz
wget -q  http://iabak.archiveteam.org/stats.tar.gz
tar xf stats.tar.gz

for SHARDNUM in $(seq 0 $NUMSHARDS); do

if [ "$SHARDNUM" = 0 ]; then
	SHARD=ALL
else
	SHARD="SHARD$SHARDNUM"
fi

HTMLTMP="$(tempfile)"

if [ -f $SHARD ]
   then
   IA1=`cat $SHARD | grep 'numcopies +0:' | cut -f2 -d':'`
   IA2=`cat $SHARD | grep 'numcopies +1:' | cut -f2 -d':'`
   IA3=`cat $SHARD | grep 'numcopies +2:' | cut -f2 -d':'`
   IA4=`cat $SHARD | grep 'numcopies +[3-9]:' | cut -f2 -d':' | awk '{ sum+=$1} END {print sum}'`

   # Fix color problem for missing numbers.
   if [ -z "$IA1" ]; then IA1=0.001; fi
   if [ -z "$IA2" ]; then IA2=0.001; fi
   if [ -z "$IA3" ]; then IA3=0.001; fi
   if [ -z "$IA4" ]; then IA4=0.001; fi

# Head!

   cat html/graph.template.head | sed "s/IA1/${IA1}/g" | sed "s/IA2/${IA2}/g" | sed "s/IA3/${IA3}/g" | sed "s/IA4/${IA4}/g" | sed "s/TIME/${CHRONOS}/g" > "$HTMLTMP"

# Let's do GEO.....
    
   CLICOUNT=`cat $SHARD.geolist | wc -l`
   COUNTRYS=`cat $SHARD.geolist | sed 's/.*\"country_name\":\"//g' | sed 's/ /_/g' | cut -f1 -d'"' | sort -u | wc -l`
   
   for country in `cat $SHARD.geolist | sed 's/.*\"country_name\":\"//g' | sed 's/ /_/g' | cut -f1 -d'"' | sort -u`
       do
       PUNKY=`echo ${country} | sed 's/_/ /g'`
       COUNT=`grep "\"country_name\":\"${PUNKY}" $SHARD.geolist | wc -l `
       echo "['${PUNKY}', ${COUNT}]," >> "$HTMLTMP"
       done

       cat html/graph.template.middle >> "$HTMLTMP"

   for city in `cat $SHARD.geolist | grep "United States" | sed 's/.*\"zip_code\":\"//g' | sed 's/ /_/g' | cut -f1 -d'"' | sort -u`
       do
       PUNKY=`echo ${city} | sed 's/_/ /g'`
       COUNT=`grep "\"zip_code\":\"${PUNKY}" $SHARD.geolist | wc -l `
       echo "['${PUNKY}', ${COUNT}]," >> "$HTMLTMP"
       done

cat $SHARD.clientconnsperhour | sed -e 's/^[ \t]*//' | awk '{print $2, $3, $4, "Z", $1}'  | sed "s/^/['/g" | sed "s/ Z /', /g" | sed "s/$/],/g" | tail -24 > $SHARD.clientday

   SHARDNAME="$SHARD"
   if [ "$SHARDNAME" = ALL ]; then SHARDNAME=""; fi

   SIZE="$(cat $SHARD.size)"

   COLLECTIONS=""
   for c in $(cat $SHARD.collections); do
	   COLLECTIONS="$COLLECTIONS <a href=\"https://archive.org/collection/$c\">$c</a>"
   done

   if [ "$SHARD" = ALL ]; then
	SHARDSTATMATCH='*'
	PROGRESS_GRAPHURL="http://iabak.archiveteam.org:8080/render/?width=900&height=500&_salt=1428621391.124&target=legendValue(alias(color(scale(divideSeries(diffSeries(sumSeries(keepLastValue(iabak.shardstats.filecount.*))%2CsumSeries(keepLastValue(iabak.shardstats.numcopies.0.*)%2CkeepLastValue(iabak.shardstats.numcopies.1.*)%2CkeepLastValue(iabak.shardstats.numcopies.2.*)))%2CsumSeries(keepLastValue(iabak.shardstats.filecount.*)))%2C100)%2C'%2300dd00')%2C'>%3D3 backups')%2C'last')&target=legendValue(alias(color(scale(divideSeries(sumSeries(keepLastValue(iabak.shardstats.numcopies.2.*))%2CsumSeries(keepLastValue(iabak.shardstats.filecount.*)))%2C100)%2C'%2393dd93')%2C'2 backups')%2C'last')&target=legendValue(alias(color(scale(divideSeries(sumSeries(keepLastValue(iabak.shardstats.numcopies.1.*))%2CsumSeries(keepLastValue(iabak.shardstats.filecount.*)))%2C100)%2C'%23e89393')%2C'1 backup')%2C'last')&target=legendValue(alias(color(scale(divideSeries(sumSeries(keepLastValue(iabak.shardstats.numcopies.0.*))%2CsumSeries(keepLastValue(iabak.shardstats.filecount.*)))%2C100)%2C'red')%2C'IA only')%2C'last')&areaMode=stacked&from=-1weeks&vtitle=%25&yMax=100&yMin=0&title=Overall progress%2C %25"
   else
	SHARDSTATMATCH="shard$SHARDNUM"
	PROGRESS_GRAPHURL="http://iabak.archiveteam.org:8080/render/?width=900&height=500&_salt=1428622253.322&areaMode=stacked&from=-1weeks&vtitle=%25&yMax=100&yMin=0&title=SHARD$SHARDNUM%20progress%2C%20%25&target=legendValue%28alias%28color%28scale%28divideSeries%28diffSeries%28keepLastValue%28iabak.shardstats.filecount.shard$SHARDNUM%29%2CsumSeries%28keepLastValue%28iabak.shardstats.numcopies.0.shard$SHARDNUM%29%2CkeepLastValue%28iabak.shardstats.numcopies.1.shard$SHARDNUM%29%2CkeepLastValue%28iabak.shardstats.numcopies.2.shard$SHARDNUM%29%29%29%2CkeepLastValue%28iabak.shardstats.filecount.shard$SHARDNUM%29%29%2C100%29%2C%22%2300dd00%22%29%2C%22%3E%3D3%20backups%22%29%2C%22last%22%29&target=legendValue%28alias%28color%28scale%28divideSeries%28keepLastValue%28iabak.shardstats.numcopies.2.shard$SHARDNUM%29%2CkeepLastValue%28iabak.shardstats.filecount.shard$SHARDNUM%29%29%2C100%29%2C%22%2393dd93%22%29%2C%222%20backups%22%29%2C%22last%22%29&target=legendValue%28alias%28color%28scale%28divideSeries%28keepLastValue%28iabak.shardstats.numcopies.1.shard$SHARDNUM%29%2CkeepLastValue%28iabak.shardstats.filecount.shard$SHARDNUM%29%29%2C100%29%2C%22%23e89393%22%29%2C%221%20backup%22%29%2C%22last%22%29&target=legendValue%28alias%28color%28scale%28divideSeries%28keepLastValue%28iabak.shardstats.numcopies.0.shard$SHARDNUM%29%2CkeepLastValue%28iabak.shardstats.filecount.shard$SHARDNUM%29%29%2C100%29%2C%22red%22%29%2C%22IA%20only%22%29%2C%22last%22%29"
   fi
   CONNECTIONSGRAPHURL="http://iabak.archiveteam.org:8080/render/?width=497&height=400&_salt=1428538747.86&tz=UTC&target=keepLastValue%28iabak.shardstats.connections.${SHARDSTATMATCH}%29&from=-2weeks"

   cat html/graph.template.tail | sed "s/SHARDNAME/${SHARDNAME}/g" | sed "s!COLLECTIONS!${COLLECTIONS}!g" | perl -pe "s!CONNECTIONSGRAPHURL!${CONNECTIONSGRAPHURL}!g" | perl -pe "s!PROGRESS_GRAPHURL!${PROGRESS_GRAPHURL}!g" | sed "s/SIZE/${SIZE}/g" | sed "s/IA1/${IA1}/g" | sed "s/IA2/${IA2}/g" | sed "s/IA3/${IA3}/g" | sed "s/IA4/${IA4}/g" | sed "s/TIME/${CHRONOS}/g" | sed "s/CLICOUNT/${CLICOUNT}/g" | sed "s/CLAMBAKE/${COUNTRYS}/g" >> "$HTMLTMP"

fi

chmod 644 "$HTMLTMP"
mv -f "$HTMLTMP" "$SHARD.html"

done
