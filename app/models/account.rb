class Account
  include Mongoid::Document
  include EncryptionHelper

  belongs_to :user
  has_many :imported_lines
  has_many :line_items

  field :name, :type => String
  field :encrypted_password, :type => BSON::Binary, :null => false, :default => ""

  def store_password(user_password, account_password)
    self.encrypted_password = BSON::Binary.new(encrypt(user_password + MY_SALT, account_password))
  end

  def retrieve_password(user_password)
    decrypt(user_password + MY_SALT, self.encrypted_password)
  end

  def imported_line?(json_line)
    imported_lines.where(:imported_line => json_line).length > 0
  end
end
