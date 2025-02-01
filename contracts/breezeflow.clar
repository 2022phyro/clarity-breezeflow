;; BreezeFlow Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-weather (err u101))
(define-constant err-invalid-rating (err u102))

;; Data Variables
(define-map WeatherData
  { location: (string-ascii 64) }
  {
    temperature: int,
    humidity: uint,
    wind-speed: uint,
    timestamp: uint
  }
)

(define-map ActivityRecommendations
  { weather-condition: (string-ascii 32) }
  { activities: (list 10 (string-ascii 64)) }
)

(define-map UserRatings
  { user: principal, activity: (string-ascii 64) }
  { rating: uint }
)

;; Public Functions
(define-public (submit-weather-data (location (string-ascii 64)) 
                                  (temperature int)
                                  (humidity uint)
                                  (wind-speed uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set WeatherData
      { location: location }
      {
        temperature: temperature,
        humidity: humidity,
        wind-speed: wind-speed,
        timestamp: block-height
      }
    ))
  )
)

(define-public (add-activity-recommendation 
  (weather-condition (string-ascii 32))
  (activities (list 10 (string-ascii 64))))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set ActivityRecommendations
      { weather-condition: weather-condition }
      { activities: activities }
    ))
  )
)

(define-public (submit-rating 
  (activity (string-ascii 64))
  (rating uint))
  (begin
    (asserts! (<= rating u5) err-invalid-rating)
    (ok (map-set UserRatings
      { user: tx-sender, activity: activity }
      { rating: rating }
    ))
  )
)

;; Read Only Functions
(define-read-only (get-weather-data (location (string-ascii 64)))
  (map-get? WeatherData { location: location })
)

(define-read-only (get-recommendations (weather-condition (string-ascii 32)))
  (map-get? ActivityRecommendations { weather-condition: weather-condition })
)

(define-read-only (get-user-rating (user principal) (activity (string-ascii 64)))
  (map-get? UserRatings { user: user, activity: activity })
)
