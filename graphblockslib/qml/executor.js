WorkerScript.onMessage = function(message) {
    console.log("Hello from thread" + message.block);
    message.block.execute(function(progress){
        WorkerScript.sendMessage({ 'type':'progress', 'progress': progress });
    });
    WorkerScript.sendMessage({ 'type':'finished', 'result': 'success' });
}
