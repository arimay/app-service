# frozen_string_literal: true

RSpec.describe App::Service do
  it "has a version number" do
    expect(App::Service::VERSION).not_to be nil
  end
end
