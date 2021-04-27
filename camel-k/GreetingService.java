/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// camel-k: language=java open-api=openapi.json dependency=camel-openapi-java resource=openapi.json

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

import org.apache.camel.Exchange;
import org.apache.camel.builder.RouteBuilder;

public class GreetingService extends RouteBuilder {

    private final Map<String, String> greetings = new HashMap<>();

    public GreetingService() {
        greetings.put(Locale.GERMAN.getLanguage(), "Hallo %s!");
        greetings.put(Locale.ENGLISH.getLanguage(), "Hello %s!");
        greetings.put(Locale.FRENCH.getLanguage(), "Bonjour %s!");
        greetings.put(Locale.ITALIAN.getLanguage(), "Ciao %s!");
        greetings.put("esp", "Hola %s!");
    }

    @Override
    public void configure() throws Exception {
        // All endpoints starting from "direct:..." reference an operationId defined
        // in the "openapi.json" file.

        // Gets the openapi specification
        from("direct:openapi")
                .setBody().simple("resource:classpath:openapi.json");

        // Health check
        from("direct:health")
                .setBody().constant("{\"status\": \"UP\"}");

        // Publish greeting event to Knative event stream
        from("direct:greeting")
            .setHeader(Exchange.CONTENT_TYPE, constant("text/plain"))
            .process(exchange -> {
                String user = getUser(exchange);
                String message = greetings.getOrDefault(getLanguage(exchange), "No greeting available!");
                exchange.getIn().setBody(String.format(message, user));
            })
        .setHeader("CE-Type", constant("message"))
        .setHeader("CE-Source", constant("https://github.com/citrusframework/yaks"))
        .setHeader("CE-Subject", constant("messages"))
        .to("knative:channel/messages")
        .setHeader(Exchange.HTTP_RESPONSE_CODE, constant(201));
    }

    private String getLanguage(Exchange exchange) {
        return Optional.ofNullable(exchange.getIn().getHeader("language"))
                .map(Object::toString)
                .orElseThrow(() -> new IllegalArgumentException("Missing language as request header"));
    }

    private String getUser(Exchange exchange) {
        return Optional.ofNullable(exchange.getIn().getHeader("username"))
                .map(Object::toString)
                .orElseThrow(() -> new IllegalArgumentException("Missing user as request header"));
    }

}
