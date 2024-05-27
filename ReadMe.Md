# HomeLab V1

## Description 

This is the first version of my home lab server. I'll push all dashboard and configuration files for every service I have.\
It's just a lab, not for production. You must check every service I host and select which you want to have on your own HomeLab.

## Which Hypervisor do I use? 

Today, I'm on [Proxmox](https://www.proxmox.com/en/) because it's cool, open source, simple, and doesn't need licenses if you don't need support.

## List of Services 

- [Pterodactyl](https://pterodactyl.io/)\
*It's for host servers like Minecraft and Discord Bot.*

- [Grafana](https://grafana.com/)\
*It's cool to see metrics and logs on one panel.*\
*If you want, you can see an example of the dashboards I have in this [folder](https://github.com/DrTableBasse/HomeLabV1/tree/master/Grafana/Dashboard).*

- [Jellyfin](https://jellyfin.org/)\
*My Own Netflix platform.*

- [Active Directory + Windows 10-11](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)\
*Sometimes, I test GPO and tricks to hack Active Directory and obtain information. For this part, I recommend [GOAD Repository](https://github.com/Orange-Cyberdefense/GOAD).*

- [Docker](https://www.docker.com/)\
*If you don't know what Docker is, take a look at [this video](https://www.youtube.com/watch?v=_dfLOzuIg2o).*

- [LXC](https://linuxcontainers.org/)\
*Just an alternative to Docker. It can run containers too.*

- [PfSense](https://www.pfsense.org/)\
*Just a simple router that can be virtualized.*

- [Cadvisor](https://github.com/google/cadvisor)\
*Monitor your containers.*

## Futur
In the future, I would like to perform some automatizations with Terraform, Ansible, Packer, and other technologies for auto-deployment.\
Furthermore, I'll create an isolated network for my teams and me to improve our pentest skills.


## Network Schema

There is a simple schema of my network with my different services

<img  src="src\img\Network.png"/>
