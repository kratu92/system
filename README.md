# Debian 11 system setup and server installation
Collection of scripts that will allow you to setup a Debian web server and install a web server.

* **Setup Debian:** Debian 11 system configuration.
* **LEMP Install** Install lemp server (NGINX, mySQL, PHP)
* **NGINX Add Virtual host** Create a new virtual host/server block
* **MySQL Create Db and User** Create a new database and user
* **MySQL Remove Db and User** Remove a new database and user


## How to use

Download all the files before executing the script.
With the following code you will download and unzip the project.

```bash
sudo apt install wget unzip -y
wget https://github.com/kratu92/system/archive/master.zip
unzip master.zip && rm -f ./master.zip && cd system-master
chmod u+x *.sh -R
```
After running the previous code you will be located on the root directory.
To start the script run the following code and follow the instructions:

```bash
sudo ./system.sh
```
