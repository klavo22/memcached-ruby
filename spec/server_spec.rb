require_relative "../lib/cache"

require_relative "spec_helper"
require_relative "client"
require_relative "../server"
require_relative "../commands/retrieval"
require_relative "../commands/storage"


describe Server do
  let(:client) { Client.new(1892) }
  let(:socket) { TCPSocket.open('localhost', 1892)}

  describe "SET" do
    context "with valid params" do
      it "returns STORED" do
        
        message = client.send_msg "set setted set_test 0"
        expect(message).to eq "STORED\r\n"

        getmessage = client.send_msg "get setted"
        expect(getmessage).to eq "set_test"
      end
    end

    context "with wrong command" do
      it "returns ERROR" do
        socket.puts "pet klavo 0 0 5"
        message = socket.gets
        expect(message).to eq "ERROR\r\n"
      end
    end 

    context "missing a parameter" do
      it "returns ERROR" do
        socket.puts "set klavo 0 5"
        message = socket.gets
        expect(message).to eq "ERROR\r\n"
      end
    end 

    context "missing key" do
      it "returns ERROR" do
        socket.puts "set 0 0 5"
        message = socket.gets
        expect(message).to eq "ERROR\r\n"
      end
    end 

    context "with non-numeric flags" do
      it "returns CLIENT_ERROR bad command line format" do
        socket.puts "set klavo a 0 5"
        message = socket.gets
        expect(message).to eq "CLIENT_ERROR bad command line format\r\n"
      end
    end
    
    context "with non-numeric expiration time" do
      it "returns CLIENT_ERROR bad command line format" do
        socket.puts "set klavo 0 a 5"
        message = socket.gets
        expect(message).to eq "CLIENT_ERROR bad command line format\r\n"
      end
    end
    
    context "with invalid flags" do
      it "returns CLIENT_ERROR bad command line format" do
        socket.puts "set klavo 4294967296 0 5"
        message = socket.gets
        expect(message).to eq "CLIENT_ERROR bad command line format\r\n"
      end
    end

    context "with negative expiration time" do
      it "returns STORED" do
        
        socket.puts "set expired 0 -1 7"
        socket.puts "expired"
        message = socket.gets
        expect(message).to eq "STORED\r\n"

        socket.puts "get expired"
        response = socket.gets
        expect(response).to eq "END\r\n"
      end
    end

    context "with positive expiration time" do
      it "returns STORED" do
        
        client.send_msg "set expired2 expired_test 4"

        sleep(2)
        response1 = client.send_msg "get expired2"
        expect(response1).to eq "expired_test"
        sleep(2)
        socket.puts "get expired2"
        message2 = socket.gets
        expect(message2).to eq "END\r\n"
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
        client.send_msg "set castest test 0"
        socket.puts "cas castest 0 0 8 12"
        socket.puts "castest2"
        message = socket.gets
        expect(message).to eq "STORED\r\n"
      end
    end

    context "with incorrect cas token" do

      it "returns EXISTS" do
        socket.puts "set castest2 0 0 5 noreply"
        socket.puts "test2"
        socket.puts "cas castest2 0 0 5 10"
        socket.puts "test3"
        message = socket.gets
        expect(message).to eq "EXISTS\r\n"
      end
    end

    context "with non-existing key" do
      it "returns NOT_FOUND" do
        socket.puts "cas falsekey 0 0 5 8"
        socket.puts "false"
        message = socket.gets
        expect(message).to eq "NOT_FOUND\r\n"
      end
    end

    context "with non-existing key" do
      it "returns CLIENT_ERROR bad command line format" do
        socket.puts "cas wrongtoken 0 0 5 18446744073709551616"
        message = socket.gets
        expect(message).to eq "CLIENT_ERROR bad command line format\r\n"
      end
    end

    context "without cas token" do
      it "returns ERROR" do
        socket.puts "cas notoken 0 0 5"
        message = socket.gets
        expect(message).to eq "ERROR\r\n"
      end
    end

    context "with negative token" do
      it "returns CLIENT_ERROR bad command line format" do
        socket.puts "cas negativetoken 0 0 5 -1"
        message = socket.gets
        expect(message).to eq "CLIENT_ERROR bad command line format\r\n"
      end
    end

  end
  
end