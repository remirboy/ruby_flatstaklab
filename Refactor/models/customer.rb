class Customer < User
	has_many :reservations, foreign_key: "customer_id"
	has_many :property_reservations, through: :properties, source: :reservations
	has_many :coupons, through: :promotions
	has_many :credits
  	has_many :credits_granted, foreign_key: :referer_id, class_name: "Credit"
  	has_many :promotions, dependent: :destroy
	has_many :rewards, through: :promotions, source: :credit

	delegate :available, to: :promotions, prefix: true, allow_nil: true

	def future_reservations
   		reservations.future.accepted_or_on_hold
  	end

 	def future_or_current_reservations
  		reservations.active.current
 	end

 	def unreviewed_reservations
    reservations
      .joins(:property)
      .where(properties: { state: :active })
      .includes(:property)
      .includes(:review)
      .select(&:is_reviewable?)
  	end

	def has_reservations_in(destination = {})
     	user_reservation.future_or_current_reservations.find_each do |r|
     	return true if r.property.destination == destination
    	end

    	false
  	end

  	def has_pending_reservations?
    	host? && property_reservations.on_hold.exists?
  	end

  	def positive_balance?
    	card_manager.balance > 0
  	end

  	def has_coupon?(coupon)
    	coupons.include? coupon
  	end  


  
  	private

  	def find_or_initialize_customer
  		return payments_customer if payments_customer

   		customer = Payments::Customer.create(
      	   first_name: first_name,
      	   last_name: last_name,
           email: email)
    	update_column(:stripe_customer_id, customer.id)

      customer
    end

  	def payments_customer
    	@payments_customer ||= Payments::Customer.find(payments_customer_id) unless payments_customer_id.blank?
  	end

  	def credit_cards
   		return [] if ::Rails.env == "development" || payments_customer.blank?

    	payments_customer.credit_cards
  	end

  	def default_card
   		return nil if payments_customer.blank?

   	 	payments_customer.default_card
  	end

end