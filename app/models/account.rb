class Account
  include Mongoid::Document
  include EncryptionHelper

  belongs_to :user
  has_many :imported_lines
  has_many :line_items

  field :name, :type => String
  field :encrypted_password, :type => BSON::Binary, :null => false, :default => ""
  field :import_format, :type => String

  def store_password(user_password, account_password)
    self.encrypted_password = BSON::Binary.new(encrypt(user_password + MY_SALT, account_password))
  end

  def retrieve_password(user_password)
    decrypt(user_password + MY_SALT, self.encrypted_password)
  end

  def imported_line?(json_line)
    imported_lines.where(:imported_line => json_line).length > 0
  end

  def reset_balance
    current_balance = 0

    line_items.default_sort.reverse.each do |item|

      if item.virtual.blank?
        current_balance += item.amount * item.multiplier
      end

      if item.balance != current_balance
        item.balance = current_balance
        item.save
      end
    end
  end

  # ---------------------------
  # Mobile support functions

  def create_from_mobile(params)
    line_items.create(LineItem.serialize_from_mobile(params))
  end

  # end mobile support functions
  # ---------------------------
end
