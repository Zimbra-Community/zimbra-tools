#!/bin/bash

account=$1

WHO=`whoami`
if [ $WHO != "zimbra" ]
then
  echo
  echo "Execute this scipt as user zimbra (\"su - zimbra\")"
  echo
  exit 1
fi

echo "*** This script has been modified for safety purposes ***"
echo "    This script generates zmmailbox commands that you can run at your discretion to remove I flags"
echo ""
echo "    Warning: be careful removing I flags on a shared mailbox, as this will invalidate all shares"
echo "    from users to the targeted mailbox."
echo ""
echo "    If there is no output following this line, then no I flags where found to fix."


zmprov ga "$1" &> /dev/null

if [ $? -ne 0 ]
then
  echo "The account $account does not exist!"
  exit 1
fi

zmmailbox -z -m "$account" gaf | sed "1,2d" | cut -d "/" -f "2-" | while read folder
do
  oldflags=$(zmmailbox -z -m "$account" gf "/$folder" | grep flags | head -n 1 | cut -d ":" -f 2 | sed 's@[^"]*"\([^"]*\)".*@\1@')
  newflags=$(echo "$oldflags" | sed 's@i@@g')

  if [ x"$oldflags" != x"$newflags" ]
  then
    echo zmmailbox -z -m "$account" mff "/$folder" "$newflags"
  fi
done