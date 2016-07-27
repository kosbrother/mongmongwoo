class User < ActiveRecord::Base
  ANONYMOUS = 31
  FAKE_PASSWORD = SecureRandom.urlsafe_base64

  enum status: { disable: 0, enable: 1 }

  validates :email, presence: true,
            uniqueness: true,
            format: { with: /\A([\w+-].?)+@[a-z\d-]+(.[a-z]+)*.[a-z]+\z/i }

  has_secure_password
  has_many :orders, dependent: :destroy
  has_many :devices, class_name: "DeviceRegistration", dependent: :destroy
  has_many :favorite_items
  has_many :favorites, through: :favorite_items, source: :item
  has_many :message_records, dependent: :destroy
  has_many :messages, through: :message_records
  has_many :logins

  scope :recent, -> { order(id: :DESC) }
  acts_as_paranoid
  self.per_page = 20

  def self.search_by_search_terms(search_terms)
    joins('LEFT JOIN orders ON orders.user_id = users.id').joins('LEFT JOIN order_infos ON order_infos.order_id = orders.id').where('ship_phone = :ship_phone OR user_name = :user_name OR email = :email', search_terms).distinct.recent
  end

  def self.fake_mail(uid)
    "#{uid}@mmwooo.fake.com"
  end

  def self.register(email, password)
    user = find_or_initialize_by(email: email, is_mmw_registered: false)
    user.password = password
    user.is_mmw_registered = true
    if user.save
      UserMailer.delay.notify_user_registered(user)
      {result: true, user: user}
    else
      {result: false, message: user.errors.messages.values.flatten}
    end
  end

  def self.find_or_create_from_omniauth(auth)
    errors = []
    info = auth.extra.raw_info
    ActiveRecord::Base.transaction do
      info.email = User.fake_mail(auth.uid) if info.email.blank?
      user = find_or_initialize_by(email: info.email)
      user.password = User::FAKE_PASSWORD if  user.password_digest.nil?
      user.user_name = info.name
      errors << user.errors.messages unless user.save

      login = Login.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
      login.user_id = user.id
      login.user_name = info.name
      login.gender = info.gender
      errors << login.errors.messages unless login.save
      raise ActiveRecord::Rollback if errors.present?

      return user
    end
  end

  def sent_password_reset
    unless self.password_reset_token
      self.password_reset_token = SecureRandom.urlsafe_base64
      self.password_reset_sent_at = Time.zone.now
      self.save
    end
    UserMailer.delay.password_reset(self)
  end

  def user_name
    self[:user_name] || self[:email]
  end

  def my_messages
    Message.joins('LEFT JOIN message_records ON message_records.message_id = messages.id').where('message_type = :message_type OR message_records.user_id = :user_id', message_type: Message.message_types["萌萌屋官方訊息"], user_id: id).order(created_at: :DESC)
  end

  def device_id
    User.joins('LEFT JOIN orders ON orders.user_id = users.id').select('users.id, orders.device_registration_id AS device_registration_id').find(id).device_registration_id
  end
end