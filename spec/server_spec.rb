require_relative "../lib/cache"

require_relative "spec_helper"
require_relative "client"
require_relative "../server"
require_relative "../commands/retrieval"
require_relative "../commands/storage"


describe Server do
  let(:client) { Client.new(1892) }


  describe "SET" do
    context "with valid params" do
      it "returns STORED" do
        
        message = client.send_msg "set setted set_test 0"
        expect(message).to eq "STORED\r\n"

        getmessage = client.send_msg "get setted"
        expect(getmessage).to eq "set_test"
      end
    end
  end

  describe "ADD" do
    context "with valid params" do
      it "returns STORED" do
        
        message = client.send_msg "add added1 addtest1 0"
        expect(message).to eq "STORED\r\n"

        getmessage = client.send_msg "get added1"
        expect(getmessage).to eq "addtest1"
      end
    end

    context "with existing key" do
      it "returns NOT_STORED" do
        
        client.send_msg "add added2 addtest2 0"
        message = client.send_msg "add added2 addtestwrong 0"
        expect(message).to eq "NOT_STORED\r\n"

        getmessage = client.send_msg "get added2"
        expect(getmessage).to eq "addtest2"
      end
    end
  end

  describe "REPLACE" do
    context "with valid params" do
      it "returns STORED" do
        
        client.send_msg "set replaced1 test 0"
        message = client.send_msg "replace replaced1 replacedtest1 0"
        expect(message).to eq "STORED\r\n"

        getmessage = client.send_msg "get replaced1"
        expect(getmessage).to eq "replacedtest1"
      end
    end

    context "with non-existing key" do
      it "returns NOT_STORED" do
        
        message = client.send_msg "replace falsekey falsetest 0"
        expect(message).to eq "NOT_STORED\r\n"
        
      end
    end
  end

  describe "APPEND" do
    context "with valid params" do
      it "returns STORED" do
        
        client.send_msg "set appended test 0"
        
        message = client.send_msg "append appended appended"
        expect(message).to eq "STORED\r\n"
        
        getmessage = client.send_msg "get appended"
        expect(getmessage).to eq "testappended"
      end
    end
  end
  
  describe "PREPEND" do
    context "with valid params" do
      it "returns STORED" do
        
        client.send_msg "set prepended test 0"
        
        message = client.send_msg "prepend prepended prepended"
        expect(message).to eq "STORED\r\n"
        
        getmessage = client.send_msg "get prepended"
        expect(getmessage).to eq "prependedtest"
      end
    end
  end

  describe "CAS" do
    context "valid params" do
      it "returns STORED" do
        optionsSet = prettify_options("castest", "0", "0", "4", "", "test")
        Server::CACHE.set(optionsSet)
        options = prettify_options("castest", "0", "0", "8", "10", "castest2")
        message = Server::CACHE.cas(options)
        expect(message).to eq "STORED"
      end
    end

    context "with invalid cas token" do
      it "returns EXISTS" do
        optionsSet1 = prettify_options("castest2", "0", "0", "5", "", "test2")
        optionsSet2 = prettify_options("castest3", "0", "0", "5", "", "test3")
        Server::CACHE.set(optionsSet1)
        Server::CACHE.set(optionsSet2)
        options = prettify_options("castest3", "0", "0", "8", "1", "castest3")
        message = Server::CACHE.cas(options)
        expect(message).to eq "EXISTS"
      end
    end

    context "with invalid key" do
      it "returns NOT_FOUND" do
        options = prettify_options("castest4", "0", "0", "8", "1", "castest3")
        message = Server::CACHE.cas(options)
        expect(message).to eq "NOT_FOUND"
      end
    end
  end

  def prettify_options(*options)
    {   
      key:       options[0],
      flags:     options[1].to_i,
      exptime:   options[2].to_i,
      bytes:     options[3].to_i,
      cas_token: options[4].to_i,
      value:     options[5]
    }
  end
end