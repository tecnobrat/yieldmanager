require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "A build run" do
  WSDL_DIR = File.join(File.dirname(__FILE__), '..', '..', 'wsdls')
  API_VERSION = "1.30"
  VERSION_DIR = "#{WSDL_DIR}/#{API_VERSION}"
  
  it "rejects non-standard api version" do
    ["", "a", "1"].each do |v|
      lambda { Yieldmanager::Builder.build_wsdls_for(v) }.should raise_error(ArgumentError)
    end
  end
  
  it "creates dir structure for new api version" do
    Yieldmanager::Builder.build_wsdls_for(API_VERSION)
    File.directory?("#{VERSION_DIR}").should be_true
    File.directory?("#{VERSION_DIR}/test").should be_true
    File.directory?("#{VERSION_DIR}/prod").should be_true
  end
  
  it "clears out old wsdls" do
    ["test","prod"].each do |env|
      dir = "#{WSDL_DIR}/#{API_VERSION}/#{env}"
      bad_wsdl = "#{dir}/bad.wsdl"
      File.makedirs(dir)
      File.open(bad_wsdl, "w") { |file| file.write("bad.wsdl")  }
      Yieldmanager::Builder.build_wsdls_for(API_VERSION)
      File.exists?(bad_wsdl).should be_false
    end
  end
  
  it "collects available services" do
    TEST = true
    Yieldmanager::Builder.build_wsdls_for(API_VERSION)
    Yieldmanager::Builder.lookup_services(API_VERSION).should include("contact")
    Yieldmanager::Builder.lookup_services(API_VERSION, TEST).should include("contact")
  end
  
  it "stores wsdl files" do
    Yieldmanager::Builder.build_wsdls_for(API_VERSION)
    Yieldmanager::Builder.lookup_services(API_VERSION).each do |s|
      File.exists?("#{VERSION_DIR}/prod/#{s}.wsdl").should be_true
    end
    Yieldmanager::Builder.lookup_services(API_VERSION, TEST).each do |s|
      File.exists?("#{VERSION_DIR}/test/#{s}.wsdl").should be_true
    end
  end
end