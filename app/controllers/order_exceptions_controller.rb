class OrderExceptionsController < ApplicationController
  before_action :set_order_exception, only: %i[ show edit update destroy ]

  # GET /order_exceptions or /order_exceptions.json
  def index
    @order_exceptions = OrderException.all
  end

  # GET /order_exceptions/1 or /order_exceptions/1.json
  def show
  end

  # GET /order_exceptions/new
  def new
    @order_exception = OrderException.new
  end

  # GET /order_exceptions/1/edit
  def edit
  end

  # POST /order_exceptions or /order_exceptions.json
  def create
    @order_exception = OrderException.new(order_exception_params)

    respond_to do |format|
      if @order_exception.save
        format.html { redirect_to @order_exception, notice: "Order exception was successfully created." }
        format.json { render :show, status: :created, location: @order_exception }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @order_exception.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /order_exceptions/1 or /order_exceptions/1.json
  def update
    respond_to do |format|
      if @order_exception.update(order_exception_params)
        format.html { redirect_to @order_exception, notice: "Order exception was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @order_exception }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @order_exception.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /order_exceptions/1 or /order_exceptions/1.json
  def destroy
    @order_exception.destroy!

    respond_to do |format|
      format.html { redirect_to order_exceptions_path, notice: "Order exception was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_exception
      @order_exception = OrderException.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def order_exception_params
      params.expect(order_exception: [ :order_number, :merchant_id, :status, :error_message, :resolved_at ])
    end
end
