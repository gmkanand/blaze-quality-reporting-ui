'use strict';

import 'material-design-icons/iconfont/material-icons.css';
import 'typeface-roboto/index.css';
import 'typeface-roboto-mono/index.css';
require("./styles.scss");

const {Elm} = require('./Main.elm');
var app = Elm.Main.init({flags: {session: localStorage.session || null}});

app.ports.storeSession.subscribe(function (session) {
    localStorage.session = session;
});

app.ports.writeToClipboard.subscribe(function (text) {
    navigator.clipboard.writeText(text).then(
        function () {
            app.ports.clipboardSuccess && app.ports.clipboardSuccess.send();
        },
        function () {
            app.ports.clipboardFailure && app.ports.clipboardFailure.send();
        }
    );
});
