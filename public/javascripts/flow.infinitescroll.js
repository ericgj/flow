Flow.setupNamespace("InfiniteScroll");

Flow.InfiniteScroll.defaults = {             // settings used in articles#index:
  url: undefined,                            // '/articles.json?page=',
  nextSelector: undefined,                   // 'div.article_content:last',
  bufferPx: 0,
  callback: undefined,
  errback: undefined,
  loadMsgSelector: null,                     // 'div.infinitescroll'
  loadingID: 'infinitescroll-loading',
  loadingMsg: undefined,
  loadingImg: undefined,
  currPage: 1
}

Flow.InfiniteScroll.init = function(options){
    
  // config
  function(opts){
    var instance = this;
    var opts = instance.opts =  $.extend({}, Flow.InfiniteScroll.defaults, opts)
    opts.callback =  opts.callback || function() { };
    opts.errback = opts.errback || function() { };
    opts.loadMsgSelector = opts.loadMsgSelector || this.element;
    opts.loadingDiv = $('<div id="' + opts.loadingID + '"><img alt="' + opts.loadingText + '" src="' + opts.loadingImg + '" /><div>' + opts.loadingText + '</div></div>');
  }(options);
  
  _loadNext: function infinitescroll_loadnext(){
    var instance = this;
    var opts = this.opts;
    
    opts.currPage++;
    
    $.ajax({
      url: opts.url.join(opts.currPage),    // note this assumes url ends with page number, like '/path?page=' or '/path/pages/'
      dataType: 'json',
      beforeSend: instance._beforeSendHandler,
      success: instance._updateHandler,
      error: instance._errorHandler,
      complete: instance._completeHandler
    })
   
  }
  
  _beforeSendHandler: function infinitescroll_beforesend(){
    var opts = this.opts;
    
    opts.loadingDiv.appendTo(opts.loadMsgSelector);
    return true;
  }
  
  _completeHandler: function infinitescroll_complete(){
    var opts = this.opts;
    
    opts.loadingDiv.remove();
  }
  
  _updateHandler: function infinitescroll_update(data) {
    var opts = this.opts;
    
    // TODO check for array
    
    if(data.length = 0) return;
    
    for(var x = 0; x <= data.length - 1; x++){
      $(opts.nextSelector).after(data[x].html);
    }
        
    opts.callback.call(data);
  }
  
  // pass the error handler in the view
  // maybe define a generic error handler that uses the flash[:error] in application layout?
  _errorHandler: function(){
    opts.errback.call();   
  }
  
  _isnearbottom: function infinitescroll_isnearbottom(){
    var opts = this.opts;
    return ($(window).scrollTop() == $(document).height() - $(window).height() - opts.bufferPx)
  }
  
  $(window).scroll(function(){
    if (!this._isnearbottom()) return;
    this._loadNext();
  });

}