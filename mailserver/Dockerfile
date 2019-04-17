FROM badibadi/maven-jdk8

RUN git clone https://github.com/abadillo999/ESSD_MailServer.git

RUN cd ESSD_MailServer && \
    mvn -DskipTests   clean package

CMD ["java",  "-jar", "/ESSD_MailServer/target/ServidorMail-0.0.1-SNAPSHOT.jar", "--contrasena=smartphone"]