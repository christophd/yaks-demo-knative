@require(com.consol.citrus:citrus-validation-hamcrest:@citrus.version@)
Feature: Greeting OpenAPI operation

  Background:
    Given OpenAPI specification: http://greeting-service-yaks-demo.apps.cdeppisc.rhmw-integrations.net/openapi
    Given Knative event consumer timeout is 20000 ms
    Given create Knative event consumer service openapi-words-service
    Given subscribe service openapi-words-service to Knative channel words

  Scenario: Trigger greeting event
    Given variable language is "it"
    Given variable username is "Paola"
    When invoke operation: greeting
    Then verify operation result: 201 CREATED
    Then expect Knative event data: Ciao
    And verify Knative event
      | type            | word |
      | source          | https://github.com/citrusframework/yaks |
      | subject         | words |
      | id              | @ignore@ |
    Then expect Knative event data: Paola!
    And verify Knative event
      | type            | word |
      | source          | https://github.com/citrusframework/yaks |
      | subject         | words |
      | id              | @ignore@ |
