## How to monitor your Github repositories with Grafana

1) Firstable, you need to create a token on Github. Go to your settings, then Developer settings, and Personal access tokens.

2) Secondly, go to your `Data Sources` and add a new source. Choose `Github` and put your token in the `Token` field.

3) Now, you can create a new dashboard and add a new panel. Choose `Github` as data source and select the repository you want to monitor.



## Informations

By default, you have the grafana repository that is monitored. You can change the repository by changing the `Organization` and `Repository` field in the query.


## Example
There is an example of a dashboard that I created to monitor my repositories:

<img  src="src\img\DashBoard.png"/>