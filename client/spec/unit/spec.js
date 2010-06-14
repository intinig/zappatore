describe 'Configuration'
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

  describe '.bindEvents()'
    it "should bind events"
      DataPusher.init()
      DataPusher.server.should_receive('bind', 'twice')
      DataPusher.bindEvents()
    end
  end
end

describe 'InterfaceActions'
  before_each
    rooms = $(fixture('rooms'))
    log = $(fixture('log'))
    welcome = $(fixture('welcome'))
    login_form = $(fixture('login-form'))
    dom = sandbox()
    dom.append(log)
    dom.append(rooms)
    dom.append(welcome)
    dom.append(login_form)
    $("body").append(dom)

    room = {players:['intinig'], rid:1}
  end
  
  describe '.roomCreated()'
    before_each
      InterfaceActions.roomCreated(room)
    end
    
    it "should add a message in #log"
      log.find('p').should.have_text 'intinig just entered Room #1'
    end
    
    it "should make rooms visible"
      rooms.should.be_visible
    end
    
    it "should add a new room"
      rooms.html().should.eql($.room(room))
    end
  end
  
  describe '.roomDestroyed()'
    before_each
      InterfaceActions.roomCreated(room)
      InterfaceActions.roomDestroyed(room)
    end
  
    it "should add a message in #log"
      log.find('p')[0].should.have_text 'intinig has just closed Room #1'
    end
    
    it "should remove the room"
      rooms.html().should.eql("")
    end
  end
  
  describe '.resetLoginForm()'    
    it "should remove #welcome"
      InterfaceActions.resetLoginForm()
      $('#welcome').length.should.eql 0
    end
    
    it "should show login-form"
      login_form.hide()
      InterfaceActions.resetLoginForm()
      login_form.should.be_visible
    end
  end
    
  after_each
    dom.remove()
  end
end

// resetLoginForm: function() {
//   $("#welcome").remove();
//   $("#login-form").show();
// },
