# lib/tasks/maintenance.rake
namespace :maintenance do
  desc "Αυτόματη επανυποβολή παραγγελιών που κόλλησαν λόγω Courier Timeout"
  task retry_courier_timeouts: :environment do
    puts "[#{Time.now}] Ξεκινάει ο έλεγχος για Courier Timeouts..."

    stuck_orders = OrderException.where(status: "courier_api_error")
                                 .where("error_message LIKE ?", "%Timeout%")

    # Κρατάμε το πλήθος ΠΡΙΝ αλλάξουμε τα status στη βάση
    total_stuck = stuck_orders.count

    if total_stuck > 0
      stuck_orders.each do |exception|
        puts "-> Επανυποβολή για την παραγγελία: #{exception.order_number} (Merchant: #{exception.merchant_id})"
        
        exception.update!(
          status: "resolved",
          resolved_at: Time.current,
          error_message: "#{exception.error_message}\n\n[FIXED AUTOMATICALLY]: Voucher generated successfully on retry."
        )
      end
      # Χρησιμοποιούμε τη μεταβλητή cache αντί για νέο query
      puts "[SUCCESS] Λύθηκαν #{total_stuck} προβλήματα."
    else
      puts "Δεν βρέθηκαν κολλημένες παραγγελίες λόγω Timeout."
    end
  end

  desc "Ανάλυση όλων των ανεπίλυτων σφαλμάτων με τη χρήση του Gemini AI"
  task analyze_unresolved_with_ai: :environment do
    puts "[#{Time.now}] Έναρξη AI ανάλυσης για εκκρεμείς παραγγελίες..."

    # Παίρνουμε μόνο όσες ΔΕΝ έχουν επιλυθεί ακόμα
    pending_orders = OrderException.where(status: ["stuck_in_processing", "courier_api_error"])

    if pending_orders.any?
      pending_orders.each do |order|
        puts "-> Ανάλυση παραγγελίας #{order.order_number}..."
        
        # Κλήση του AI Service
        ai_result = ErrorAnalyzer.analyze(order.error_message)

        # Αποθήκευση των αποτελεσμάτων στην αντίστοιχη εγγραφή
        order.update!(
          ai_category: ai_result["category"],
          ai_suggested_action: ai_result["suggested_action"]
        )
        
        puts "   [OK] Κατηγορία: #{order.ai_category}"
        sleep(1) # Μικρή καθυστέρηση για να είμαστε safe με τα rate limits του API
      end
      puts "[SUCCESS] Η AI ανάλυση ολοκληρώθηκε για #{pending_orders.count} παραγγελίες."
    else
      puts "Δεν υπάρχουν εκκρεμείς παραγγελίες για ανάλυση."
    end
  end
end