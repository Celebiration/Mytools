#!/usr/bin/bash

sto=$1
sto=${sto%.*}

hmmbuild -O ${sto}.sto.hmm_refined.sto ${sto}.hmm ${sto}.sto