# spec/Dockerfile_spec.rb

require_relative "spec_helper"

describe "Dockerfile" do
  before(:all) do
    load_docker_image()
    set :os, family: :redhat
  end

  describe "Dockerfile#running" do
    it "runs the right version of CentOS" do
      expect(os_version).to include("CentOS")
      expect(os_version).to include("release 7")
    end
    it "runs as service user" do
      package_name = ENV['PACKAGE_NAME']
      expect(sys_user).to eql(package_name)
    end
  end

  describe package("kibana") do
    package_version = ENV['PACKAGE_VERSION']
    it { should be_installed.with_version("#{package_version}") }
  end

  describe command("/usr/share/kibana/bin/kibana --version") do
    package_version = ENV['PACKAGE_VERSION']
    its(:stdout) { should match("#{package_version}") }
    its(:exit_status) { should eq 0 }
  end
end
