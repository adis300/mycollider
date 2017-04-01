# Screen sharing
## For Firefox
For firefox open: about:config   search screensharing and add host to trust.
#For chrome
screen sharing plugin is needed.


sudo into root directory

```
sudo su - sneadm
```

## Update package

```
cd /app
rm -r -f ./go-rtc
cd ..
cp -r /home/a31/go-rtc/ app
```

Sudo is needed for permission to run app on port 80
```
cd /app/go-rtc
sudo ./go-rtc &
exit
```
