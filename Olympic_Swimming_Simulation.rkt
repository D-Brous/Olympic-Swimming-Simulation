#lang typed/racket

(require "../include/cs151-core.rkt")
(require "../include/cs151-image.rkt")
(require "../include/cs151-universe.rkt")
(require typed/test-engine/racket-tests)

;; <<<<<<<<<<<<<<<<<<<<<<<<<<<< Display Preferences >>>>>>>>>>>>>>>>>>>>>>>>>>>>

(: pool-color Color)
(define pool-color (make-color 77 195 255))

(: swimmer-color Color)
(define swimmer-color (make-color 199 77 255))

(: paused-color Color)
(define paused-color (make-color 255 202 66))

(: 1st-color Color)
(define 1st-color (make-color 247 203 7))

(: 2nd-color Color)
(define 2nd-color (make-color 204 204 204))

(: 3rd-color Color)
(define 3rd-color (make-color 204 115 55))

(: no-medal-color Color)
(define no-medal-color (make-color 0 0 0))

;; <<<<<<<<<<<<<<<<<<<<<<<<<<<<< Types and Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>

(define-struct (Some T)
  ([value : T]))

(define-type (Optional T)
  (U 'None (Some T)))

(define-struct (Pairof A B)
  ([first : A]
   [second : B]))

(define-type TickInterval
  Positive-Exact-Rational)

(define-type Direction
  (U 'Left 'Right))

(define-struct Date
  ([month : Integer]
   [day : Integer]
   [year : Integer]))

(define-type Stroke
  (U 'Freestyle 'Backstroke 'Breaststroke 'Butterfly))

(define-struct Event
  ([gender : (U 'Men 'Women)]
   [race-distance : Integer]
   [stroke : Stroke]
   [name : String]
   [date : Date]))

(define-type Country
  (U 'AFG 'ALB 'ALG 'AND 'ANG 'ANT 'ARG 'ARM 'ARU 'ASA 'AUS 'AUT 'AZE 'BAH
     'BAN 'BAR 'BDI 'BEL 'BEN 'BER 'BHU 'BIH 'BIZ 'BLR 'BOL 'BOT 'BRA 'BRN
     'BRU 'BUL 'BUR 'CAF 'CAM 'CAN 'CAY 'CGO 'CHA 'CHI 'CHN 'CIV 'CMR 'COD
     'COK 'COL 'COM 'CPV 'CRC 'CRO 'CUB 'CYP 'CZE 'DEN 'DJI 'DMA 'DOM 'ECU
     'EGY 'ERI 'ESA 'ESP 'EST 'ETH 'FIJ 'FIN 'FRA 'FSM 'GAB 'GAM 'GBR 'GBS
     'GEO 'GEQ 'GER 'GHA 'GRE 'GRN 'GUA 'GUI 'GUM 'GUY 'HAI 'HON 'HUN 'INA
     'IND 'IRI 'IRL 'IRQ 'ISL 'ISR 'ISV 'ITA 'IVB 'JAM 'JOR 'JPN 'KAZ 'KEN
     'KGZ 'KIR 'KOR 'KOS 'KSA 'KUW 'LAO 'LAT 'LBA 'LBN 'LBR 'LCA 'LES 'LIE
     'LTU 'LUX 'MAD 'MAR 'MAS 'MAW 'MDA 'MDV 'MEX 'MGL 'MHL 'MKD 'MLI 'MLT
     'MNE 'MON 'MOZ 'MRI 'MTN 'MYA 'NAM 'NCA 'NED 'NEP 'NGR 'NIG 'NOR 'NRU
     'NZL 'OMA 'PAK 'PAN 'PAR 'PER 'PHI 'PLE 'PLW 'PNG 'POL 'POR 'PRK 'QAT
     'ROU 'RSA 'ROC 'RUS 'RWA 'SAM 'SEN 'SEY 'SGP 'SKN 'SLE 'SLO 'SMR 'SOL
     'SOM 'SRB 'SRI 'SSD 'STP 'SUD 'SUI 'SUR 'SVK 'SWE 'SWZ 'SYR 'TAN 'TGA
     'THA 'TJK 'TKM 'TLS 'TOG 'TTO 'TUN 'TUR 'TUV 'UAE 'UGA 'UKR 'URU 'USA
     'UZB 'VAN 'VEN 'VIE 'VIN 'YEM 'ZAM 'ZIM))

(define-struct IOC
  ([abbrev : Country]
   [country : String]))

(define-struct Swimmer
  ([lname : String]
   [fname : String]
   [country : Country]
   [height : Real]))

(define-struct Result
  ([swimmer : Swimmer]
   [splits : (Listof Real)]))

(define-type Mode
  (U 'choose 'running 'paused 'done))

(define-struct (KeyValue K V)
  ([key : K]
   [value : V]))
         
(define-struct (Association K V)
  ([key=? : (K K -> Boolean)]
   [data : (Listof (KeyValue K V))]))

(define-struct FileChooser
  ([directory : String]
   [chooser : (Association Char String)]))
;; a map of chars #\a, #\b etc. to file names

(define-struct Sim
  ([mode : Mode]
   [event : Event]
   [tick-rate : TickInterval]
   [sim-speed : (U '1x '2x '4x '8x)]
   [sim-clock : Real]
   [pixels-per-meter : Integer]
   [pool : (Listof Result)] ;; in lane order
   [labels : Image] ;; corresponding to lane order
   [ranks : (Listof Integer)] ;; in lane order
   [end-time : Real]
   [file-chooser : (Optional FileChooser)]))

(define-struct Position
  ([x-position : Real]
   [direction : (U 'east 'west 'finished)]))

(: ioc-abbrevs (Listof IOC))
(define ioc-abbrevs
  (list (IOC 'AFG "Afghanistan")
        (IOC 'ALB "Albania")
        (IOC 'ALG "Algeria")
        (IOC 'AND "Andorra")
        (IOC 'ANG "Angola")
        (IOC 'ANT "Antigua Barbuda")
        (IOC 'ARG "Argentina")
        (IOC 'ARM "Armenia")
        (IOC 'ARU "Aruba")
        (IOC 'ASA "American Samoa")
        (IOC 'AUS "Australia")
        (IOC 'AUT "Austria")
        (IOC 'AZE "Azerbaijan")
        (IOC 'BAH "Bahamas")
        (IOC 'BAN "Bangladesh")
        (IOC 'BAR "Barbados")
        (IOC 'BDI "Burundi")
        (IOC 'BEL "Belgium")
        (IOC 'BEN "Benin")
        (IOC 'BER "Bermuda")
        (IOC 'BHU "Bhutan")
        (IOC 'BIH "Bosnia Herzegovina")
        (IOC 'BIZ "Belize")
        (IOC 'BLR "Belarus")
        (IOC 'BOL "Bolivia")
        (IOC 'BOT "Botswana")
        (IOC 'BRA "Brazil")
        (IOC 'BRN "Bahrain")
        (IOC 'BRU "Brunei")
        (IOC 'BUL "Bulgaria")
        (IOC 'BUR "Burkina Faso")
        (IOC 'CAF "Central African Republic")
        (IOC 'CAM "Cambodia")
        (IOC 'CAN "Canada")
        (IOC 'CAY "Cayman Islands")
        (IOC 'CGO "Congo Brazzaville")
        (IOC 'CHA "Chad")
        (IOC 'CHI "Chile")
        (IOC 'CHN "China")
        (IOC 'CIV "Cote dIvoire")
        (IOC 'CMR "Cameroon")
        (IOC 'COD "Congo Kinshasa")
        (IOC 'COK "Cook Islands")
        (IOC 'COL "Colombia")
        (IOC 'COM "Comoros")
        (IOC 'CPV "Cape Verde")
        (IOC 'CRC "Costa Rica")
        (IOC 'CRO "Croatia")
        (IOC 'CUB "Cuba")
        (IOC 'CYP "Cyprus")
        (IOC 'CZE "Czechia")
        (IOC 'DEN "Denmark")
        (IOC 'DJI "Djibouti")
        (IOC 'DMA "Dominica")
        (IOC 'DOM "Dominican Republic")
        (IOC 'ECU "Ecuador")
        (IOC 'EGY "Egypt")
        (IOC 'ERI "Eritrea")
        (IOC 'ESA "El Salvador")
        (IOC 'ESP "Spain")
        (IOC 'EST "Estonia")
        (IOC 'ETH "Ethiopia")
        (IOC 'FIJ "Fiji")
        (IOC 'FIN "Finland")
        (IOC 'FRA "France")
        (IOC 'FSM "Micronesia")
        (IOC 'GAB "Gabon")
        (IOC 'GAM "Gambia")
        (IOC 'GBR "United Kingdom")
        (IOC 'GBS "Guinea-Bissau")
        (IOC 'GEO "Georgia")
        (IOC 'GEQ "Equatorial Guinea")
        (IOC 'GER "Germany")
        (IOC 'GHA "Ghana")
        (IOC 'GRE "Greece")
        (IOC 'GRN "Grenada")
        (IOC 'GUA "Guatemala")
        (IOC 'GUI "Guinea")
        (IOC 'GUM "Guam")
        (IOC 'GUY "Guyana")
        (IOC 'HAI "Haiti")
        (IOC 'HON "Honduras")
        (IOC 'HUN "Hungary")
        (IOC 'INA "Indonesia")
        (IOC 'IND "India")
        (IOC 'IRI "Iran")
        (IOC 'IRL "Ireland")
        (IOC 'IRQ "Iraq")
        (IOC 'ISL "Iceland")
        (IOC 'ISR "Israel")
        (IOC 'ISV "US Virgin Islands")
        (IOC 'ITA "Italy")
        (IOC 'IVB "British Virgin Islands")
        (IOC 'JAM "Jamaica")
        (IOC 'JOR "Jordan")
        (IOC 'JPN "Japan")
        (IOC 'KAZ "Kazakhstan")
        (IOC 'KEN "Kenya")
        (IOC 'KGZ "Kyrgyzstan")
        (IOC 'KIR "Kiribati")
        (IOC 'KOR "South Korea")
        (IOC 'KOS "Kosovo")
        (IOC 'KSA "Saudi Arabia")
        (IOC 'KUW "Kuwait")
        (IOC 'LAO "Laos")
        (IOC 'LAT "Latvia")
        (IOC 'LBA "Libya")
        (IOC 'LBN "Lebanon")
        (IOC 'LBR "Liberia")
        (IOC 'LCA "St Lucia")
        (IOC 'LES "Lesotho")
        (IOC 'LIE "Liechtenstein")
        (IOC 'LTU "Lithuania")
        (IOC 'LUX "Luxembourg")
        (IOC 'MAD "Madagascar")
        (IOC 'MAR "Morocco")
        (IOC 'MAS "Malaysia")
        (IOC 'MAW "Malawi")
        (IOC 'MDA "Moldova")
        (IOC 'MDV "Maldives")
        (IOC 'MEX "Mexico")
        (IOC 'MGL "Mongolia")
        (IOC 'MHL "Marshall Islands")
        (IOC 'MKD "North Macedonia")
        (IOC 'MLI "Mali")
        (IOC 'MLT "Malta")
        (IOC 'MNE "Montenegro")
        (IOC 'MON "Monaco")
        (IOC 'MOZ "Mozambique")
        (IOC 'MRI "Mauritius")
        (IOC 'MTN "Mauritania")
        (IOC 'MYA "Myanmar Burma")
        (IOC 'NAM "Namibia")
        (IOC 'NCA "Nicaragua")
        (IOC 'NED "Netherlands")
        (IOC 'NEP "Nepal")
        (IOC 'NGR "Nigeria")
        (IOC 'NIG "Niger")
        (IOC 'NOR "Norway")
        (IOC 'NRU "Nauru")
        (IOC 'NZL "New Zealand")
        (IOC 'OMA "Oman")
        (IOC 'PAK "Pakistan")
        (IOC 'PAN "Panama")
        (IOC 'PAR "Paraguay")
        (IOC 'PER "Peru")
        (IOC 'PHI "Philippines")
        (IOC 'PLE "Palestinian Territories")
        (IOC 'PLW "Palau")
        (IOC 'PNG "Papua New Guinea")
        (IOC 'POL "Poland")
        (IOC 'POR "Portugal")
        (IOC 'PRK "North Korea")
        (IOC 'QAT "Qatar")
        (IOC 'ROU "Romania")
        (IOC 'RSA "South Africa")
        (IOC 'ROC "Russia")
        (IOC 'RUS "Russia")
        (IOC 'RWA "Rwanda")
        (IOC 'SAM "Samoa")
        (IOC 'SEN "Senegal")
        (IOC 'SEY "Seychelles")
        (IOC 'SGP "Singapore")
        (IOC 'SKN "St Kitts Nevis")
        (IOC 'SLE "Sierra Leone")
        (IOC 'SLO "Slovenia")
        (IOC 'SMR "San Marino")
        (IOC 'SOL "Solomon Islands")
        (IOC 'SOM "Somalia")
        (IOC 'SRB "Serbia")
        (IOC 'SRI "Sri Lanka")
        (IOC 'SSD "South Sudan")
        (IOC 'STP "Sao Tome Principe")
        (IOC 'SUD "Sudan")
        (IOC 'SUI "Switzerland")
        (IOC 'SUR "Suriname")
        (IOC 'SVK "Slovakia")
        (IOC 'SWE "Sweden")
        (IOC 'SWZ "Eswatini")
        (IOC 'SYR "Syria")
        (IOC 'TAN "Tanzania")
        (IOC 'TGA "Tonga")
        (IOC 'THA "Thailand")
        (IOC 'TJK "Tajikistan")
        (IOC 'TKM "Turkmenistan")
        (IOC 'TLS "Timor Leste")
        (IOC 'TOG "Togo")
        (IOC 'TTO "Trinidad Tobago")
        (IOC 'TUN "Tunisia")
        (IOC 'TUR "Turkey")
        (IOC 'TUV "Tuvalu")
        (IOC 'UAE "United Arab Emirates")
        (IOC 'UGA "Uganda")
        (IOC 'UKR "Ukraine")
        (IOC 'URU "Uruguay")
        (IOC 'USA "United States")
        (IOC 'UZB "Uzbekistan")
        (IOC 'VAN "Vanuatu")
        (IOC 'VEN "Venezuela")
        (IOC 'VIE "Vietnam")
        (IOC 'VIN "St Vincent Grenadines")
        (IOC 'YEM "Yemen")
        (IOC 'ZAM "Zambia")
        (IOC 'ZIM "Zimbabwe")))

;; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

(: sum : (Listof Real) -> Real)
;; computes the sum of the numbers in a list
(define (sum lst)
  (foldl + 0 lst))

(: set-mode : Mode Sim -> Sim)
;; set the mode in simulation
(define (set-mode m sim)
  (match sim
    [(Sim _ e tr ss sc ppm pool lbls rnks end fc)
     (Sim m e tr ss sc ppm pool lbls rnks end fc)]))

(: set-speed : (U '1x '2x '4x '8x) Sim -> Sim)
;; set the simulation speed
(define (set-speed ss sim)
  (match sim
    [(Sim m e tr _ sc ppm pool lbls rnks end fc)
     (Sim m e tr ss sc ppm pool lbls rnks end fc)]))

(: set-event : Event Sim -> Sim)
;; set the event in simulation
(define (set-event e sim)
  (match sim
    [(Sim m _ tr ss sc ppm pool lbls rnks end fc)
     (Sim m e tr ss sc ppm pool lbls rnks end fc)]))

(: set-pool : (Listof Result) Sim -> Sim)
;; set the pool in simulation
(define (set-pool pool sim)
  (match sim
    [(Sim m e tr ss sc ppm _ lbls rnks end fc)
     (Sim m e tr ss sc ppm pool lbls rnks end fc)]))

(: toggle-paused : Sim -> Sim)
;; set 'running sim to 'paused, and set 'paused sim to 'running
;; return 'done sim as is
(define (toggle-paused sim)
  (match (Sim-mode sim)
    ['running (set-mode 'paused sim)]
    ['paused (set-mode 'running sim)]
    [_ sim]))

(: reset : Sim -> Sim)
;; reset the simulation to the beginning of the race
(define (reset sim)
  (match sim
    [(Sim m e tr ss sc ppm pool lbls rnks end fc)
     (Sim 'running e tr ss 0 ppm pool lbls rnks end fc)]))

(: get-country-string : Country (Listof IOC) -> String)
;; finds the country string tied to the country symbol which is stored in the
;; list of ioc defined above.
(define (get-country-string c lst)
  (match lst
    ['() (error "Country not in list")]
    [(cons (IOC sym str) tail) (if (symbol=? sym c)
                                   str
                                   (get-country-string c tail))]))

(: flag-of : Country -> Image)
;; produce an image of a country's flag
;; - use bitmap/file and find the file include/flags
;; - it is OK to raise an error for a not-found file
(define (flag-of c)
  (bitmap/file
   (string-append
    "../include/flags/"
    (string-replace
     (string-downcase (get-country-string c ioc-abbrevs))
     " "
     "-")
    ".png")))

(: label : Result -> Image)
;; creates an image of a flag and a country name beside each other
(define (label res)
  (local
    {(: sw Swimmer)
     (define sw (Result-swimmer res))
     (: flag Image)
     (define flag (flag-of (Swimmer-country sw)))}
    (beside flag (text (string-append (Swimmer-fname sw) " " (Swimmer-lname sw))
                       (cast (exact-round (/ (image-height flag) 3)) Byte)
                       'black))))

(: ranks : (Listof Result) -> (Listof Integer))
;; produces a list of the ranks of the swimmers in the pool in lane order.
;; ranking system follows olympic ranking rules
(define (ranks res-lst)
  (local
    {(: index-acc : Integer (Listof Real) -> (Listof (Pairof Real Integer)))
     ;; turns a list of total race times into a list of pairs with those race
     ;; times and their index in the list, in the same order. The first input,
     ;; the previous index, is a parameter to save computation time.
     (define (index-acc n lst)
       (match lst
         ['() '()]
         [(cons swt tail) (cons (Pairof swt n) (index-acc (add1 n) tail))]))
     (: rank-acc : Real Integer Integer (Listof (Pairof Real Integer)) ->
        (Listof (Pairof Integer Integer)))
     ;; replaces the pairs of total race times and their index in the original
     ;; list with pairs of their rank and the same index, in the same order. The
     ;; first three inputs are parameters which are stored to save time in the
     ;; computation. From left to right, they are the previous total race time,
     ;; the previous rank, and the number of times the previous rank has been
     ;; given in the computation so far.
     (define (rank-acc prev-swt prev-rank repeats lst)
       (match lst
         ['() '()]
         [(cons (Pairof swt n) tail)
          (if (= prev-swt swt)
              (cons (Pairof prev-rank n)
                    (rank-acc swt prev-rank (add1 repeats) tail))
              (cons (Pairof (+ prev-rank repeats) n)
                    (rank-acc swt (+ prev-rank repeats) 1 tail)))]))}
    (map (lambda ([p : (Pairof Integer Integer)]) (Pairof-first p))
         (sort
          (rank-acc 0 0 1 (sort (index-acc 1 (map (lambda ([r : Result])
                                                    (sum (Result-splits r)))
                                                  res-lst))
                                (lambda ([a : (Pairof Real Integer)]
                                         [b : (Pairof Real Integer)])
                                  (< (Pairof-first a) (Pairof-first b)))))
          (lambda ([a : (Pairof Integer Integer)]
                   [b : (Pairof Integer Integer)])
            (< (Pairof-second a) (Pairof-second b)))))))

(: end-time : (Listof Result) -> Real)
;; finds the maximum total race time out of the list of swimmers in the pool
(define (end-time res-lst)
  (foldl max 0 (map (lambda ([r : Result]) (sum (Result-splits r))) res-lst)))

(: find-assoc : All (K V) K (Association K V) -> (Optional V))
;; given a key and an association, return the corresponding value, if there is
;; one
(define (find-assoc key assoc)
  (match assoc
    [(Association eq '()) 'None]
    [(Association eq (cons (KeyValue k v) tail))
     (if (eq key k)
         (Some v)
         (find-assoc key (Association eq tail)))]))

(: split : Char String -> (Listof String))
;; split a string around the given character
;; ex: (split #\x "abxcdxyyz") -> (list "ab" "cd" "yyz")
;; ex: (split #\, "Chicago,IL,60637") -> (list "Chicago" "IL" "60637")
;; ex: (split #\: "abcd") -> (list "abcd")
(define (split char str)
  (local
    {(: list-split-acc
        (-> (Listof (Listof Char)) (Listof Char) Char (Listof Char)
            (Listof (Listof Char))))
     ;; turns a list of characters into a list of lists of those characters,
     ;; where the original list is split along the given character. It's inputs,
     ;; from left to right, are the current list of list of characters, the
     ;; current list to be added to the list of list, the character being split
     ;; along, and the rest of the original list of characters.
     (define (list-split-acc out curr char1 lst)
       (match lst
         ['() (append out (list curr))]
         [(cons char2 tail)
          (if (char=? char1 char2)
              (match curr
                ['() (list-split-acc out '() char1 tail)]
                [curr (list-split-acc (append out (list curr)) '() char1 tail)])
              (list-split-acc out (append curr (list char2)) char1 tail))]))}
    (map list->string (list-split-acc '() '() char (string->list str)))))

(: process-line : String Sim -> Sim)
;; processes any simulation information present in a string and changes the
;; simulation accordingly
(define (process-line str sim)
  (match (split #\: str)
    [(cons "gender" (cons g '()))
     (match (Sim-event sim)
       [(Event gend dist strk name date)
        (set-event (Event (cond
                            [(string=? g "m") 'Men]
                            [(string=? g "w") 'Women]
                            [else gend]) dist strk name date) sim)])]
    [(cons "distance" (cons s '()))
     (match (Sim-event sim)
       [(Event gend _ strk name date)
        (set-event (Event gend (cast
                                (string->number s)
                                Integer) strk name date) sim)])]
    [(cons "stroke" (cons s '()))
     (match (Sim-event sim)
       [(Event gend dist strk name date)
        (set-event
         (Event gend dist (cond
                            [(string=? s "Freestyle") 'Freestyle]
                            [(string=? s "Backstroke") 'Backstroke]
                            [(string=? s "Breaststroke") 'Breaststroke]
                            [(string=? s "Butterfly") 'Butterfly]
                            [else strk]) name date) sim)])]
    [(cons "event" (cons s '()))
     (match (Sim-event sim)
       [(Event gend dist strk _ date)
        (set-event (Event gend dist strk s date) sim)])]
    [(cons "date" (cons s '()))
     (match (Sim-event sim)
       [(Event gend dist strk name _)
        (set-event
         (Event gend dist strk name
                (match (map (lambda ([x : String])
                              (cast (string->number x) Integer)) (split #\| s))
                  [(cons d (cons m (cons y '()))) (Date m d y)])) sim)])]
    [(cons "result" (cons s '()))
     (match (split #\| s)
       [(cons _ (cons lname (cons fname (cons cntry (cons h (cons splits _))))))
        (set-pool (cons (Result
                         (Swimmer lname
                                  fname
                                  (cast (string->symbol cntry) Country)
                                  (cast (string->number h) Real))
                         (map (lambda ([x : String])
                                (cast (string->number x) Real))
                              (split #\, splits)))
                        (Sim-pool sim)) sim)])]
    [_ sim]))

(: build-file-chooser : String String -> FileChooser)
;; given a suffix and a directory name, build a file chooser
;; associating the characters a, b, c, etc. with all the files
;; in the given directory that have the given suffix
;; - note: you don't need to support more than 26 files
;;         (which would exhaust the alphabet) -- consider that
;;         GIGO if it happens
(define (build-file-chooser suffix directory)
  (local
    {(: assoc-acc (-> Integer (Listof String) (Listof (KeyValue Char String))))
     (define (assoc-acc n lst)
       (match lst
         ['() '()]
         [(cons str tail)
          (cons (KeyValue (integer->char n) str) (assoc-acc (add1 n) tail))]))}
    (FileChooser
     directory
     (Association
      char=?
      (assoc-acc 97 (filter (lambda ([str : String])
                              (string=? (last (split #\. str)) suffix))
                            (map path->string (directory-list directory))))))))

(: sim-from-file : TickInterval Integer String -> Sim)
;; given a tick interval, a pixels-per-meter, and the name of an swm file,
;; build a Sim that contains the data from the file
;; - note: the Sim constructed by this function should contain 'None
;;         in the file-chooser slot
;; - note: GIGO applies to this function in all ways
(define (sim-from-file tr ppm file)
  (match (foldr process-line
                (Sim 'running (Event 'Women 0 'Freestyle "" (Date 0 0 0))
                     tr '1x 0 ppm '() empty-image '() 0 'None)
                (sort (file->lines file) string<?))
    [(Sim m e tr ss sc ppm pool lbls rnks end fc)
     (local
       {(: labels Image)
        (define labels
          (foldr (lambda ([a : Image] [b : Image])
                   (above/align "left" a b)) empty-image (map label pool)))}
       (Sim m e tr ss sc ppm pool
            (scale (/ (* 2.5 (length pool) ppm) (image-height labels)) labels)
            (ranks pool)
            (end-time pool)
            fc))]))

(: sim-from-file-fc : TickInterval Integer String (Optional FileChooser) -> Sim)
;; does the same things as sim-from-file, but makes the file chooser the
;; given file chooser instead of defaulting to 'None
(define (sim-from-file-fc tr ppm file fc)
  (match (sim-from-file tr ppm file)
    [(Sim m e tr ss sc ppm pool lbls rnks end _)
     (Sim m e tr ss sc ppm pool lbls rnks end fc)]))

(: react-to-keyboard : Sim String -> Sim)
;; set sim-speed to 1x, 2x, 4x or 8x on "1", "2", "4", or "8".
;; reset the simulation on "r"
(define (react-to-keyboard sim str)
  (match* ((Sim-mode sim) (Sim-file-chooser sim))
    [('choose (Some (FileChooser directory assoc)))
     (match (find-assoc (string-ref str 0) assoc)
       ['None sim]
       [(Some name) (sim-from-file-fc (Sim-tick-rate sim)
                                      (Sim-pixels-per-meter sim)
                                      (string-append directory "/" name)
                                      (Sim-file-chooser sim))])]
    [(_ _) (match str
             ["1" (set-speed '1x sim)]
             ["2" (set-speed '2x sim)]
             ["4" (set-speed '4x sim)]
             ["8" (set-speed '8x sim)]
             ["r" (reset sim)]
             ["d" (set-mode 'choose sim)]
             [_ sim])]))

(: react-to-tick : Sim -> Sim)
;; if simulation is 'running, increase sim-clock accordingly
;; - note: the amount of time added to sim-clock depends on
;; sim-speed and tick-rate
(define (react-to-tick sim)
  (match sim
    [(Sim m e tr ss sc ppm pool lbls rnks end fc)
     (match m
       ['running (if (< sc end)
                     (Sim 'running e tr ss (match ss
                                             ['1x (min end (+ sc tr))]
                                             ['2x (min end (+ sc (* 2 tr)))]
                                             ['4x (min end (+ sc (* 4 tr)))]
                                             ['8x (min end (+ sc (* 8 tr)))])
                          ppm pool lbls rnks end fc)
                     (set-mode 'done sim))]
       [_ sim])]))

(: react-to-mouse : Sim Integer Integer Mouse-Event -> Sim)
;; pause/unpause the simulation on "button-down"
(define (react-to-mouse sim x y event)
  (match event
    ["button-down" (toggle-paused sim)]
    [_ sim]))

(: current-position : Real Result -> Position)
;; the arguments to current-position are the current time and a result
;; - compute the given swimmer's current position, which
;;   includes a heading 'east or 'west, or 'finished
(define (current-position sc res)
  (local
    {(: splits (Listof Real))
     (define splits (Result-splits res))
     (: lwall Real)
     (define lwall (/ (Swimmer-height (Result-swimmer res)) 2))
     (: rwall Real)
     (define rwall (- 50 lwall))
     (: current-position-acc : Real Real Integer (Listof Real) -> Position)
     ;; accumulator function which finds position. Takes in the following inputs
     ;; from left to right: the sim clock, a running total of the split times in
     ;; the list (which is initialized at 0 on function call) which allows us to
     ;; circumvent computing more sums than necessary, a current lap number
     ;; (initialized at 1 on function call) which also helps circumvent extra
     ;; computation, and the list of splits.
     (define (current-position-acc sc tot lap splits)
       (match splits
         ['() (Position rwall 'finished)]
         [(cons split tail)
          (local
            {(: tot-new Real)
             (define tot-new (+ split tot))}
            (if (and (<= tot sc) (< sc tot-new))
                (if (= 1 lap)
                    (if (= 1 (length splits))
                        (Position
                         (+ lwall (* (- sc tot) (/ (- 50 (* 2 lwall)) split)))
                         'east)
                        (Position
                         (- rwall (* (- sc tot) (/ (- 50 (* 2 lwall)) split)))
                         'west))
                    (if (= 0 (modulo lap 2))
                        (Position
                         (+ lwall (* (- sc tot) (/ (- 50 (* 2 lwall)) split)))
                         'east)
                        (Position
                         (- rwall (* (- sc tot) (/ (- 50 (* 2 lwall)) split)))
                         'west)))
                (current-position-acc sc tot-new (add1 lap) tail)))]))}
    (current-position-acc sc 0 1 splits)))

(: draw-button : Byte (KeyValue Char String) -> Image)
;; draw the button for the given character key and file name which will appear
;; on the file chooser screen, where the size is determined by the first input,
;; the font-size
(define (draw-button font-size kv)
  (match kv
    [(KeyValue char str)
     (local
       {(: file-name Image)
        (define file-name (text str font-size 'black))}
       (overlay
        (overlay/offset
         (overlay (text (string-append (string char))
                        (cast (min 255 (exact-round (* 1.75 font-size))) Byte)
                        'black)
                  (circle font-size 'outline 'black)
                  (circle font-size 'solid 1st-color))
         (exact-round (* (image-width file-name) 0.55))
         0
         (overlay/align 'right 'middle
                        file-name
                        (frame (rectangle (* 1.1 (image-width file-name))
                                          (* 1.05 (image-height file-name))
                                          'solid
                                          pool-color))))
        (rectangle 1 (* 2.4 font-size) 'solid (make-color 0 0 0 0))))]))

(: draw-paused-symbol : Integer Byte -> Image)
;; draw the paused symbol based on the ppm and font size
(define (draw-paused-symbol ppm font-size)
  (overlay
   (text "Paused" (cast (min 255 (* 2 font-size)) Byte) 'black)
   (frame (rectangle (* ppm 6.5) (* ppm 1.9) 'solid paused-color))))

(: draw-medal : Integer Byte Integer -> Image)
;; draw the image of the medals based on the given pixels per meter, font
;; size, and rank
(define (draw-medal ppm font-size rank)
  (cond
    [(= rank 1) (overlay (text "1" font-size 'black)
                         (circle (* ppm 0.75) 'outline 'black)
                         (circle (* ppm 0.75) 'solid 1st-color)
                         (rectangle 1 (* ppm 2.5) 'solid (make-color 0 0 0 0)))]
    [(= rank 2) (overlay (text "2" font-size 'black)
                         (circle (* ppm 0.75) 'outline 'black)
                         (circle (* ppm 0.75) 'solid 2nd-color)
                         (rectangle 1 (* ppm 2.5) 'solid (make-color 0 0 0 0)))]
    [(= rank 3) (overlay (text "3" font-size 'white)
                         (circle (* ppm 0.75) 'outline 'black)
                         (circle (* ppm 0.75) 'solid 3rd-color)
                         (rectangle 1 (* ppm 2.5) 'solid (make-color 0 0 0 0)))]
    [else (overlay (text (number->string rank) font-size 'white)
                   (circle (* ppm 0.75) 'outline 'black)
                   (circle (* ppm 0.75) 'solid no-medal-color)
                   (rectangle 1 (* ppm 2.5) 'solid (make-color 0 0 0 0)))]))

(: draw-pool : Integer -> Image)
;; draws the image of one olympic swimming pool based on pixels per meter
(define (draw-pool ppm)
  (frame (rectangle (* ppm 50) (* ppm 2.5) 'solid pool-color)))

(: mmsshh : Real -> String)
;; display an amount of time in MM:SS.HH format
;; where HH are hundredths of seconds
;; - don't worry about hours, since races are at most
;;   a few minutes long
;; - *do* append a trailing zero as needed
;; ex: (mmsshh 62.23) -> "1:02.23"
;; ex: (mmsshh 62.2)  -> "1:02.20"
(define (mmsshh r)
  (local
    {(: m Integer)
     (define m (exact-floor (/ r 60)))
     (: s Integer)
     (define s (exact-floor (- r (* 60 m))))
     (: h Integer)
     (define h (exact-floor (* 100 (- r (* 60 m) s))))}
    (string-append (cond
                     [(= m 0) "00"]
                     [(< m 10) (string-append "0" (number->string m))]
                     [else (number->string m)])
                   ":"
                   (cond
                     [(= s 0) "00"]
                     [(< s 10) (string-append "0" (number->string s))]
                     [else (number->string s)])
                   "."
                   (cond
                     [(= h 0) "00"]
                     [(< h 10) (string-append "0" (number->string h))]
                     [else (number->string h)]))))

(: draw-lane : Integer Real Byte Result -> Image)
;; draw the pool and the swimmer in their current position. The inputs, from
;; left to right, are the pixels per meter, sim clock, font size, and a result.
(define (draw-lane ppm sc font-size res)
  (local
    {(: h Real)
     (define h (Swimmer-height (Result-swimmer res)))
     (: pool Image)
     (define pool (draw-pool ppm))}
    (match (current-position sc res)
      [(Position pos dir)
       (match dir
         ['finished
          (overlay/align
           "right"
           "middle"
           (overlay (text (mmsshh (sum (Result-splits res))) font-size 'black)
                    (frame (rectangle (* ppm 4) (* ppm 2) 'solid 'white)))
           pool)]
         ['west (place-image
                 (overlay
                  (rotate 90 (triangle (* ppm (/ h 6)) 'solid 'black))
                  (rectangle (* ppm h) (* ppm (/ h 4)) 'solid swimmer-color))
                 (* ppm pos)
                 (* ppm 1.25)
                 pool)]
         ['east (place-image
                 (overlay
                  (rotate 270 (triangle (* ppm (/ h 6)) 'solid 'black))
                  (rectangle (* ppm h) (* ppm (/ h 4)) 'solid swimmer-color))
                 (* ppm pos)
                 (* ppm 1.25)
                 pool)])])))

(: draw-simulation : Sim -> Image)
;; draw the simulation in its current state, including both graphical and
;; textual elements
(define (draw-simulation sim)
  (match sim
    [(Sim m (Event gend dist strk name (Date mnth day yr))
          _ ss sc ppm pool lbls rnks end fc)
     (if (symbol=? m 'choose)
         (local
           {(: font-size Byte)
            (define font-size
              (cast (min 255 (exact-round (* ppm 27/20))) Byte))}
           (match fc
             [(Some (FileChooser directory assoc))
              (overlay/align
               'left 'top
               (above/align
                'left
                (text (string-append "Current Directory: " directory)
                      font-size
                      'black)
                (foldr (lambda ([i1 : Image] [i2 : Image])
                         (above/align 'left i1 i2))
                       empty-image
                       (map (lambda ([kv : (KeyValue Char String)])
                              (draw-button font-size kv))
                            (Association-data assoc)))
                (text "Press a letter key to run its associated simulation"
                      font-size
                      'black))
               (rectangle (max 0 (* ppm 75))
                          (max 0 (* ppm 37.5))
                          'solid
                          (make-color 0 0 0 0)))]))
         (local
           {(: font-size Byte)
            (define font-size (cast (min 255 (exact-round (* ppm 18/20))) Byte))
            (: empty-lane Image)
            (define empty-lane (draw-pool ppm))}
           (above/align
            'left
            (beside (overlay
                     (match m
                       ['paused (draw-paused-symbol ppm font-size)]
                       ['done (foldr
                               above
                               empty-image
                               (map (lambda ([i : Integer])
                                      (draw-medal ppm font-size i)) rnks))]
                       [_ empty-image])
                     (above empty-lane
                            (foldr above empty-lane
                                   (map (lambda ([r : Result])
                                          (draw-lane ppm sc font-size r))
                                        pool))))
                    lbls)
            (text (string-append name
                                 ": "
                                 (symbol->string gend)
                                 "'s "
                                 (number->string dist)
                                 "m "
                                 (symbol->string strk)
                                 " ("
                                 (number->string mnth)
                                 "/"
                                 (number->string day)
                                 "/"
                                 (number->string yr)
                                 ")") font-size 'black)
            (text (string-append "Time elapsed: " (mmsshh sc)) font-size 'black)
            (text (match ss
                    ['1x "Playback speed: 1x"]
                    ['2x "Playback speed: 2x"]
                    ['4x "Playback speed: 4x"]
                    [_ "Playback speed: 8x"]) font-size 'black))))]))

(: run : TickInterval Integer String -> Sim)
;; the run function should consume a tick interval, a pixels per meter,
;; and a path to a directory containing one or more .swm files
(define (run tr ppm directory)
  (big-bang
      (Sim 'choose (Event 'Women 0 'Freestyle "" (Date 0 0 0)) tr '1x 0 ppm '()
           empty-image '() 0 (Some (build-file-chooser "swm" directory))) : Sim
    [to-draw draw-simulation]
    [on-key react-to-keyboard]
    [on-mouse react-to-mouse]
    [on-tick react-to-tick]))