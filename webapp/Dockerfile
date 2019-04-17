FROM badibadi/maven-jdk8

RUN git clone https://github.com/abadillo999/ESSD_WebServer.git

RUN cd ESSD_WebServer && \
    mvn -DskipTests   clean package

CMD ["java",  "-jar", "/ESSD_WebServer/target/SmartestPhone-0.0.1-SNAPSHOT.jar", "--contrasena=smartphone"]