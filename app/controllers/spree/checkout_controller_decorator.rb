Spree::CheckoutController.class_eval do  
  def edit
    if ((@order.state == "payment") && @order.valid?)
      puts "valid, processing"
      if @order.payable_via_pag_seguro?
        puts "payable via pag_seguro, adding payment"
        payment = Spree::Payment.new
        payment.amount = @order.total
        payment.payment_method = Spree::Order.pag_seguro_payment_method
        @order.payments << payment
        
        redirect_url = Rails.env.development? ? nil : "#{root_url}pag_seguro/callback"
        
        pag_seguro_payment = PagSeguro::Payment.new(
          Spree::Order.pag_seguro_payment_method.preferred_email,
          Spree::Order.pag_seguro_payment_method.preferred_token,
          redirect_url: redirect_url,
          id: @order.id)
       
        pag_seguro_payment.items = @order.line_items.map do |item|
          PagSeguro::Item.new(
            id: item.id,
            description: item.product.name,
            amount: format("%.2f", item.price.round(2)),
            quantity: item.quantity,
            weight: ( item.product.weight * 1000 ).to_i
          )
        end
       
        pag_seguro_payment.sender = PagSeguro::Sender.new(name: @order.name, email: @order.email, phone_number: @order.ship_address.phone)
        pag_seguro_payment.shipping = PagSeguro::Shipping.new(type: PagSeguro::Shipping::SEDEX, state: @order.ship_address.state.abbr, city: @order.ship_address.city, postal_code: @order.ship_address.zipcode, street: @order.ship_address.address1, complement: @order.ship_address.address2)
       
        @pag_seguro_url = pag_seguro_payment.checkout_payment_url
        payment.started_processing
      end
    end
  end
end
