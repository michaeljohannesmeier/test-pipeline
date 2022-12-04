#!/bin/bash
scp ./files/kubeadm-init.yml kube-master:~
scp ./files/cloud.cfg kube-master:~
scp ./files/prep-master.sh kube-master:~
scp ./files/prep-worker.sh kube-worker-1:~