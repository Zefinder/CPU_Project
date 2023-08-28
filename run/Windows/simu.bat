@echo off
set unix_c=/mnt/c
set script_path=%cd%
set script_path=%script_path:\=/%
set script_path=%unix_c%%script_path:~2%
bash -c "%script_path%/simu.sh \"%script_path%/CPU_Project/simulation/%1\""