# Marketplace Ops Resolver 🚀

Το **Marketplace Ops Resolver** είναι μια εσωτερική Support Engineering πλατφόρμα (Backoffice Tool) σχεδιασμένη για σύγχρονα e-commerce marketplaces μεγάλης κλίμακας. Ο πρωταρχικός της στόχος είναι η αυτοματοποίηση του εντοπισμού, της κατηγοριοποίησης και της επίλυσης προβληματικών ή «κολλημένων» παραγγελιών (Order Exceptions) που προκύπτουν από αστοχίες τρίτων παρόχων (Courier APIs), προβλήματα αποθεμάτων των εμπόρων (Inventory/Merchant Stock) ή λανθασμένα δεδομένα χρηστών.

---

## 🛠️ Τεχνολογικό Stack & Προδιαγραφές

*   **Framework:** Ruby on Rails 8.1.3 (Development Environment)
*   **Database:** SQLite / Relational Architecture (`OrderException` model)
*   **AI Integration:** Gemini 2.5 Flash API (LLM-driven semantic log analysis)
*   **Automation:** Rake Tasks για Batch Processing και Scheduled Maintenance

---

## ✨ Βασικά Χαρακτηριστικά & Αρχιτεκτονική

### 1. AI-Powered Log Triage (`ErrorAnalyzer`)
Αντί για τη χειροκίνητη ανάγνωση ατελείωτων και δυσνόητων raw logs από την ομάδα Operations, το σύστημα ενσωματώνει έναν AI Service Layer. 
*   **Strict Structural JSON:** Το `ErrorAnalyzer` στέλνει τα logs στο Gemini API με εξειδικευμένο prompt, απαιτώντας αυστηρή απάντηση σε μορφή JSON (χωρίς markdown wrappers).
*   **Κατηγοριοποίηση:** Τα σφάλματα ταξινομούνται αυτόματα σε 3 βασικούς πυλώνες:
    *   `Customer_Data_Issue` (π.χ. άκυροι Ταχυδρομικοί Κώδικες).
    *   `Merchant_Stock_Issue` (π.χ. timeouts κατά το inventory lock).
    *   `Provider_Infrastructure_Down` (π.χ. 504 Gateway Timeouts από Courier Services).
*   **Actionable Insights:** Παρέχεται άμεση, ανθρωπίνως αναγνώσιμη προτεινόμενη ενέργεια στα Ελληνικά, η οποία εμφανίζεται live στο Support Dashboard.

### 2. Ανθεκτικότητα upstream με Retry Pattern & Backoff
Στον πραγματικό κόσμο, τα LLM APIs αντιμετωπίζουν συχνά transient errors (όπως το *Google API Error: 503 High Demand*). 
*   Ο κώδικας υλοποιεί ένα **recursive Retry Mechanism**. Αν το API επιστρέψει κωδικό `503` ή `429`, το Service παγώνει προσωρινά (`sleep`) και επαναλαμβάνει την κλήση αυτόματα έως και 3 φορές, εξασφαλίζοντας ανθεκτικότητα (resiliency) και data integrity στην παραγωγή.

### 3. Smart Batch Automation (Rake Tasks)
Το project εξαλείφει τις χειροκίνητες επαναλαμβανόμενες ενέργειες μέσω αυτόματων scripts:
*   `maintenance:retry_courier_timeouts`: Σκανάρει τη βάση, εντοπίζει παραγγελίες που απέτυχαν λόγω δικτυακού Timeout με τον Courier, και τις προωθεί αυτόματα αλλάζοντας το status σε `resolved`.
*   `maintenance:analyze_unresolved_with_ai`: Αναλαμβάνει το μαζικό asynchronous "triage" όλων των εκκρεμών σφαλμάτων με τη χρήση του AI.

---

## 🏃‍♂️ Οδηγίες Εγκατάστασης & Χρήσης

### 1. Προετοιμασία Περιβάλλοντος
Βεβαιωθείτε ότι έχετε εγκαταστήσει τα απαραίτητα gems και έχετε ορίσει το API Key της Google στο περιβάλλον σας:


# Εγκατάσταση dependencies
bundle install

# Ορισμός της μεταβλητής περιβάλλοντος για το Gemini API
export GEMINI_API_KEY="το_api_key_σας_εδώ"

2. Βάση Δεδομένων & Seed Data
Τρέξτε τα migrations για την προσθήκη των AI πεδίων και αρχικοποιήστε τη βάση με έτοιμα test cases (σενάρια courier timeouts, stock validation errors κλπ):

bin/rails db:migrate
bin/rails db:seed

3. Εκτέλεση Αυτοματισμών (CLI)
Για τη μαζική ανάλυση των unhandled exceptions με το AI, εκτελέστε:

bin/rake maintenance:analyze_unresolved_with_ai

Για την αυτόματη επίλυση των γνωστών Courier Timeouts:

bin/rake maintenance:retry_courier_timeouts

🎨 UI Preview (Support Dashboard)
Όταν η ομάδα Customer Care ή Support ανοίγει το dashboard, κάθε προβληματική παραγγελία συνοδεύεται πλέον από ένα δυναμικό, έγχρωμο box (Badge) ανάλογα με τη σοβαρότητα και την κατηγορία του AI Triage:

🔴 Provider Infrastructure Down: «Προτεινόμενη ενέργεια: Επανάληψη δημιουργίας κουπονιού αποστολής.»

🟡 Merchant Stock Issue: «Προτεινόμενη ενέργεια: Επικοινωνήστε με τον έμπορο για το πρόβλημα αποθέματος.»

🔵 Customer Data Issue: «Προτεινόμενη ενέργεια: Ελέγξτε και διορθώστε τον ταχυδρομικό κώδικα της διεύθυνσης αποστολής.»

🎯 Engineering Mindset & Στόχος Project
Το project αυτό αναπτύχθηκε με βάση την αρχή "Release early & Iterate" και την "AI-first" φιλοσοφία. Αντί για over-engineering, επιλύει ένα υπαρκτό πρόβλημα Operations χρησιμοποιώντας σύγχρονα LLM εργαλεία για την αυτοματοποίηση των mundane tasks, επιτρέποντας στους engineers να εστιάσουν σε high-level αρχιτεκτονικές προκλήσεις.