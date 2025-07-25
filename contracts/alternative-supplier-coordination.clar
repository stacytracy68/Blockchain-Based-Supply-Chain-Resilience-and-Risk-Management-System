;; Alternative Supplier Coordination Contract
;; Maintains backup suppliers to prevent disruption during crises

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-INVALID-INPUT (err u201))
(define-constant ERR-NOT-FOUND (err u202))
(define-constant ERR-ALREADY-EXISTS (err u203))
(define-constant ERR-INSUFFICIENT-CAPACITY (err u204))

;; Data Variables
(define-data-var contract-active bool true)
(define-data-var next-supplier-id uint u1)
(define-data-var next-coordination-id uint u1)

;; Data Maps
(define-map suppliers
  { supplier-id: uint }
  {
    name: (string-ascii 100),
    location: (string-ascii 50),
    contact-info: (string-ascii 200),
    status: (string-ascii 20),
    tier: uint,
    registration-date: uint,
    is-backup: bool
  }
)

(define-map supplier-capabilities
  { supplier-id: uint, product-id: uint }
  {
    capacity: uint,
    available-capacity: uint,
    lead-time: uint,
    cost-per-unit: uint,
    quality-rating: uint,
    last-updated: uint
  }
)

(define-map supplier-relationships
  { primary-supplier-id: uint, product-id: uint }
  {
    backup-suppliers: (list 10 uint),
    active-backup: (optional uint),
    switch-date: (optional uint),
    switch-reason: (optional (string-ascii 100))
  }
)

(define-map coordination-events
  { coordination-id: uint }
  {
    event-type: (string-ascii 30),
    primary-supplier: uint,
    backup-supplier: uint,
    product-id: uint,
    quantity: uint,
    event-date: uint,
    coordinator: principal,
    status: (string-ascii 20)
  }
)

(define-map authorized-coordinators
  { coordinator: principal }
  { authorized: bool }
)

;; Authorization Functions
(define-private (is-contract-owner)
  (is-eq tx-sender CONTRACT-OWNER)
)

(define-private (is-authorized-coordinator)
  (default-to false (get authorized (map-get? authorized-coordinators { coordinator: tx-sender })))
)

(define-private (is-authorized)
  (or (is-contract-owner) (is-authorized-coordinator))
)

;; Administrative Functions
(define-public (authorize-coordinator (coordinator principal))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-coordinators { coordinator: coordinator } { authorized: true }))
  )
)

(define-public (revoke-coordinator (coordinator principal))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-coordinators { coordinator: coordinator } { authorized: false }))
  )
)

;; Supplier Management Functions
(define-public (register-supplier
  (name (string-ascii 100))
  (location (string-ascii 50))
  (contact-info (string-ascii 200))
  (tier uint)
  (is-backup bool)
)
  (let
    (
      (supplier-id (var-get next-supplier-id))
    )
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)
    (asserts! (var-get contract-active) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> tier u0) ERR-INVALID-INPUT)
    (asserts! (<= tier u3) ERR-INVALID-INPUT)

    (map-set suppliers
      { supplier-id: supplier-id }
      {
        name: name,
        location: location,
        contact-info: contact-info,
        status: "active",
        tier: tier,
        registration-date: block-height,
        is-backup: is-backup
      }
    )

    (var-set next-supplier-id (+ supplier-id u1))
    (ok supplier-id)
  )
)

(define-public (add-supplier-capability
  (supplier-id uint)
  (product-id uint)
  (capacity uint)
  (lead-time uint)
  (cost-per-unit uint)
  (quality-rating uint)
)
  (begin
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)
    (asserts! (var-get contract-active) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? suppliers { supplier-id: supplier-id })) ERR-NOT-FOUND)
    (asserts! (> capacity u0) ERR-INVALID-INPUT)
    (asserts! (<= quality-rating u100) ERR-INVALID-INPUT)

    (ok (map-set supplier-capabilities
      { supplier-id: supplier-id, product-id: product-id }
      {
        capacity: capacity,
        available-capacity: capacity,
        lead-time: lead-time,
        cost-per-unit: cost-per-unit,
        quality-rating: quality-rating,
        last-updated: block-height
      }
    ))
  )
)

(define-public (establish-backup-relationship
  (primary-supplier-id uint)
  (product-id uint)
  (backup-supplier-ids (list 10 uint))
)
  (begin
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)
    (asserts! (var-get contract-active) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? suppliers { supplier-id: primary-supplier-id })) ERR-NOT-FOUND)
    (asserts! (> (len backup-supplier-ids) u0) ERR-INVALID-INPUT)

    (ok (map-set supplier-relationships
      { primary-supplier-id: primary-supplier-id, product-id: product-id }
      {
        backup-suppliers: backup-supplier-ids,
        active-backup: none,
        switch-date: none,
        switch-reason: none
      }
    ))
  )
)

