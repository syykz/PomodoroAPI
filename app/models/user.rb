class User < ApplicationRecord
  has_many :sns_credentials, dependent: :destroy
  # has_one_attached :sample_music
  has_many :music_sessions
  has_many :music_links

  def self.without_sns_data(auth)
    user = User.where(email: auth.info.email).first

    if user.present?
      sns = SnsCredential.create(
        uid: auth.uid,
        provider: auth.provider,
        user_id: user.id,
      )
    else
      user = User.new(
        email: auth.info.email,
      )
      sns = SnsCredential.new(
        uid: auth.uid,
        provider: auth.provider,
      )
      user.save
    end

    return { user: user, sns: sns }
  end

  def self.with_sns_data(auth, snscredential)
    user = User.where(id: snscredential.user_id).first

    # 仕様上あり得ないが念のためuserの存在確認
    unless user.present?
      user = User.new(
        email: auth.info.email,
      )
    end

    return { user: user }
  end

  def self.find_oauth(auth)
    uid = auth.uid
    provider = auth.provider
    snscredential = SnsCredential.where(uid: uid, provider: provider).first

    if snscredential.present?
      user = with_sns_data(auth, snscredential)[:user]
      sns = snscredential
    else
      user = without_sns_data(auth)[:user]
      sns = without_sns_data(auth)[:sns]
    end

    return { user: user, sns: sns }
  end

  protected

  def password_required?
    return false
  end
end