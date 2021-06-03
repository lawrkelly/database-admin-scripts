#!/bin/bash
#


# get the slow query file logs list

aws rds describe-db-log-files --region us-east-1 --db-instance-identifier leadedata_aurora-vpc | grep slow > list.txt

# remove the logiles as we append the results

rm output.txt
rm logfile.txt
rm aws_logfile.txt
rm aws_outfile.txt

# loop through the logfile list

for i in `cat list.txt`; do

    file=`echo $i | sed 's/^.*\///'| sed 's/",//'`
    file2=`echo $file | sed 's/"LogFileName":/''/'` 
    echo $file2 >> output.txt

    f=`echo "$i" | sed 's/^.*"slow/slow/' | sed 's/",//'` 
    g=`echo $f | sed 's/"LogFileName":/''/'` 
    echo $g >> logfile.txt 
done;

# remove blank lines
    
grep "\S" logfile.txt >> aws_logfile.txt
grep "\S" output.txt >> aws_outfile.txt

# join files and loop over once

paste -- "aws_logfile.txt" "aws_outfile.txt" |
while IFS=$'\t' read -r file1 file2 rest; do
	# echo  $file1
	# echo $file2

# run the loader python script to upload the files

python3 rds_log_downloader.py --s3_bucket database-admin-repo --region us-east-1 --db leadedata_aurora-vpc --logfile $file1 --output $file2

done
