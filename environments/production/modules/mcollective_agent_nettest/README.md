# Choria Nettest agent

This is an agent that will execute a ping or remote connection test on mcollective hosts

I often find myself logging onto boxes to ping different sites to diagnose local or remote network issues, this means I can now just issue a single command and get results from anywhere I’m running mcollective.

## Installation

This module depends on the `Net::Ping` Ruby gem which requires a C++ compiler
to build.

## Usage

ICMP ping test:

    $ mco nettest ping hostname
    Do you really want to perform network tests unfiltered? (y/n): y

     * [ ============================================================> ] 11 / 11

    node1.example.net                        time = 0.429
    node8.example.net                        time = 0.388
    node5.example.net                        time = 0.686
    node4.example.net                        time = 1.858
    middleware.example.net                   time = 2.697
    node7.example.net                        time = 0.637
    node0.example.net                        time = 16.455
    node9.example.net                        time = 1.974
    node6.example.net                        time = 0.415
    node3.example.net                        time = 0.389
    node2.example.net                        time = 0.4

    Summary of RTT:

       Min: 0.388ms  Max: 16.455ms  Average: 2.393ms


    Finished processing 11 / 11 hosts in 85.76 ms

TCP connection test to port 8140:

    $ mco nettest connect hostname 8140

## Validator

The nettest agent supplies an fqdn validator which will validate if a string is a valid uri.

    validate :fqdn, :nettest_fqdn

The nettest agent supplies a server address validator which will validate that a given string includes both a valid hostname and port number separated by a colon.

    validate :serveraddress, :nettest_server_address

## Data Plugin

The nettest agent also supplies a data plugin which uses the nettest agent to check if a connection to a fqdn at a specific port can be made. The data plugin will return 'true' or 'false' and can be used during discovery or any other place where the MCollective discovery language is used.

    $ mco rpc rpcutil -S "Nettest('myhost', '8080').connect=true"

## Mma Aggregate Plugin

The nettest agent supplies a mma aggregate plugin which will determine the minimum value, maximum value and average value of a set of inputs determinted in a DDL.

    summarize do
      aggregate nettest_mma(:rtt, :format => "Min: %.3fms  Max: %.3fms  Average: %.3fms")
    end
