require 'spec_helper'

describe Raven do
  it "should not raise an exception if operation of type 'submit' is made" do
    pymtReq = Raven::RavenRequest.new('submit')
    pymtReq.should_not raise_exception
  end

  it "should raise an exception if operation of type 'wrong' is made" do
    expect { Raven::RavenRequest.new('wrong') }.to raise_exception
  end

  it "should submit a raven request with PRN, currency, cardnumber, PymtType, ExpiryDate, Amount" do 
    pymtReq = Raven::RavenRequest.new('submit')
    pymtReq.set('PRN', '840033')
    pymtReq.set('Currency', 'USD')
    pymtReq.set('CardNumber', '4000000000000010')
    pymtReq.set('PymtType', 'cc_debit')
    pymtReq.set('ExpiryDate', '0919')
    pymtReq.set('Amount', 2000)
    pymtReq.values['PRN'].should eq '840033'
    pymtReq.values['Currency'].should eq 'USD'
    pymtReq.values['CardNumber'].should eq '4000000000000010'
    pymtReq.values['PymtType'].should eq 'cc_debit'
    pymtReq.values['ExpiryDate'].should eq '0919'
    pymtReq.values['Amount'].should eq "2000"
  end 
end

