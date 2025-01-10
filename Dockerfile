FROM openjdk:17
ADD jarstaging/com/valaxy/demo-workshop/2.1.3/demo-workshop-2.1.3.jar tttrend.jar
ENTRYPOINT ["java", "-jar", "tttrend.jar"]
