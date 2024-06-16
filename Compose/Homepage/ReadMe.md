# What is Homepage ?

Homepage is an open-source project available on GitHub. It is a web application that allows users to create and customize their own personal homepage. With Homepage, users can easily access their favorite websites, view personalized widgets, and organize their online activities in one place.

The project provides a user-friendly interface and supports various customization options, such as choosing a theme, adding bookmarks, and integrating widgets for weather, news, and more. It aims to enhance productivity and convenience by providing a centralized hub for users to access their most frequently used online resources.

To get started with Homepage, simply clone the repository from [GitHub](https://github.com/gethomepage/homepage) and follow the installation instructions in the project's documentation. Customize your homepage to suit your needs and enjoy a personalized browsing experience.

Homepage is built using modern web technologies, including HTML, CSS, and JavaScript. It leverages popular libraries and frameworks such as React, Redux, and Material-UI to create a responsive and interactive user interface. The project is actively maintained and welcomes contributions from the open-source community.

# Example of Homepage Docker Compose Configuration

```yml
version: "3.3"
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    environment:
      PUID: 1000 -- optional, your user id
      PGID: 1000 -- optional, your group id
    ports:
      - 3000:3000
    volumes:
      - /path/to/config:/app/config # Make sure your local config directory exists
      - /var/run/docker.sock:/var/run/docker.sock:ro # optional, for docker integrations
    restart: unless-stopped
```

# Example of Homepage 
<img  src="src\img\example.png"/>