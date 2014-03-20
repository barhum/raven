require 'spec_helper'
require 'pry'

describe Raven do
  it "should not raise an exception if operation of type 'submit' is made" do
    pymtReq = Raven::Raven.new('submit')
    pymtReq.should_not raise_exception
  end

  it "should raise an exception if operation of type 'wrong' is made" do
    expect { Raven::Raven.new('wrong') }.to raise_exception
  end

  it "should set the current operation of submit" do
    pymtReq = Raven::Raven.new('submit')
    binding.pry
    pymtReq.operation.should eq 'submit'
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

  it "should return the value of the first valid key requested" do
    pymtReq = Raven::RavenRequest.new('submit')
    pymtReq.set('PRN', '840033')
    pymtReq.set('Currency', 'USD')
    pymtReq.get('PRN', 'Currency').should eq '840033' 
  end 

  it "should ignore an invalid key and return the first valid key requested" do
    pymtReq = Raven::RavenRequest.new('submit')
    pymtReq.set('PRN', '840033')
    pymtReq.set('Currency', 'USD')
    pymtReq.get('Wrong', 'Currency').should eq 'USD' 
  end  

  it "should print the values in a friendly form" do 
    pymtReq = Raven::RavenRequest.new('submit')
    pymtReq.set('PRN', '840033')
    pymtReq.set('Currency', 'USD')
    pymtReq.set('CardNumber', '4000000000000010')
    pymtReq.set('PymtType', 'cc_debit')
    pymtReq.set('ExpiryDate', '0919')
    pymtReq.set('Amount', 2000)
    pymtReq.printValues.should print ['840033', 'USD', '4000000000000010', 'cc_debit', '0919', '2000']
  end

  it "should set the user name from the config file" do 
    pymtReq = Raven::RavenRequest.new('submit')
    pymtReq.values['UserName'].should eq "ernest"
    pymtReq.values['RAPIVersion'].should eq "2"
    pymtReq.values['RAPIInterface'].should eq "Rails1.0"  
  end

  it "should return a signature for the operation" do 
    pymtReq = Raven::RavenRequest.new('submit')
    pymtReq.set('PRN', '840033')
    pymtReq.set('Currency', 'USD')
    pymtReq.set('CardNumber', '4000000000000011')
    pymtReq.set('PymtType', 'cc_debit')
    pymtReq.set('ExpiryDate', '0919')
    pymtReq.set('Amount', 2000)
    pymtReq.signature.length.should be 40
  end

  it "should set the signature in values" do 
    pymtReq = Raven::RavenRequest.new('submit')
    pymtReq.set('PRN', '840033')
    pymtReq.set('Currency', 'USD')
    pymtReq.set('CardNumber', '4000000000000011')
    pymtReq.set('PymtType', 'cc_debit')
    pymtReq.set('ExpiryDate', '0919')
    pymtReq.set('Amount', 2000)
    pymtReq.send
  end  

  it "should set the signature in values" do 
    pymtReq = Raven::RavenRequest.new('submit')
    pymtReq.set('PRN', '840033')
    pymtReq.set('Currency', 'USD')
    pymtReq.set('CardNumber', '4000000000000011')
    pymtReq.set('PymtType', 'cc_debit')
    pymtReq.set('ExpiryDate', '0919')
    pymtReq.set('Amount', 2000)
    response = pymtReq.send
    response.parseResponse
    response.getRequestResult.should eq 'ok'
  end  
end

