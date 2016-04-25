FactoryGirl.define do
  factory :android_version, class: AndroidVersion do
    version_code 1
    version_name "1.2.3"
    update_message "gggg\ngggg\n"
  end
end