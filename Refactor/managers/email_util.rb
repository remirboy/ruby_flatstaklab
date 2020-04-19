class Email_Util < ActiveRecord::Base
  
  validate :not_in_blocked_domain, on: :create

  def create_email_alias
    begin
      new_alias = EmailAliasComponents::pick_hex_alias
    end while User.exists? kc_email_alias: new_alias

    new_alias
  end

  def not_in_blocked_domain
    return unless email.present? && User.blocked_domains.present?

    domain = email.split("@").last
    return unless User.blocked_domains.include? domain

    errors.add(:email, "is invalid")
  end

end