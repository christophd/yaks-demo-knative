Feature: Greetings

  Background:
    Given URL: http://greeting-service-yaks-demo.apps.cdeppisc.rhmw-integrations.net

  Scenario Outline: Push <lang> greeting
    When send POST /greeting/<lang>?username=<user>
    And receive HTTP 201 OK

  Examples:
  | lang  | user   |
  | en    | John   |
  | it    | Paola  |
  | esp   | Xavi   |
