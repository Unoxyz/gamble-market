#! /bin/bash

cd log
rm *.log
cd ..

for i in `seq 1 100`;
do
    ruby run.rb
	sleep 1
    echo "itr: $i "
done


