@require(com.consol.citrus:citrus-validation-hamcrest:@citrus.version@)
Feature: Greeting Splitter

  Background:
    Given Kafka connection
      | url   | demo-kafka-cluster-kafka-bootstrap:9092 |
      | topic | greetings                               |
    Given Knative broker URL: http://default-broker.yaks-demo.svc.cluster.local
    Given Knative event consumer timeout is 20000 ms
    Given Knative broker default is running
    Given create Knative event consumer service greeting-words-service
    Given create Knative trigger greeting-words-service-trigger on service greeting-words-service with filter on attributes
      | type   | greeting-words |
      | source | https://github.com/citrusframework/yaks |

  Scenario: Split greeting event
    When send Kafka message with body: {"message": "Hola Knative!"}
    Then receive Knative event as json
    """
    {
      "specversion" : "1.0",
      "type" : "greeting-words",
      "source" : "https://github.com/citrusframework/yaks",
      "subject" : "greeting-splitter",
      "id" : "@startsWith('ID-greeting-splitter-')@",
      "time": "@matchesDatePattern('yyyy-MM-dd'T'HH:mm:ss')@",
      "data" : "@assertThat(anyOf(is(Hola), is(Knative!)))@"
    }
    """
    And receive Knative event as json
    """
    {
      "specversion" : "1.0",
      "type" : "greeting-words",
      "source" : "https://github.com/citrusframework/yaks",
      "subject" : "greeting-splitter",
      "id" : "@startsWith('ID-greeting-splitter-')@",
      "time": "@matchesDatePattern('yyyy-MM-dd'T'HH:mm:ss')@",
      "data" : "@assertThat(anyOf(is(Hola), is(Knative!)))@"
    }
    """
