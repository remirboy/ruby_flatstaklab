require "uuidtools"
require "refinements"

using HashRefinements

class User < ActiveRecord::Base # rubocop:disable Metrics/ClassLength
  include Chronology
  include Reads
  include Phone
  include Verifiable

  EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9_]+\.)+[a-z]{2,})\Z/i

  authenticates_with_sorcery!

  
  has_many :properties, dependent: :destroy, foreign_key: "host_id"
  has_many :archive_entries, class_name: "Users::ConversationArchive"
  has_many :archived_messages, class_name: "Message", source: :message, through: :archive_entries

  # FIXME: IT SEEMS THAT MOST OF THE TIME WE ACTUALLY WANT ACTIVE AND APPROVED
  # PROPERTIES RATHER THAN JUST ACTIVE PROPERTIES
  has_many :active_properties,
    -> { where(state: :active) },
    class_name: "Property",
    foreign_key: :host_id
  has_many :approved_properties,
    -> { where(state: %i[active accepted]) },
    class_name: "Property",
    foreign_key: :host_id

  has_many :authentications, dependent: :destroy
  has_many :consents
  has_many :terms_of_services, through: :consents

 
  has_many :reviews

  has_one :payment_option
  has_many :membership_subscriptions, through: :properties

  # Specific Authentication types
  has_one :facebook_profile,
    -> { where(provider: "facebook") },
    class_name: :Authentication
  has_one :google_profile,
    -> { where(provider: "google_oauth2") },
    class_name: :Authentication

  accepts_nested_attributes_for :payment_option
  accepts_nested_attributes_for :authentications

  attr_accessor :tos

  mount_uploader :avatar, AvatarUploader

  validates :email, :kc_email_alias, presence: true, uniqueness: true
  validates :email, format: { with: EMAIL_FORMAT }

  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name,  presence: true, length: { maximum: 100 }
  validates :password,   presence: true, length: { within: 7..20 }, unless: -> { persisted? && password.blank? }

  validates_acceptance_of :tos

  after_create :link_to_active_tos

  scope :admins, -> { where admin: true }
  scope :hosts, -> { joins(:properties).uniq }
  scope :with_active_properties, -> { where properties: { state: %i[active accepted] } }

  delegate :latest_review, to: :reviews
  delegate :favorable?, to: :latest_review, prefix: true

  alias_attribute :payments_customer_id, :stripe_customer_id

  serialize(:verification_data_old)

  before_save { |user| user.verification_data_old = user.verification_data }

  def self.by_number(number)
    where("CONCAT(country_code, phone_number) = ?", number).first
  end

  def self.blocked_domains
    ENV["BLOCKED_DOMAINS"].try(:split, ",")
  end

  def temp_email?
    email.match?(/#{OauthAuthenticationService::TEMP_EMAIL}/)
  end

  def email=(value)
    self[:email] = value.try :downcase
  end

  def active?
    activation_state == "active"
  end

  def host?
    properties.exists?
  end

  def is_owner?(property)
    self == property.user
  end

  def has_avatar?
    avatar.thumb.to_s != avatar.default_url
  end

  def conversation_email(conversation_token)
    username = [kc_email_alias, conversation_token].join "+"

    "#{username}@people.kidandcoe.com"
  end

  def kc_email_alias
    return self[:kc_email_alias] unless self[:kc_email_alias].blank?

    self[:kc_email_alias] = email_util.create_email_alias
  end

  def accept_latest_tos!
    link_to_active_tos

    save!
  end

  def terms_of_service
    terms_of_services.last
  end

  def on_latest_tos?
    terms_of_service == TermsOfService.active
  end

  
  def reset_rejection_count!
    self.rejection_count = 0

    save!
  end

  def has_updated_profile?
    !phone_number.blank? && avatar.present? && email.present? && bio.present? && verification_data["result"] == "clear"
  end

  def can_complete?
    [has_avatar?, bio].any?(&:blank?)
  end

  def missing_rates?
    properties.active.not_qualified.exists?
  end

  def completed_rates_steps?
    !missing_rates?
  end

  def membership_outstanding?
    membership_subscriptions
      .with_active_property
      .select do |ms|
        ms.subscribed_for_payments? && ms.past_due? ||
          !ms.subscribed_for_payments? && !ms.free_and_not_ended?
      end
      .exists?
  end

  def link_to_active_tos
    consent = consents.build terms_of_service: TermsOfService.active
    consent.save!
  end

end
