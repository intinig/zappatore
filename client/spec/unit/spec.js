describe 'Configuration'
  // before_each
  //   list = $(fixture('user-ul-list'))
  // end
  describe '.setDefaults()'
    it 'should call ajaxsetup'
      $.should_receive('ajaxSetup')
      Configuration.setDefaults()
    end
    
    it 'should alert and log on a wrong request'
      mock_request().and_return('{}', 'application/json', 500)
      console.should_receive('log', 'twice')
      $.getJSON('/', function(data){})
    end
  end
end

describe 'DataPusher'
  describe '.init()'
    it 'should set the server'
      DataPusher.init()
      DataPusher.server.should.be_an_instance_of Pusher
    end
  end
end