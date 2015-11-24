import QtQuick 2.0
import "qrc:/qml/theme/";

Item {
    property var jobs: []
    function executeBlock(blockId, innerBlock, progressReportFn, finishedFn) {
        if(jobs.indexOf(blockId) !== -1) {
            return false;
        }
        jobs[blockId] = [progressReportFn, finishedFn];
        blockExecutor.sendMessage({block: innerBlock});
        return true;
    }
    WorkerScript {
        id: blockExecutor
        source: "executor.js"
        onMessage: {
            if(messageObject.type === "progress") {
                jobs[blockId][0](messageObject.progress);
            } else if(messageObject.type === "finished") {
                var finishFn = jobs[blockId][1];
                delete jobs[blockId];
                finishFn(messageObject.progress);
            }
        }
    }
}
