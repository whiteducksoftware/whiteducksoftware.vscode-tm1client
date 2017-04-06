# White Duck Software TM1 MDX Client extension for Visual Studio Code

Beautify and Run MDX queries on IBM Cognos TM1 multidimensional databases.

## Features

* Beautify MDX statements for better readability with the `Format MDX` command.
* Execute MDX statements on a TM1 database with the `Execute MDX` command.

## Getting started

Download the .vsix package and install the extension in your Visual Studio Code or download the git repository and run it directly in Visual Studio Code.

### Formatting MDX queries 
![Formatting MDX queries](https://raw.githubusercontent.com/whiteducksoftware/whiteducksoftware.vscode-tm1client/master/images/format.gif)

### Connecting to  a TM1 database server and login to a database

Before executing MDX queries you have to connect to and login into a TM1 database server.

![Connect to a database server](https://raw.githubusercontent.com/whiteducksoftware/whiteducksoftware.vscode-tm1client/master/images/connect.gif)

The port number is the port of the TM1 admin server. By default the server listens on port 5895.
The communication with the admin server can only use http connections, not https connections.

> Tip: You can also enter the servername as _hostname_:_portnumber_

> Tip: You can state your mostly used database server as default server in the settings to shorten the connect process.

### Execute MDX queries
![Execute a MDX query](https://raw.githubusercontent.com/whiteducksoftware/whiteducksoftware.vscode-tm1client/master/images/execute.gif)

## Requirements

* TM1 MDX Client is a Visual Studio Code extension, so you need Visual Studio Code to run it.
* In order to execute MDX statements you must have access to a TM1 database.

## Extension Settings

This extension contributes the following settings:

* `whiteducksoftware.tm1client.defaultserver`: Default server for connection as _hostname_:_portnumber_

## Known Issues

* Not all function names are defined as keywords
* The formatting parser doesn't know all calculations yet.

## Release Notes

### 0.0.1

Initial release of TM1 client

### 0.0.2

* Bugfix: Didn't clear list of databases after re-connect
* Enhancement: Now recognizes element range expressions (_element_:_element_)

-----------------------------------------------------------------------------------------------------------

## Remarks

IBM, TM1, and Cognos are trademarks or registered trademarks of International Business Machines Corp.

-----------------------------------------------------------------------------------------------------------
