class ErrorSerializer
  def self.format_errors(messages, status)
    { message: 'Your request could not be completed, please read the details below.', 
      errors: [
        {
          status: status,
          detail: messages[0]
        }
      ]
    }
  end

  def self.forbidden_action(messages, status)
    { message: 'This actiion is forbidden, please read the details below.', 
      errors: [
        {
          status: status,
          detail: messages[0]
        }
      ]
    }
  end
  def self.format_invalid_search_response
    { 
      message: "your query could not be completed", 
      errors: ["invalid search params"] 
    }
  end
end