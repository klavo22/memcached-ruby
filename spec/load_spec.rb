require_relative "spec_helper"
require_relative "client"
require_relative "../server"

describe Server do
    
    let(:client) { Client.new(1892) }

    context "process 1000 request simultaneously" do
      it "performs under 120s" do
        expect {
          threads = 1000.times.map do
            Thread.new do
              5.times.each do |time|
                client.send_msg "set key#{time} set_test 0"
              end
            end
          end
          threads.each(&:join)
        }.to perform_under(120).sec
      end
    end    

end