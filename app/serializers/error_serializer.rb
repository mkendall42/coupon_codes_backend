class ErrorSerializer
  #This handles general error returns

  def self.handle_exception(exception, custom_message)
    #Check if exception.message is already an array of strings; if not, make it so

    # binding.pry

    if exception.message.class != Array
      errors_array = [exception.message]
    else
      errors_array = exception.message
    end

    {
      message: custom_message,
      errors: errors_array
    }
  end

end