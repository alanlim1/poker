class TransactionsController < ApplicationController
  before_action :authenticate_player!
  # before_action :check_cart!

  def new
    # gon.client_token = generate_client_token
    @token = Braintree::ClientToken.generate
  end

  def create
      result = Braintree::Transaction.sale(
                amount: @total_price,
                payment_method_nonce: params[:payment_method_nonce]
      )

      if result.success?
        order = Order.create do
          transaction_id = result.transaction.id
          amount = result.transaction.amount
          player_id = current_player&.id
          status = "pending"
        end
        flash[:success] = "Congratulations! Your transaction is successful!"
        redirect_to root_path
      else
        flash[:danger] = "Something went wrong while processing your transaction. Please try again!"
        # gon.client_token = generate_client_token
        render :new
      end
    end


  # private
  # # def check_cart!
  # #   if current_player.get_cart_tokens.blank?
  # #     redirect_to root_url, alert: "Please add some items to your cart before processing your transaction!"
  # #   end
  # # end
  #
  # def generate_client_token
  # Braintree::ClientToken.generate
  # end
end
