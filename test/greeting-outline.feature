Feature: Greetings

  Background:
    Given URL: http://greeting-service-yaks-demo.svc.cluster.local

  Scenario Outline: Get greetings
    When send GET /<lang>
    Then verify HTTP response body: {"language": "<lang>", "message": "<greeting>"}
    And receive HTTP 200 OK

  Examples:
  | lang  | greeting         |
  | en    | Hello Knative! |
  | it    | Ciao Knative!  |
  | esp   | Hola Knative!  |