;; Coordination Functions
(define-public (activate-backup-supplier
  (primary-supplier-id uint)
  (product-id uint)
  (backup-supplier-id uint)
  (quantity uint)
  (reason (string-ascii 100))
)
  (let
    (
      (coordination-id (var-get next-coordination-id))
      (relationship (map-get? supplier-relationships { primary-supplier-id: primary-supplier-id, product-id: product-id }))
      (backup-capability (map-get? supplier-capabilities { supplier-id: backup-supplier-id, product-id: product-id }))
    )
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)
    (asserts! (var-get contract-active) ERR-NOT-AUTHORIZED)
    (asserts! (is-some relationship) ERR-NOT-FOUND)
    (asserts! (is-some backup-capability) ERR-NOT-FOUND)
    (asserts! (> quantity u0) ERR-INVALID-INPUT)

    ;; Check if backup supplier has sufficient capacity
    (asserts! (>= (get available-capacity (unwrap-panic backup-capability)) quantity) ERR-INSUFFICIENT-CAPACITY)

    ;; Update supplier relationship
    (map-set supplier-relationships
      { primary-supplier-id: primary-supplier-id, product-id: product-id }
      (merge (unwrap-panic relationship) {
        active-backup: (some backup-supplier-id),
        switch-date: (some block-height),
        switch-reason: (some reason)
      })
    )

    ;; Update backup supplier capacity
    (map-set supplier-capabilities
      { supplier-id: backup-supplier-id, product-id: product-id }
      (merge (unwrap-panic backup-capability) {
        available-capacity: (- (get available-capacity (unwrap-panic backup-capability)) quantity)
      })
    )

    ;; Record coordination event
    (map-set coordination-events
      { coordination-id: coordination-id }
      {
        event-type: "backup-activation",
        primary-supplier: primary-supplier-id,
        backup-supplier: backup-supplier-id,
        product-id: product-id,
        quantity: quantity,
        event-date: block-height,
        coordinator: tx-sender,
        status: "active"
      }
    )

    (var-set next-coordination-id (+ coordination-id u1))
    (ok coordination-id)
  )
)

(define-public (deactivate-backup-supplier
  (primary-supplier-id uint)
  (product-id uint)
  (quantity uint)
)
  (let
    (
      (coordination-id (var-get next-coordination-id))
      (relationship (map-get? supplier-relationships { primary-supplier-id: primary-supplier-id, product-id: product-id }))
      (active-backup-id (match relationship rel (get active-backup rel) none))
    )
    (asserts! (is-authorized) ERR-NOT-AUTHORIZED)
    (asserts! (var-get contract-active) ERR-NOT-AUTHORIZED)
    (asserts! (is-some relationship) ERR-NOT-FOUND)
    (asserts! (is-some active-backup-id) ERR-NOT-FOUND)
    (asserts! (> quantity u0) ERR-INVALID-INPUT)

    ;; Update supplier relationship
    (map-set supplier-relationships
      { primary-supplier-id: primary-supplier-id, product-id: product-id }
      (merge (unwrap-panic relationship) {
        active-backup: none,
        switch-date: none,
        switch-reason: none
      })
    )

    ;; Restore backup supplier capacity
    (let
      (
        (backup-supplier-id (unwrap-panic active-backup-id))
        (backup-capability (unwrap-panic (map-get? supplier-capabilities { supplier-id: backup-supplier-id, product-id: product-id })))
      )
      (map-set supplier-capabilities
        { supplier-id: backup-supplier-id, product-id: product-id }
        (merge backup-capability {
          available-capacity: (+ (get available-capacity backup-capability) quantity)
        })
      )
    )

    ;; Record coordination event
    (map-set coordination-events
      { coordination-id: coordination-id }
      {
        event-type: "backup-deactivation",
        primary-supplier: primary-supplier-id,
        backup-supplier: (unwrap-panic active-backup-id),
        product-id: product-id,
        quantity: quantity,
        event-date: block-height,
        coordinator: tx-sender,
        status: "completed"
      }
    )

    (var-set next-coordination-id (+ coordination-id u1))
    (ok coordination-id)
  )
)

;; Query Functions
(define-read-only (get-supplier (supplier-id uint))
  (map-get? suppliers { supplier-id: supplier-id })
)

(define-read-only (get-supplier-capability (supplier-id uint) (product-id uint))
  (map-get? supplier-capabilities { supplier-id: supplier-id, product-id: product-id })
)

(define-read-only (get-supplier-relationship (primary-supplier-id uint) (product-id uint))
  (map-get? supplier-relationships { primary-supplier-id: primary-supplier-id, product-id: product-id })
)

(define-read-only (get-coordination-event (coordination-id uint))
  (map-get? coordination-events { coordination-id: coordination-id })
)

(define-read-only (get-available-backup-suppliers (primary-supplier-id uint) (product-id uint))
  (match (map-get? supplier-relationships { primary-supplier-id: primary-supplier-id, product-id: product-id })
    relationship (ok (get backup-suppliers relationship))
    ERR-NOT-FOUND
  )
)

;; Emergency Functions
(define-public (pause-contract)
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (var-set contract-active false)
    (ok true)
  )
)

(define-public (resume-contract)
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (var-set contract-active true)
    (ok true)
  )
)

;; Utility Functions
(define-read-only (get-contract-info)
  {
    active: (var-get contract-active),
    next-supplier-id: (var-get next-supplier-id),
    next-coordination-id: (var-get next-coordination-id),
    owner: CONTRACT-OWNER
  }
)
