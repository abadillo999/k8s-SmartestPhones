# k8s-SmartestPhones
#Práctica computación en la Nube
#Migración de una aplicación a Kubernetes

#Máster en Software Craftmanship
#ETSISI-UPM
Para el despliegue se ha utilizado Helm, con ayuda de la librería de Sprig, cada repo de Helm, utilizado para el despliegue de los servicios (Pods) contiene la siguiente estructura:
/ templates /Deployment.yaml
/Chart.yaml
/Values.yaml

Para desplegar correctamente la página web y el servicio de mail, se tienen que desplegar los servicios en la siguiente secuencia:
DataBase  MailServer  WebApp

El despliegue de WebApp contiene un archivo llamado requirements.yaml con la información de los despliegues de los que depende:
dependencies:
	  - name: database
	    alias: database
	    version: 0.0.1
	    repository: file://../../database
	  - name: smartest-phones-mail-server
	    alias: smartest-phones-mail-server
	    version: 0.0.1
	    repository: file://../../mailserver/helm


Para conseguirlo, se han utilizado InitContainers previos al despliegue del servicio, que esperan a que el siguiente servicio esté levantado para iniciar el despliegue del mismo:
		initContainers:
		- name: {{ .Values.global.mailserver_name }}-init
		image: {{ .Values.global.initContainer.registry}}{{ .Values.global.initContainer.image }} 
		imagePullPolicy: IfNotPresent
		command: ["sh","-c"]
		args:
		       - sleep 10;
		       until nslookup {{ .Values.global.database_service }};
		       do sleep 2;
		       done;
		       nc -w 1 -z {{ .Values.global.database_service }} {{.Values.global.database_port }}

Algunos valores compartidos entre los diferentes Pods, y declarados en el values.yaml de despliegue principal son:
global:
	  registry: badibadi/
	  webapp_name: alejandro-gbadillo-marco-cab-web-app
	  webapp_port: 8080
	  mailserver_name: alejandro-gbadillo-marco-cab-mail-server
	  mailserver_port: 8081
	  database_name: alejandro-gbadillo-marco-cab-database
	  database_service: database-service
	  database_claim: database-claim
	  database_port: 3306
	  initContainer:
	    registry: 
	    image: alpine

El numero de réplicas para cada servicio se ha limitado a 1, tras varias pruebas, se ha visto que al levantar más de una réplica de webapp o mailserver hay un conflicto en la base de datos y el servicio se cae, haciendo que los pods estén en constantes CrashLoopBackoff.
Las imágenes utilizadas se han construido a partir del siguiente Dockerfile, emulando el despliegue de Vagrant sugerido:
FROM ubuntu:xenial
	

	RUN apt-get update && \
	    apt-get install -y git && \
	    apt-get install -y openjdk-8-jre openjdk-8-jdk maven
	

	ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre/
	RUN echo ${JAVA_HOME}


Esta imagen y las del WebServer y MailServer se pueden encontrar  en:
https://hub.docker.com/u/badibadi






Para la base de datos se han descrito el siguiente servicio y PersistentVolumeClaim:

		kind: Service
		apiVersion: v1
		metadata:
		  name: {{ .Values.global.database_service }}
		spec:
		  selector:
		    app: {{ .Values.global.database_name }}
		  ports:
		  - protocol: TCP
		    port: {{ .Values.global.database_port }}
		

		---
		apiVersion: v1
		kind: PersistentVolumeClaim
		metadata:
		  name: {{ .Values.global.database_claim }}
		  labels:
		    app:  {{ .Values.global.database_name }}
		spec:
		  accessModes:
		    - ReadWriteOnce
		  resources:
		    requests:
		      storage: 2Gi

Los servicios de la WebApp y el MailServer se desacriben como NodePort:
kind: Service
apiVersion: v1
metadata:
  name: {{ .Values.global.webapp_name }}-service
spec:
  type: NodePort
  selector:
    app: {{ .Values.global.webapp_name }}
  ports:
  - protocol: TCP
    port: {{ .Values.global.webapp_port }}


Instrucciones de despliegue:
Primero se clonará el repo con el siguiente comando:
-	git clone https://github.com/abadillo999/k8s-SmartestPhones.git
-	cd k8s-SmartestPhones
Después se debe hacer un update da las dependencias de la aplicación principal:
-	helm dep update webapp/helm
Para desplegar el servicio (con minikube levantado):
-	helm install webapp/helm 
Para ver el estado de los pods y esperar a que estén levantados y corriendo:
-	kubectl get po
NAME                                                              READY   STATUS    RESTARTS   AGE
alejandro-gbadillo-marco-cab-database-54d5cb4c7-mrlp4             1/1     Running   0          6m58s
alejandro-gbadillo-marco-cab-mail-server-deployment-6c448dbxdpq   1/1     Running   0          6m58s
alejandro-gbadillo-marco-cab-web-app-deployment-ccbc996d8-4cn2t   1/1     Running   0          6m58s
Finalmente para mostrar la GUI ejecutar el comando:
-	  minikube service alejandro-gbadillo-marco-cab-web-app-service
