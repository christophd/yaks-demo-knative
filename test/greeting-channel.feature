@require(com.consol.citrus:citrus-validation-hamcrest:@citrus.version@)
Feature: Message event

  Background:
    Given Knative broker url: http://broker-ingress.knative-eventing.svc.cluster.local/yaks-demo/default
    Given variable id is "citrus:randomNumber(4)"
    Given Knative event consumer timeout is 20000 ms
    Given create Knative event consumer service words-service
    Given subscribe service words-service to Knative channel words

  Scenario: Process message event
    Given variable user is "Knative"
    When Knative event data: Hola ${user}!
    And send Knative event
      | type            | message |
      | source          | https://github.com/citrusframework/yaks |
      | subject         | messages |
      | id              | ID-message-${id} |
    Then receive Knative event as json
    """
    {
      "specversion" : "1.0",
      "type" : "word",
      "source" : "https://github.com/citrusframework/yaks",
      "subject" : "words",
      "id" : "@ignore@",
      "time": "@matchesDatePattern('yyyy-MM-dd'T'HH:mm:ss')@",
      "data" : "Hola"
    }
    """
    And receive Knative event as json
    """
    {
      "specversion" : "1.0",
      "type" : "word",
      "source" : "https://github.com/citrusframework/yaks",
      "subject" : "words",
      "id" : "@ignore@",
      "time": "@matchesDatePattern('yyyy-MM-dd'T'HH:mm:ss')@",
      "data" : "${user}!"
    }
    """
