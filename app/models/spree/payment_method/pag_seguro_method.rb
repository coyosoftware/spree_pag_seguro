module Spree
  class PaymentMethod::PagSeguroMethod < PaymentMethod
    preference :email, :string
    preference :token, :string
    
    def actions
      %w{capture void}
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      ['checkout', 'pending'].include?(payment.state)
    end

    # Indicates whether its possible to void the payment.
    def can_void?(payment)
      payment.state != 'void'
    end

    def capture(payment)
      payment.update_attribute(:state, 'pending') if payment.state == 'checkout'
      payment.complete
      true
    end

    def void(payment)
      payment.update_attribute(:state, 'pending') if payment.state == 'checkout'
      payment.void
      true
    end

    def source_required?
      false
    end
  end
end
