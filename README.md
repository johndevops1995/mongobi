# mongobi
Creación de una imagen de Docker para Mongo BI 

Mongo BI Connector es una herramienta increíble para usar su almacenamiento Mongo DB como un Business Intelligence Cube. Si ejecutó Mongo DB como contenedor Docker, tal vez preguntó cómo ejecuta Mongo BI Connector también como contenedor. Desafortunadamente, no hay casi nada en Docker Hub para ejecutar esto.

Pero nada se pierde. Siempre puedes construir tu propia imagen. Aquí hay un Dockerfile simple para lograr este requisito. Debe usar un mongosqld.confpara ejecutar Mongo BI Connector con éxito.

Dockerfile

```java
FROM ubuntu:18.04
WORKDIR /home/mongobi
RUN apt-get update
RUN apt-get install -y libssl1.0.0 libssl-dev libgssapi-krb5-2 wget
RUN wget https://info-mongodb-com.s3.amazonaws.com/mongodb-bi/v2/mongodb-bi-linux-x86_64-ubuntu1804-v2.13.1.tgz
RUN tar -xvzf mongodb-bi-linux-x86_64-ubuntu1804-v2.13.1.tgz
WORKDIR /home/mongobi/mongodb-bi-linux-x86_64-ubuntu1804-v2.13.1
RUN mkdir /logs
RUN ls
RUN echo $PATH
RUN install -m755 bin/mongo* /usr/local/bin/
EXPOSE 3307
CMD ["mongosqld", "--config=/home/mongobi/mongosqld.conf"]
```

Los paquetes instalados en el comando apt-get se determinaron como un proceso de prueba-error 😵.

Definamos algunas variables, para que puedas reemplazarlas con las tuyas cuando sea necesario:


✅ {{YourLogFolder}} ✅ = /home/johndoe/mongobi/logs 
✅ {{YourConfFolder}} ✅ = /home/johndoe/mongobi/conf 
✅ {{YourDockerUser}} ✅ = johndoe 
✅ {{YourSchemaPath}} ✅ = / home/johndoe/mongobi/schema/schema.drdl # SI LO TIENE, NO SE REQUIERE 😋

Ahora construye tu imagen como:

docker build -t ✅ {{YourDockerUser}} ✅/mongobi .

Para ejecutar esta imagen, primero cree una carpeta de registro, por ejemplo:

mkdir ✅ {{YourLogFolder}} ✅

Y crea un mongosqld.conf (por ejemplo):

✅{{YourConfFolder}}✅/mongosqld.conf



systemLog:
  path: '/logs/mongosqld.log'
  verbosity: 10
mongodb:
  net:
    uri: "mongodb://instance-1:27017,instance-2:27017/?replicaSet=MEDIUM"
#schema:
#  path: "✅{{YourSchemaPath}}✅" #If you have an schema please uncomment this line
net:
  bindIp: 0.0.0.0
  port: 3307

Ahora, agregue nuestro servicio a docker-compose.yml (si lo tiene)

docker-compose.yml


versión: "3" 
servicios: 
  # ... MÁS SERVICIOS ... 
  mongo-bi: 
    imagen: ✅ {{YourDockerUser}} ✅/mongobi 
    restart: siempre 
    volúmenes: 
      #- "✅ {{YourSchemaPath}} ✅:/home/ mongobi/schema.drdl" #Quite el comentario si tiene un archivo de esquema 
      - "✅ {{YourConfFolder}} ✅/mongosqld.conf:/home/mongobi/mongosqld.conf" 
      - "✅ {{YourLogFolder}} ✅:/logs" 
    container_name: "mongo-bi" 
    hostname: "mongo-bi" 
    puertos: 
      - "3307:3307"

Ejecutemos nuestro contenedor (usando nuestra ruta docker-compose.yml):

docker-compose up -d

Pruebe si su contenedor se está ejecutando:

tsil -f -n 25 ✅ {{SuCarpetaDeRegistro}} ✅/mongosqld.log
La salida debe ser similar a:

2019-12-16T18:14:16.404+0000 I CONTROL    [initandlisten] mongosqld starting: version=v2.13.1 pid=1 host=mongo-bi
2019-12-16T18:14:16.404+0000 I CONTROL    [initandlisten] git version: bae9ae2a9bff80642215b648d46312804fe62f2d
2019-12-16T18:14:16.404+0000 I CONTROL    [initandlisten] OpenSSL version OpenSSL 1.1.1  11 Sep 2018 (built with OpenSSL 1.1.1  11 Sep 2018)
2019-12-16T18:14:16.404+0000 I CONTROL    [initandlisten] options: {config: "/home/mongobi/mongosqld.conf", systemLog: {path: "/logs/mongosqld.log", verbosity: 10}, schema: {path: "/home/mongobi/schema.drdl"}, net: {bindIp: [0.0.0.0]}, mongodb: {net: {uri: "mongodb://instance-0:27017,instance-1:27017/?replicaSet=NeROUTE", auth: {source: "admin"}}}}
2019-12-16T18:14:16.404+0000 I CONTROL    [initandlisten] ** WARNING: Access control is not enabled for mongosqld.
2019-12-16T18:14:16.404+0000 I CONTROL    [initandlisten]
2019-12-16T18:14:16.413+0000 I NETWORK    [initandlisten] waiting for connections at [::]:3307
2019-12-16T18:14:16.413+0000 I NETWORK    [initandlisten] waiting for connections at /tmp/mysql.sock

Y voilà, se está ejecutando como un contenedor. 🤩

Puede encontrar esta imagen en Docker Hub: