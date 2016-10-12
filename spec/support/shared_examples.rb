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

shared_examples "return JSON 400 status code with error message" do
  it 'should not create new user and login' do
    message = JSON.parse(response.body)['error']
    expect(User.all.size).to eq(0)
    expect(Login.all.size).to eq(0)
    expect(response.status).to eq(400)
    expect(response.content_type).to eq 'application/json'
    expect(message).not_to be_nil
  end
end