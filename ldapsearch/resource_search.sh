#!/bin/bash
. resource_search.conf
echo $1
echo $2
pwd=`pass "$pwd_key"`
echo $pwd
ldapSearchArgs="-x -LL -h ldap.pramati.com -w $pwd -D 'uid=$1,ou=employees,dc=pramati,dc=com' -b 'ou=employees,dc=pramati,dc=com' -s sub '(cn=*$2*)'"
# ldapsearch -x -LL -h ldap.pramati.com -W -D "uid=$1,ou=employees,dc=pramati,dc=com" -b "ou=employees,dc=pramati,dc=com" -s sub "(cn=*$2*)"
eval ldapsearch $ldapSearchArgs
