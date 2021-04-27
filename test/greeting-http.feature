@require(com.consol.citrus:citrus-validation-hamcrest:@citrus.version@)
Feature: Greeting event

  Background:
    Given URL: http://greeting-service-yaks-demo.apps.cdeppisc.rhmw-integrations.net
    Given Knative event consumer timeout is 20000 ms
    Given create Knative event consumer service http-words-service
    Given subscribe service http-words-service to Knative channel words

  Scenario: Process greeting event
    When send POST /greeting/de?username=Christoph
    Then receive HTTP 201 CREATED
    Then expect Knative event data: Hallo
    And verify Knative event
      | type            | word |
      | source          | https://github.com/citrusframework/yaks |
      | subject         | words |
      | id              | @ignore@ |
    Then expect Knative event data: Christoph!
    And verify Knative event
      | type            | word |
      | source          | https://github.com/citrusframework/yaks |
      | subject         | words |
      | id              | @ignore@ |
