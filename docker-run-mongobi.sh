#si prefieres correr el contenedor sin el docker-compose
#ejecucion de una imagen con ubuntu y mongo-bi-connector creada previamente, instancia para que se conecte a la base mongo
#la configuracion de la conexion a la base se realiza en el archivo  mongosqld.conf
docker run --volume $HOME/mongobi/conf/mongosqld.conf:/home/mongobi/mongosqld.conf --volume $HOME/mongobi/logs:/logs -dit --restart unless-stopped --net=host -d -p 3307:3307 --name mongo-bi  itmanager/mongobi
