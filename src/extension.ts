// Visual Studio Code Extension "TM1 MDX Client"

'use strict';

import * as vscode from 'vscode';
import * as tm1Client from './tm1client';
import * as formatMdx from './formatMdx';
import * as executeMdx from './executemdx';

// add commands when the extension is activated
export function activate(context: vscode.ExtensionContext) {

    let client = new tm1Client.TM1Client();

    // command "connect"
    let connectDisposable = vscode.commands.registerCommand('extension.TM1Connect', () => {
        let config = vscode.workspace.getConfiguration("whiteducksoftware.tm1client");
        let options: vscode.InputBoxOptions = {
            prompt: "Enter TM1 server name",
            value: config.get("defaultserver") as string,
            placeHolder: "server name"
        }
        vscode.window.showInputBox(options).then((server: string) => {
            // port number provided?
            let serverSplit = server.split(':');
            if (1 < serverSplit.length) {
                client.connect(serverSplit[0], Number(serverSplit[1]));
            } else {
                let options: vscode.InputBoxOptions = {
                    prompt: "Enter port number",
                    placeHolder: "port number"
                }
                vscode.window.showInputBox(options).then((portnumber) => {
                    client.connect(server, Number(portnumber));
                });
            }
        });
    });

    context.subscriptions.push(connectDisposable);

    // command "login"
    let loginDisposable = vscode.commands.registerCommand('extension.TM1Login', () => {
        let databaseNames = client.getDatabaseNames()
        if (0 == databaseNames.length) {
            vscode.window.showErrorMessage('No databases found. Perhaps you forgot to connect? Use "Connect to TM1 Server" command!')
            return;
        }

        vscode.window.showQuickPick(databaseNames).then((database: string) => {
            let options: vscode.InputBoxOptions = {
                prompt: "Enter user name",
                placeHolder: "user"
            }
            vscode.window.showInputBox(options).then((user: string) => {
                let options: vscode.InputBoxOptions = {
                    prompt: "Enter password",
                    placeHolder: "password",
                    password: true
                }
                vscode.window.showInputBox(options).then((password: string) => {
                    client.login(database, user, password);
                });
            });
        });
    });

    context.subscriptions.push(loginDisposable);

    // command "format MDX"
    let formatter = new formatMdx.MdxFormatter();
    let executor = new executeMdx.ExecuteMdx();
    let mdxResultChannel = vscode.window.createOutputChannel('MDX Result');

    let formatDisposable = vscode.commands.registerCommand('extension.formatMDX', (server: string, port: number) => {
        formatter.formatMDX();
    });

    context.subscriptions.push(formatDisposable);

    // command "execute MDX"
    let executeDisposable = vscode.commands.registerCommand('extension.executeMDX', () => {
        let login = client.getLogin();
        if (!login) {
            vscode.window.showWarningMessage('No login information! Use command "Login into TM1 Database" first.');
            return;
        }
        let editor = vscode.window.activeTextEditor;
        let doc = editor.document;
        let command = doc.getText(editor.selection);
        executor.executeMDX(command, login, (result, error) => {
            if (!error) {
                mdxResultChannel.clear();
                mdxResultChannel.append(result);
                mdxResultChannel.show();
            } else {
                vscode.window.showErrorMessage(error.error.message);
            }
        });
    });

    context.subscriptions.push(executeDisposable);

    console.log('Loaded extension "TM1 MDX Client"!');
}

// this method is called when your extension is deactivated
export function deactivate() {
}