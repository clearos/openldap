# openldap

Forked version of openldap with ClearOS changes applied

* git clone git+ssh://git@github.com/clearos/openldap.git
* cd openldap
* git checkout c7
* git remote add upstream git://git.centos.org/rpms/openldap.git
* git pull upstream c7
* git checkout clear7
* git merge --no-commit c7
* git commit
