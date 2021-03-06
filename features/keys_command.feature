# Copyright (c) 2011, 2012 Solano Labs All Rights Reserved

@mimic
Feature: Keys command
  As a Solano user
  In order to use Solano from multiple computers/logins
  I want to manage a list of SSH keys authorized to use Solano

Background:
  Given `solano keys` will write into tmp storage

Scenario: Display keys
  Given the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
    | another   |
  When I run `solano keys`
  Then the output should contain "default"
  And the exit status should be 0
  And the output should contain "another"
  And the output should contain "keys:add"

Scenario: Handle no keys
  Given the user is logged in
  And the user has no keys
  When I run `solano keys`
  And the exit status should be 0
  And the output should contain "keys:add"

Scenario: Handle API failure
  Given the user is logged in
  And there is a problem retrieving keys
  When I run `solano keys`
  Then the exit status should not be 0
  And the output should contain "API Error"

Scenario: Fail if the user isn't logged in
  When I run `solano keys`
  Then it should fail with a login hint

Scenario: Generate first key
  Given the user is logged in
  And the user has no keys
  And adding the key "third" will succeed
  When I run `solano keys:gen third`
  Then the exit status should be 0
  And the key file named "third" should exist
  And the output should contain "Generating"
  And the output should contain "authorized"
  And the output should contain "Host"

Scenario: Generate key successfully
  Given the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
    | another   |
  And adding the key "third" will succeed
  When I run `solano keys:gen third`
  Then the exit status should be 0
  And the key file named "third" should exist
  And the output should contain "Generating"
  And the output should contain "authorized"
  And the output should contain "Host git.solanolabs.com"
  And the output should contain "IdentityFile"
  And the output should contain "identity.solano.third"
  And the output should not contain "identity.solano.third.pub"

Scenario: Fail to add key if the user isn't logged in
  When I run `solano keys:add identitiy.solano.third third`
  Then it should fail with a login hint

Scenario: Fail to generate key if the user isn't logged in
  When I run `solano keys:gen third`
  Then it should fail with a login hint

Scenario: Fail to add key with duplicate name
  Given the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
    | another   |
  When I run `solano keys:gen another`
  Then the exit status should not be 0
  And the key file named "another" should not exist
  And the output should contain "already have"

Scenario: Fail to add key with duplicate name
  Given the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
    | another   |
  And the public key file named "another" exists
  When I run `solano keys:add another identity.solano.another.pub`
  Then the exit status should not be 0
  And the output should contain "already have"

Scenario: Fail to generate key that already exists in the filesystem
  Given the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
    | another   |
  And adding the key "third" will succeed
  But the private key file named "third" exists
  When I run `solano keys:gen third`
  Then the exit status should not be 0
  And the output should contain "already exists"

Scenario: Add an existing key in the filesystem
  Given the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
    | another   |
  And adding the key "third" will succeed
  And the public key file named "third" exists
  When I run `solano keys:add third identity.solano.third.pub`
  Then the exit status should be 0
  And the output should contain "Adding"
  And the output should contain "Authorized"
  And the output should contain "IdentityFile"
  And the output should contain "identity.solano.third"
  And the output should not contain "identity.solano.third.pub"
  And the output should contain "Host"

Scenario: Fail to add key that does not exist in the filesystem
  Given the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
    | another   |
  When I run `solano keys:add identity.solano.third third`
  Then the exit status should not be 0
  And the output should contain "is not accessible"

Scenario: Fail to generate on API error
  Given the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
    | another   |
  But adding the key "third" will fail
  When I run `solano keys:gen third`
  Then the exit status should not be 0
  And the output should contain "API Error"

Scenario: Fail to add on API error
  Given the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
    | another   |
  And the public key file named "third" exists
  But adding the key "third" will fail
  When I run `solano keys:add third identity.solano.third.pub`
  Then the exit status should not be 0
  And the output should contain "API Error"

Scenario: Remove key successfully
  Given the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
    | another   |
  And removing the key "default" will succeed
  When I run `solano keys:remove default`
  Then the exit status should be 0
  And the output should contain "Removing key 'default'"
  And the output should contain "Removed key 'default'"

Scenario: Fail to remove if the user isn't logged in
  When I run `solano keys:remove third`
  Then it should fail with a login hint

Scenario: Fail to remove on API error
  Given the user is logged in
  And the user has the following keys:
    | name      |
    | default   |
    | another   |
  And removing the key "default" will fail
  When I run `solano keys:remove default`
  Then the exit status should not be 0
  And the output should contain "API Error"
