# frozen_string_literal: true

RSpec.describe App::Service do
  it "has a version number" do
    expect(App::Service::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
