'use strict';

import * as vscode from 'vscode';

const request = require('request');
const url = require('url');

export class TM1Client {

    private databases: TM1DataBase[];
    private database: TM1DataBase;
    private user: string;
    private passwd: string;

    constructor() {
        this.databases = [];
    }

    public connect(server: string, port: number) {

        var executeUrl = {
            protocol: 'http:',
            slashes: true,
            hostname: server,
            port: port,
            pathname: '/api/v1/Servers'
        };

        var options = {
            url: url.format(executeUrl),
            json: true,
            strictSSL: false
        };

        request.get(options, (error, res, body) => {
            if (!error && res.statusCode == 200) {
                this.initServers(body);
                vscode.window.showInformationMessage(`Connected to server ${server} on port ${port}`);
            } else {
                vscode.window.showErrorMessage(`Error connecting to server ${server} on port ${port}: status code ${res.statusCode}`);
            }
        });
    }

    private initServers(body: any) {
        this.databases = [];
        
        for (let db of body.value) {
            let dataBase = new TM1DataBase;
            dataBase.Name = db.Name;
            dataBase.IPAddress = db.IPAddress;
            dataBase.IPv6Address = db.IPv6Address;
            dataBase.PortNumber = db.PortNumber;
            dataBase.ClientMessagePortNumber = db.ClientMessagePortNumber;
            dataBase.HTTPPortNumber = db.HTTPPortNumber;
            dataBase.UsingSSL = db.UsingSSL;
            dataBase.AcceptingClients = db.AcceptingClients;

            if (dataBase.AcceptingClients) {
                this.databases.push(dataBase);
            }
        }
    }

    public getDatabaseNames(): string[] {
        let databaseNames = [];
        this.databases.forEach((db) => {
            databaseNames.push(db.Name);
        })
        return databaseNames;
    }

    public login(database: string, user: string, passwd: string) {
        this.database = this.databases.find((db) => {
            return db.Name == database;
        });
        this.user = user;
        this.passwd = passwd;
    }

    public getLogin(): TM1DataBaseLogin {
        if (!this.database) {
            return null;
        }
        let login = new TM1DataBaseLogin();
        if (this.database.UsingSSL) {
            login.Protocol = 'https:'
        } else {
            login.Protocol = 'http:'
        }
        login.Host = this.database.IPAddress;
        login.Port = this.database.HTTPPortNumber;
        login.User = this.user;
        login.Passwd = this.passwd;
        return login;
    }
}

export class TM1DataBaseLogin {
    Protocol: string;
    Host: string;
    Port: number;
    User: string;
    Passwd: string;
}

class TM1DataBase {
    Name: string;
    IPAddress: string;
    IPv6Address: string;
    PortNumber: number;
    ClientMessagePortNumber: number;
    HTTPPortNumber: number;
    UsingSSL: boolean;
    AcceptingClients: boolean;
}
