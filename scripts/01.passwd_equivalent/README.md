
#### PreQ

Install the expect on your linux first

On redhat6,7
```
yum -y install expect
```

On redhat8
```
dnf -y install expect
```

#### Usage: expect 04_setup_user_equ.expect ${username} ${password} ${node1} ${node2} 05_sshUserSetup.sh
e.g
```
04_setup_user_equ.expect root root_passwod node1 node2 05_sshUserSetup.sh

```
