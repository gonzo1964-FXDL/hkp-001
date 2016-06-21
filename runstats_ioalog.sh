En#!/bin/bash
#
#       get runstats from cmr_iolaog     
#
#
qYear=`date --date '-'-1' day' +'%y'`
qDay=`date --date '-'-1' day' +'%d'`
qDat=`date --date '-'-1' day' +'%Y%m%d'`
#
############################
outPath="/netfs/CTLM/TOOLS/jobosr_scripts/log"
#
#
#       temporarily until ORACLE has been migrated to PG - SOurce jobs are in "CTMADM-IOALOG-CSV" called "RUNSSTATS-[1-6]P"
#
#
    ls -l MUC*${qDat}.csv
    files=`ls  MUC*${qDat}.csv`
    for j in ${files}
    do
        tail -n +3 ${j} > x_${j}
        xx=`echo ${j:5:2}`
        if [ ${xx} == "4C" ]
        then
            db_Table="runinfshout_cfs"
        else
            db_Table="runinfshout"
        fi
        echo "parse_insert_csv.py ${outPath}/x_${j} ${db_Table}"
        python /netfs/CTLM/TOOLS/jobosr_scripts/bin/parse_insert_csv.py ${outPath}/x_${j} ${db_Table}
    done
#
#
rm -irf ${outPath}/x_MUC*
echo "ORACLE done"
echo "PG START"
#
db_Table="runinfshout_tst"
for i in ct1tst ct4dev ct4tst ct5tst ct6tst
do
#    dbHost="mucctlatv02"
    if [ $i == "ct1tst" ]
        then
            export PGPASSWORD=ct1tst800
            dbUser="ct1tst800"
            dbName="ct1tst800"
            dbHost="mucctlatv02"
            dbPort="5438"
    fi
    if [ $i == "ct2tst" ]
        then
            export PGPASSWORD=ct2tst800
            dbUser="ct2tst800"
            dbName="ct2tst800"
            dbHost="mucctlatv02"
            dbPort="5438"
    fi
    if [ $i == "ct3tst" ]
        then
            export PGPASSWORD=ct3tst800
            dbUser="ct3tst"
            dbName="ct3tst800"
            dbHost="mucctlatv02"
            dbPort="5433"
    fi    
    if [ $i == "ct4tst" ]
        then
            dbUser="ct4tst"
            export PGPASSWORD=ct4tst800
            dbName="ct4tst800"
            dbHost="mucctlatv02"
            dbPort="5436"
    fi
    if [ $i == "ct5tst" ]
        then
            export PGPASSWORD=ct5tst800
            dbUser="ct5tst800"
            dbName="ct5tst800"
            dbHost="mucctlatv02"
            dbPort="5435"
    fi    
    if [ $i == "ct6tst" ]
        then
            export PGPASSWORD=ct6tst800
            dbUser="ct6tst"
            dbName="ct6tst800"
            dbHost="mucctlatv02"
            dbPort="5437"
    fi    
    if [ $i == "ct4dev" ]
        then
            export PGPASSWORD=ct4dev800
            dbUser="ct4dev"
            dbName="ct4dev800"
            dbHost="mucctlatv02"
            dbPort="5434"
            db_Table="runinfshout_dev"
    fi    
    
    #echo "$dbUser - $dbName - $dbPort - $dbHost"
    psql -U ${dbUser} -h ${dbHost} -p ${dbPort} -d ${dbName} -c "\copy (select distinct cmr_runinf.JOBNAME, cmr_runinf.ELAPTIME, cmr_runinf.TIMESTMP, cmr_runinf.ORDERNO,  cmr_runinf.nodeid, cmr_ioalog.odate, cms_jobdef.APPLIC, cms_jobdef.APPLGROUP, cmr_runinf.RUNCOUNT, cmr_runinf.OSCOMPSTAT from cmr_runinf, cms_jobdef, cmr_ioalog where cmr_runinf.orderno = cmr_ioalog.orderno and cmr_runinf.jobname = cms_jobdef.jobname  and cmr_runinf.STARTRUN = '${qDat}' order by TIMESTMP) to ${outPath}/${dbName}_${qDat}.csv  WITH CSV"
    #
    echo "parse_insert_csv.py ${outPath}/${dbName}_${qDat}.csv  ${db_Table}"
    python /netfs/CTLM/TOOLS/jobosr_scripts/bin/parse_insert_csv.py ${outPath}/${dbName}_${qDat}.csv  ${db_Table}
    #
done
#
gzip ${outPath}/*.csv
find ${outPath}/ -iname "*.gz" -mtime +30 -delete
ter file contents here
