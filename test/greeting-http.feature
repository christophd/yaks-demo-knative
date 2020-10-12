@require(com.consol.citrus:citrus-validation-hamcrest:@citrus.version@)
Feature: Greeting

  Background:
    Given URL: http://greeting-service-yaks-demo.svc.cluster.local
    Given Knative broker URL: http://default-broker.yaks-demo.svc.cluster.local
    Given Knative event consumer timeout is 20000 ms
    Given Knative broker default is running
    Given create Knative event consumer service greeting-words-service
    Given create Knative trigger greeting-words-service-trigger on service greeting-words-service with filter on attributes
      | type   | greeting-words |
      | source | https://github.com/citrusframework/yaks |

  Scenario: Split greeting event
    When send POST /event/de
    Then receive HTTP 201 CREATED
    Then expect Knative event data: @assertThat(anyOf(is(Hallo), is(Knative!)))@
    And verify Knative event
      | type            | greeting-words |
      | source          | https://github.com/citrusframework/yaks |
      | subject         | greeting-splitter |
      | id              | @startsWith('ID-greeting-splitter-')@ |
    Then expect Knative event data: @assertThat(anyOf(is(Hallo), is(Knative!)))@
    And verify Knative event
      | type            | greeting-words |
      | source          | https://github.com/citrusframework/yaks |
      | subject         | greeting-splitter |
      | id              | @startsWith('ID-greeting-splitter-')@ |
