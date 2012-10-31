class Account
  include Mongoid::Document
  include Mongoid::Timestamps
  include EncryptionHelper

  belongs_to :user
  has_many :imported_lines
  has_many :line_items

  field :name, :type => String
  field :encrypted_password, :type => Moped::BSON::Binary, :default => ""
  field :random_iv, type: Moped::BSON::Binary, :default => ""
  field :import_format, :type => String

  def store_password(mobile_password, account_password)
    if mobile_password.present? and account_password.present?
      iv, enc = encrypt(mobile_password + MY_SALT, account_password)
      self.random_iv = BSON::Binary.new(iv)
      self.encrypted_password = BSON::Binary.new(enc)
    end
  end

  def retrieve_password(mobile_password)
    decrypt(mobile_password + MY_SALT, random_iv.to_s, self.encrypted_password.to_s)
  end

  def line_already_imported?(json_line)
    imported_lines.where(:imported_line => json_line).length > 0
  end

  def reset_balance
    current_balance = 0

    line_items.default_sort.reverse.each do |item|
      current_balance += item.amount * item.multiplier

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

  # ---------------------------
  # Importing functions

  def import_line_items(line_items_jsonified)
    all_payee_rules = ProcessingRule.get_payee_rules
    all_category_rules = ProcessingRule.get_category_name_rules
    line_items_jsonified.each do |json_str|
      unless line_already_imported?(json_str)
        line_item = LineItem.create(JSON.parse(json_str))
        ProcessingRule.perform_all_matching(all_payee_rules, line_item)
        ProcessingRule.perform_all_matching(all_category_rules, line_item)

        imported_lines.create(:imported_line => json_str, :line_item_id => line_item.id)
      end
    end
  end

  # end importing
  # ---------------------------
end
