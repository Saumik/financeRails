class Account
  include Mongoid::Document
  include Mongoid::Timestamps
  include EncryptionHelper

  belongs_to :user, :inverse_of => :accounts
  has_many :imported_lines
  has_many :line_items
  has_many :investment_line_items

  field :name, :type => String
  field :encrypted_password, :type => Moped::BSON::Binary, :default => ""
  field :random_iv, type: Moped::BSON::Binary, :default => ""
  field :import_format, :type => String

  def store_password(mobile_password, account_password)
    if mobile_password.present? and account_password.present?
      iv, enc = encrypt(mobile_password + MY_SALT, account_password)
      self.random_iv = Moped::BSON::Binary.new(:generic, iv)
      self.encrypted_password = Moped::BSON::Binary.new(:generic, enc)
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

    line_items.sort_for_balance.reverse.each do |item|
      unless item.tags.include? LineItem::TAG_CASH
        current_balance += item.signed_amount
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

  # ---------------------------
  # Importing functions

  def import_line_items(line_items_jsonified)
    if investment_account?
      symbols_updated = []
      line_items_jsonified.each do |json_str|
        unless line_already_imported?(json_str)
          line_item = investment_line_items.create(JSON.parse(json_str))
          symbols_updated << line_item.symbol
          imported_lines.create(:imported_line => json_str, :investment_line_item => line_item)
        end
      end
      symbols_updated.uniq.each do |symbol|
        user.update_asset_by_symbol(symbol)
      end
    else
      all_payee_rules = ProcessingRule.get_payee_rules
      all_category_rules = ProcessingRule.get_category_name_rules
      line_items_jsonified.each do |json_str|
        unless line_already_imported?(json_str)
          puts json_str.inspect
          line_item = line_items.create(JSON.parse(json_str))
          ProcessingRule.perform_all_matching(all_payee_rules, line_item)
          ProcessingRule.perform_all_matching(all_category_rules, line_item)

          imported_lines.create(:imported_line => json_str, :line_item => line_item)
        end
      end
    end
  end

  # end importing
  # ---------------------------

  def investment_account?
    import_format == 'Scottrade'
  end
end
