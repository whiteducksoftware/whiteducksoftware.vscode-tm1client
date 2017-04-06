'use strict';
// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from 'vscode';

let fs = require('fs');
let peg = require('pegjs');

export class MdxFormatter {

    constructor() { }

    public formatMDX() {
        let path = vscode.extensions.getExtension('whiteducksoftware.vscode-tm1client').extensionPath;
        let editor = vscode.window.activeTextEditor;
        let doc = editor.document;
        let docContent = doc.getText(editor.selection);
        try {
            let parser = peg.generate(fs.readFileSync(path + '\\mdx-language\\formatmdx.pegjs', 'utf-8'));
            let output = parser.parse(docContent);
            editor.edit((e) => {
                e.replace(editor.selection, output);
            });
        }
        catch (e) {
            vscode.window.showErrorMessage(e.name + ': ' + e.message);
            console.log(e);
        }
    }
}