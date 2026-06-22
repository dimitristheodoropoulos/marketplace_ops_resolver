# app/services/error_analyzer.rb
require "net/http"
require "uri"
require "json"

class ErrorAnalyzer
  GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

  # Προσθέσαμε το όρισμα retries με default τιμή 3
  def self.analyze(error_message, retries = 3)
    api_key = ENV["GEMINI_API_KEY"]
    if api_key.nil? || api_key.empty?
      return { "category" => "Unknown", "suggested_action" => "Λείπει το Gemini API Key από τις μεταβλητές περιβάλλοντος." }
    end

    uri = URI.parse("#{GEMINI_URL}?key=#{api_key}")
    
    prompt = <<~PROMPT
      You are a Support Engineering AI Assistant for a major e-commerce marketplace.
      Analyze the following raw error message from a stuck order and return a strict JSON response.
      
      Error Message: #{error_message.inspect}

      The JSON response must have exactly these keys:
      1. "category": Choose one from ['Customer_Data_Issue', 'Merchant_Stock_Issue', 'Provider_Infrastructure_Down']
      2. "suggested_action": A short sentence in Greek explaining what the support team or system should do next.

      Return ONLY the raw JSON object. Do not include markdown code blocks like ```json.
    PROMPT

    header = { "Content-Type" => "application/json" }
    payload = {
      "contents" => [{ "parts" => [{ "text" => prompt }] }]
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = payload.to_json

    begin
      response = http.request(request)
      result = JSON.parse(response.body)
      
      if result["error"]
        code = result['error']['code']
        
        # Αν είναι 503 (High Demand) ή 429 (Rate Limit) και έχουμε υπόλοιπα retries
        if (code == 503 || code == 429) && retries > 0
          puts "   [Gemini #{code}] Υψηλό φορτίο. Αναμονή 3'' και επαναδοκιμή (Προσπάθειες: #{retries})..."
          sleep(3)
          return analyze(error_message, retries - 1) # Αναδρομική κλήση με -1 retry
        end

        return { 
          "category" => "Analysis_Failure", 
          "suggested_action" => "Google API Error: #{result['error']['message']} (Code: #{code})" 
        }
      end
      
      raw_text = result["candidates"][0]["content"]["parts"][0]["text"].strip
      clean_text = raw_text.gsub(/```json|```/, "").strip
      
      JSON.parse(clean_text)
    rescue => e
      { "category" => "Analysis_Failure", "suggested_action" => "Σφάλμα κατά την επικοινωνία με το AI: #{e.message}" }
    end
  end
end