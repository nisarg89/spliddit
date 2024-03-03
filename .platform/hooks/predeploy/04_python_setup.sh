#!/bin/bash
cd /var/app/staging || exit
python3 -m pip install -r pip-requirements.txt
