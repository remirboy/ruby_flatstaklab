class Card_Manager < ActiveRecord::Base

 def find_or_create_card(params)
    if params[:card_selector].present?
      return OpenStruct.new(
        success?: true,
        credit_card: OpenStruct.new(token: params[:card_selector]))
    end

    create_card(params)
 end

 def create_card(params, reservation = nil)
    customer = find_or_initialize_customer
    add_security_alert_if_needed(params, reservation)

    # enforce params[:device] even if set to force braintree to fail wen tampered with or absent
    card_params =
      params
      .except(:card_selector)
      .deep_merge(
        customer_id: customer.id,
        device_data: params[:device_data],
        options: { verify_card: true })

    Payments::PaymentMethod.create card_params
 end

   def add_security_alert_if_needed(params, reservation)
    if params[:token]
      alert_for_card_details(params[:token], reservation)
    else
      alert_cardholder_name(params[:cardholder_name], reservation)
    end

    alert_cards_count(reservation)
  end

  def alert_for_card_details(token, reservation)
    token = ::Stripe::Token.retrieve token
    card = token && token.card
    return unless card

    if NameMatcher.mismatch?(user: self, other_name: card.name)
      SecurityAlertsPublisher.publish!(
        alert_name: "card_name_does_not_match",
        source: reservation || self,
        description: "Card name does not match: user #{name} tries to add card for #{card.name}")
    end

    %w[name address_zip address_line1].each do |param|
      if card.public_send(param).blank?
        SecurityAlertsPublisher.publish!(
          alert_name: "card_details_missing",
          source: reservation || self,
          description: "Card details missing: user #{name} tries to add card #{card.last4}")
      end
    end
  end

  def alert_cardholder_name(cardholder_name, reservation)
    if NameMatcher.mismatch?(user: self, other_name: cardholder_name)
      SecurityAlertsPublisher.publish!(
        alert_name: "card_name_does_not_match",
        source: reservation || self,
        description: "Card name does not match: user #{name} tries to add card for #{cardholder_name}")
    end
  end

  def alert_cards_count(reservation)
    if credit_cards.count >= 2
      SecurityAlertsPublisher.publish!(
        alert_name: "multiple_ccs_used",
        source: reservation || self,
        description: "User has used three or more credit cards on this account. \
        Please manually check that this is valid")
    end
  end

    def balance
    [credits.sum(:amount), coupon_limit].min
  end

end