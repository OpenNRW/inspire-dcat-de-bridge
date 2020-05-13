package eu.odp.harvest.geo.oai;

import org.springframework.boot.SpringApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.apache.camel.component.servlet.CamelHttpTransportServlet;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.boot.web.servlet.ServletContextInitializer;
import org.springframework.web.servlet.DispatcherServlet;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import java.util.HashMap;
import java.util.Map;
import java.lang.String;

// see https://github.com/spring-projects/spring-boot/blob/master/spring-boot-samples/spring-boot-sample-traditional/src/main/java/sample/traditional/SampleTraditionalApplication.java

@SpringBootApplication
public class SpringBootApp {

	public static void main(String[] args) {
		SpringApplication.run(SpringBootApp.class, args);
	}

    // https://developers.redhat.com/blog/2018/03/26/camel-spring-boot-rest-dsl/
    @Bean
    public ServletRegistrationBean camelRegistrationBean() {
        ServletRegistrationBean rb = new ServletRegistrationBean(new CamelHttpTransportServlet(), "/omdf/*");
        rb.setLoadOnStartup(1);
        rb.setName("CamelServlet");
        return rb;
    }

    // cf https://stackoverflow.com/questions/22389996/how-to-configure-spring-boot-servlet-like-in-web-xml
    @Bean
    public ServletRegistrationBean dispatcherRegistrationBean() {
        ServletRegistrationBean rb = new ServletRegistrationBean(new DispatcherServlet());
        rb.setName("DispatcherServlet");
        rb.setLoadOnStartup(1);
        Map<String,String> params = new HashMap<String,String>();
        params.put("contextConfigLocation", "classpath:camel-oai-pmh.xml");
        rb.setInitParameters(params);
        return rb;
    }
}