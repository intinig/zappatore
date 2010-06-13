var Configuration = {
  server: 'http://zappatore.local:4567',
  apiKey: '0788cbceb5387c7f2eb8',
  channelName: 'zappatore-main',
  setDefaults: function() {
    $.ajaxSetup({
      error: function(xhr) {
        console.log(xhr);
        alert(xhr.status + " " + xhr.responseText);
      }
    });
  }
};
