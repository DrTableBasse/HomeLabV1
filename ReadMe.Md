

<h1 style="display: flex; align-items: center;">
   HomeLab V1
  <img src="src/img/Logo.png" width="50" alt="Logo" style="margin-left: 10px;"/>
</h1>



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


# Hardware

### Today 
1) **Server**:
    - **CPU**: i7-4770
    - **RAM**: 32GB DDR3
    - **Storage**: 1TB SSD
    - **Network**: 1Gbps
    - [**Reference**](https://www.topachat.com/pages/detail2_cat_est_ordinateurs_puis_rubrique_est_w_pc_puis_ref_est_in10087021.html)
2) **Switch**: 
    - **Model**: Zyxel GS1200-8
    - **Ports**: 8
    - **Network**: 1Gbps
3) **Router**: 
    - **Model**: [PfSense](https://www.pfsense.org/)


### Future

1) **Server**:\
    *I'll buy two servers like this to do a cluster.*
    - **Model**: GMK NucBox M5
    - **CPU**: Ryzen 7 5700U
    - **RAM**: 16 Go DDR4
    - **Storage**: 512 Go SSD
    - **Network**: 2x2.5 Gbps
    - [**Reference**](https://www.powerplanetonline.com/fr/gmktec-nucbox-m5-ryzen-7-5700u-16go-512go-noir)

2) **NAS**:
    - **Model**: Synology DS923+
    - **Storage**: 4x 16TB
    - **Network**: 2x2.5 Gbps
    - [**Reference**](https://www.synology.com/fr-fr/products/DS923+)

3) **Switch**: 
    - **Model**: Zyxel GS1200-8
    - **Ports**: 8
    - **Network**: 1Gbps

4) **Router**:
    - **Model**: [PfSense](https://www.pfsense.org/)