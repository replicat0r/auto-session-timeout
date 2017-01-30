module AutoSessionTimeoutHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    verbosity = options[:verbosity] || 2
    active_url = options[:active_url] || '/active'
    timeout_url = options[:timeout_url] || '/timeout'
    code = <<JS
if (typeof(Ajax) != 'undefined') {
  new Ajax.PeriodicalUpdater('', '#{active_url}', {frequency:#{frequency}, method:'get', onSuccess: function(e) {
    if (e.responseText == 'false'){
      console.log('firstblock','#{timeout_url}')
      window.location.href = '#{timeout_url}';
      } 
  }});
}else if(typeof(jQuery) != 'undefined'){
  function PeriodicalQuery() {
    $.ajax({
      url: '#{active_url}',
      success: function(data) {
        if(data == 'false'){
          window.location.href = '#{timeout_url}';
        }
      }
    });
    setTimeout(PeriodicalQuery, (#{frequency} * 1000));
  }
  setTimeout(PeriodicalQuery, (#{frequency} * 1000));
} else {
  $.PeriodicalUpdater('#{active_url}', {minTimeout:#{frequency * 1000}, multiplier:0, method:'get', verbose:#{verbosity}}, function(remoteData, success) {
    if (success == 'success' && remoteData == 'false')
      console.log('last else:','#{timeout_url}')
      window.location.href = '#{timeout_url}';
  });
}
JS
    javascript_tag(code)
  end
end

ActionView::Base.send :include, AutoSessionTimeoutHelper