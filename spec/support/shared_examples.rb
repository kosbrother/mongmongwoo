shared_examples "return correct http status code" do
  it "should return status code 200" do
    action
    expect(response).to have_http_status(200)
  end
end

shared_examples "return correct response format" do
  it "should return JSON format" do
    action
    expect(response.content_type).to eq("application/json")
  end
end