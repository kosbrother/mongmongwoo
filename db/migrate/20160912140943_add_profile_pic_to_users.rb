class AddProfilePicToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pic_url, :string

    Login.find_each do |login|
      if login.provider == 'facebook'
        pic_url = "https://graph.facebook.com/#{login.uid}/picture?width=100&height=100"
      elsif login.provider == 'google'
        response = Net::HTTP.get(URI("http://picasaweb.google.com/data/entry/api/user/#{login.uid}?alt=json"))
        begin
          pic_url = JSON.parse(response)['entry']['gphoto$thumbnail'].values.first
        rescue JSON::ParserError => e
        end
      end
      user = login.user
      user.update_column(:pic_url, pic_url) if pic_url
    end
  end
end
