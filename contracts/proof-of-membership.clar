;; ----------------------------------------------------------------------------------
;; Contract: proof-of-membership.clar
;; 
;; Description: Soulbound Membership NFT. Non-transferable tokens representing membership.
;; ----------------------------------------------------------------------------------



;; --- Constants ---
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-TRANSFER-BLOCKED (err u101))
(define-constant ERR-MEMBER-NOT-FOUND (err u102))

;; --- Data Vars ---
(define-data-var last-token-id uint u0)
(define-data-var contract-owner principal tx-sender)

;; --- Token Definition ---
(define-non-fungible-token membership-nft uint)

;; --- Maps ---
;; token-id => { username: (string-ascii 32), role: (string-ascii 32), joined-at: uint }
(define-map member-metadata
  uint
  { username: (string-ascii 32), role: (string-ascii 32), joined-at: uint }
)

;; ------------------------------------------------------------------------------
;; Mint membership NFT to a user (owner-only)
;; ------------------------------------------------------------------------------
(define-public (mint-membership (recipient principal) (username (string-ascii 32)) (role (string-ascii 32)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)

    (let ((next-id (+ u1 (var-get last-token-id))))
      ;; Mint NFT to recipient
      (try! (nft-mint? membership-nft next-id recipient))

      ;; Store member metadata
      (map-set member-metadata next-id {
        username: username,
        role: role,
        joined-at: stacks-block-height
      })

      ;; Update last token ID
      (var-set last-token-id next-id)

      ;; Log event
      (print {
        action: "mint-membership",
        to: recipient,
        token-id: next-id,
        username: username,
        role: role
      })

      (ok next-id)
    )
  )
)

;; ------------------------------------------------------------------------------
;; Disable transfer - permanently block transfers to make token soulbound
;; ------------------------------------------------------------------------------
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    ;; Only token owner can call transfer
    (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)

    ;; Transfers are blocked
    ERR-TRANSFER-BLOCKED
  )
)

;; ------------------------------------------------------------------------------
;; Read-only: Get metadata for a membership token
;; ------------------------------------------------------------------------------
(define-read-only (get-member-details (token-id uint))
  (match (map-get? member-metadata token-id)
    details (ok details)
    ERR-MEMBER-NOT-FOUND
  )
)

;; ------------------------------------------------------------------------------
;; Read-only: Get owner of membership token
;; ------------------------------------------------------------------------------
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? membership-nft token-id))
)

;; ------------------------------------------------------------------------------
;; Read-only: Get last minted token id
;; ------------------------------------------------------------------------------
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

