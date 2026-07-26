"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ConoutConnection = void 0;
var net_1 = require("net");
var conout_1 = require("./shared/conout");
var eventEmitter2_1 = require("./eventEmitter2");
var FLUSH_DATA_INTERVAL = 1000;
var ConoutConnection = (function () {
    function ConoutConnection(_conoutPipeName, _useConptyDll) {
        var _this = this;
        this._conoutPipeName = _conoutPipeName;
        this._useConptyDll = _useConptyDll;
        this._isDisposed = false;
        this._onReady = new eventEmitter2_1.EventEmitter2();
        this._conoutSocket = new net_1.Socket();
        this._conoutSocket.setEncoding('utf8');
        this._conoutSocket.connect(_conoutPipeName, function () {
            _this._server = net_1.createServer(function (workerSocket) {
                _this._conoutSocket.pipe(workerSocket);
            });
            _this._server.listen(conout_1.getWorkerPipeName(_conoutPipeName));
            _this._onReady.fire();
        });
    }
    Object.defineProperty(ConoutConnection.prototype, "onReady", {
        get: function () { return this._onReady.event; },
        enumerable: false,
        configurable: true
    });
    ConoutConnection.prototype.dispose = function () {
        if (!this._useConptyDll && this._isDisposed) { return; }
        this._isDisposed = true;
        this._drainDataAndClose();
    };
    ConoutConnection.prototype.connectSocket = function (socket) {
        socket.connect(conout_1.getWorkerPipeName(this._conoutPipeName));
    };
    ConoutConnection.prototype._drainDataAndClose = function () {
        var _this = this;
        if (this._drainTimeout) { clearTimeout(this._drainTimeout); }
        this._drainTimeout = setTimeout(function () { return _this._destroySocket(); }, FLUSH_DATA_INTERVAL);
    };
    ConoutConnection.prototype._destroySocket = function () {
        if (this._server) { this._server.close(); }
        if (this._conoutSocket) { this._conoutSocket.destroy(); }
    };
    return ConoutConnection;
}());
exports.ConoutConnection = ConoutConnection;
