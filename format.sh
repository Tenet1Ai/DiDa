#!/bin/bash -x
for i in `ls *.*` ; do
  cat $i | tr -s '\n' > $i.new
  mv $i.new $i
done

for i in `ls *.*` ; do
  cat $i | awk '{gsub("\t","  ");print}' > $i.new
  mv $i.new $i
done
