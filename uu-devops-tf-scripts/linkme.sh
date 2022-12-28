#!/bin/bash
echo "$LINENO: $0"

for i in $(dirname $0)/*.sh
do
  echo $i | grep -q linkme.sh
  [ $? -eq 0 ] && continue
  echo $i 
  ln -sf $i
done
for i in accounts/{438171280653,452418757197,804656202561,819417623337,089902810488,102553174541,543800268692}
do
if [ -d $i ] ; then
  echo "$i exists"
else
  echo "Creating $i"
  mkdir -pv $i
fi
done

[ ! -e New-Stage      ] && ln -sf accounts/089902810488 New-Stage
[ ! -e Staging        ] && ln -sf accounts/438171280653 Staging
[ ! -e NEW-DEV        ] && ln -sf accounts/452418757197 NEW-DEV
[ ! -e Implementation ] && ln -sf accounts/102553174541 Implementation
[ ! -e LAB            ] && ln -sf accounts/819417623337 LAB
[ ! -e Admin          ] && ln -sf accounts/804656202561 Admin
[ ! -e LCH PRODUCTION ] && ln -sf accounts/543800268692 LCH PRODUCTION

