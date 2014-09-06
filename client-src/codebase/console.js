var console = {

    _times: [],
    time: function(label) {
        this._times[label]=Date.now();
    },
    timeEnd: function(label) {
        var time = this._times[label];
        if(!time) {
            throw new Error("No such label: "+label);
        }

        var duration = Date.now()-time;
        print(label+": "+duration+"ms");
    }

};