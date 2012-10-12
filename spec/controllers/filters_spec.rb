require 'spec_helper'

describe ApplicationController do
  describe ".check_response" do
    it "should exist" do
      ApplicationController.new.should respond_to :check_response
    end
  end
end