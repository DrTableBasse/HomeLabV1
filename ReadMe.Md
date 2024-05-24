# HomeLab V1

## Description 

This is the first version of my home lab server. I'll push all dashboard and configurations files for every services I have.\
It's just a lab, not for production. You must check every services I host and select which you want to have on your own HomeLab.

## Which Hypervisor do I use ? 

Today, I'm on [Proxmox](https://www.proxmox.com/en/) because it's cool, open sources, simple and don't need licences if you don't need supports.

## List of Services 

- [Pterodactyl](https://pterodactyl.io/)\
*It's for host servers like  Minecraft and Discord Bot.*

- [Grafana](https://grafana.com/)\
*It's cool to see metrics and logs on one panel.*\
*If you want, you can see example of dashboard I have at this [link](https://github.com/DrTableBasse/HomeLabV1/tree/master/Grafana/Dashboard).*

- [Jellyfin](https://jellyfin.org/)\
*My Own Netflix plateform.*

- [Active Directory + Windows 10-11](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)\
*Sometimes, I test GPO and tricks to hack Active Directory and obtain informations. For this part, I recommand [GOAD Repository](https://github.com/Orange-Cyberdefense/GOAD).*

- [Docker](https://www.docker.com/)\
*If you don't know what is docker, just look at [this video](https://www.youtube.com/watch?v=_dfLOzuIg2o).*

- [LXC](https://linuxcontainers.org/)\
*Just an alternative at Docker. It can run containers too.*

- [PfSense](https://www.pfsense.org/)\
*Just a simple routeur which can be virtualize.*

## Futur
In the futur, I would like to perform some automatizations with Terraform, Ansible, Packer and other technos for auto-deploiement.\
Furthermore, I'll create an isolate network for my teams and my to improve our pentest skills.


## Network Schema

There is a simple schema of my network with my differents services

![alt text](src\img\Network.png)
