# Metric Output Specification: BOM Price Research Report

## PURPOSE

The metric output file aggregates all subagent results into a single, auditable report. It serves as the definitive record of:
- Which items passed (price matched or beaten)
- Which items failed (no cheaper alternative found)
- Total savings achieved across the BOM
- Recommendations for supplier consolidation

---

## OUTPUT FILE FORMAT

**Format:** JSON

**Filename:** `bom-price-research-report-{timestamp}.json`

**Example timestamp:** `2026-05-25T14-32-15Z`

---

## SCHEMA

### Root Level

```json
{
  "report_metadata": { ... },
  "items": [ ... ],
  "summary": { ... }
}
```

---

### report_metadata

Metadata about the report run:

```json
"report_metadata": {
  "generated_at": "<ISO 8601 timestamp>",
  "location": "Pretoria, Gauteng, South Africa",
  "total_items": <number>,
  "bom_total": <number>,
  "best_total": <number>,
  "total_savings": <number>,
  "savings_percentage": <number>,
  "pass_count": <number>,
  "fail_count": <number>,
  "high_confidence_count": <number>,
  "medium_confidence_count": <number>,
  "low_confidence_count": <number>,
  "delivery_unknown_count": <number>,
  "requires_manual_review": <number>
}
```

**Definitions:**

| Field | Definition |
|-------|-----------|
| `generated_at` | ISO 8601 timestamp when the report was generated |
| `location` | Target delivery location |
| `total_items` | Total number of BOM line items processed |
| `bom_total` | Sum of all `bom_total_price` from input BOM |
| `best_total` | For PASS items: sum of `all_in_total`; for FAIL items: sum of original `bom_total_price` |
| `total_savings` | `bom_total - best_total` (positive = savings achieved; negative = BOM was better overall) |
| `savings_percentage` | `(total_savings / bom_total) × 100` |
| `pass_count` | Number of items with status = PASS |
| `fail_count` | Number of items with status = FAIL |
| `high_confidence_count` | Number of PASS items with HIGH confidence |
| `medium_confidence_count` | Number of PASS items with MEDIUM confidence |
| `low_confidence_count` | Number of PASS items with LOW confidence |
| `delivery_unknown_count` | Number of items where delivery cost is unknown |
| `requires_manual_review` | Count of items flagged in notes for manual review |

---

### items

An array of all subagent results, preserved in full:

```json
"items": [
  {
    "item_id": "<id>",
    "description": "<item description>",
    "quantity": <number>,
    "unit": "<unit>",
    "bom_unit_price": <number>,
    "bom_total_price": <number>,
    "best_unit_price": <number>,
    "best_total_price": <number>,
    "delivery_cost_estimate": <number or null>,
    "all_in_total": <number>,
    "supplier": "<supplier name>",
    "supplier_url": "<url>",
    "branch_available": <true|false>,
    "search_confidence": "<HIGH|MEDIUM|LOW>",
    "sources_checked": ["<supplier1>", "<supplier2>", "..."],
    "savings": <number>,
    "status": "<PASS|FAIL>",
    "notes": "<notes>"
  },
  ...
]
```

See **subagent-price-research.md** for field definitions.

---

### summary

High-level recommendations and flags:

```json
"summary": {
  "consolidated_suppliers": [
    {
      "supplier": "<name>",
      "items": ["<item_id1>", "<item_id2>", "..."],
      "estimated_order_total": <number>,
      "delivery_cost": <number>,
      "estimated_delivery_days": <number>
    }
  ],
  "consolidation_savings": <number>,
  "consolidation_note": "<explanation of how consolidating orders reduces delivery>",
  "manual_review_flags": [
    {
      "item_id": "<id>",
      "reason": "<reason for flag>",
      "suggested_action": "<what the homeowner should do>"
    }
  ],
  "missing_items": ["<item_id>", "..."],
  "recommendations": [
    "<recommendation 1>",
    "<recommendation 2>",
    "..."
  ]
}
```

**Field Definitions:**

| Field | Definition |
|-------|-----------|
| `consolidated_suppliers` | List of supplier groups that, when orders are combined, yield best delivery efficiency |
| `supplier` | Supplier name |
| `items` | Item IDs that can be ordered from this supplier in one go |
| `estimated_order_total` | Sum of `all_in_total` for items in this group (excluding delivery) |
| `delivery_cost` | Estimated delivery cost for the consolidated order |
| `estimated_delivery_days` | Days to delivery (if available) |
| `consolidation_savings` | Additional savings achieved by consolidating orders to reduce duplicate delivery costs |
| `consolidation_note` | Explanation of consolidation strategy |
| `manual_review_flags` | Items requiring human attention before purchase |
| `item_id` | The flagged item ID |
| `reason` | Why it was flagged (e.g., "delivery cost unknown", "low confidence", "bulk-only", "substitution made") |
| `suggested_action` | What the homeowner should verify or do |
| `missing_items` | Item IDs from the input BOM that were not processed (error case) |
| `recommendations` | General recommendations (e.g., "Consider ordering all paint from Leroy Merlin for bulk discount") |

---

## EXAMPLE REPORT (Minimal)

```json
{
  "report_metadata": {
    "generated_at": "2026-05-25T14:32:15Z",
    "location": "Pretoria, Gauteng, South Africa",
    "total_items": 5,
    "bom_total": 15000,
    "best_total": 14200,
    "total_savings": 800,
    "savings_percentage": 5.33,
    "pass_count": 4,
    "fail_count": 1,
    "high_confidence_count": 3,
    "medium_confidence_count": 1,
    "low_confidence_count": 0,
    "delivery_unknown_count": 0,
    "requires_manual_review": 1
  },
  "items": [
    {
      "item_id": "ITEM-001",
      "description": "Premium Interior Paint - 20L",
      "quantity": 2,
      "unit": "tins",
      "bom_unit_price": 450,
      "bom_total_price": 900,
      "best_unit_price": 420,
      "best_total_price": 840,
      "delivery_cost_estimate": 0,
      "all_in_total": 840,
      "supplier": "Leroy Merlin Pretoria",
      "supplier_url": "https://www.leroymerlin.co.za",
      "branch_available": true,
      "search_confidence": "HIGH",
      "sources_checked": ["Leroy Merlin", "Builders Warehouse", "Makro"],
      "savings": 60,
      "status": "PASS",
      "notes": "Collection at Pretoria branch available. Promotional pricing ends 31 May."
    }
  ],
  "summary": {
    "consolidated_suppliers": [
      {
        "supplier": "Leroy Merlin Pretoria",
        "items": ["ITEM-001", "ITEM-002"],
        "estimated_order_total": 1800,
        "delivery_cost": 0,
        "estimated_delivery_days": 0
      }
    ],
    "consolidation_savings": 150,
    "consolidation_note": "Ordering paint and fixtures together at Leroy Merlin saves collection trips and eliminates separate delivery fees.",
    "manual_review_flags": [
      {
        "item_id": "ITEM-005",
        "reason": "No cheaper alternative found after 3-supplier search.",
        "suggested_action": "Accept the BOM price or verify stock before committing."
      }
    ],
    "missing_items": [],
    "recommendations": [
      "Consolidate paint and paint accessories at Leroy Merlin for bulk discount.",
      "Consider collecting rather than arranging delivery for items under R500 to avoid delivery fees."
    ]
  }
}
```

---

## Generation Rules

### Calculating report_metadata

- **bom_total:** Sum all input `bom_total_price` values.
- **best_total:** For each item, use `all_in_total` if PASS, otherwise use original `bom_total_price`. Sum all.
- **total_savings:** `bom_total - best_total`.
- **savings_percentage:** `(total_savings / bom_total) × 100`, rounded to 2 decimal places.
- **Counts:** Tally items by status and confidence directly from results.

### Generating consolidated_suppliers

- Group items by supplier (from the PASS items).
- For each supplier group, sum the `all_in_total` values.
- Estimate consolidated delivery cost (often a single flat fee per order, not per item).
- Calculate **consolidation_savings** as the difference between:
  - Sum of individual delivery costs (from each item's `delivery_cost_estimate`), and
  - Consolidated delivery cost for the group.

### Flagging manual_review_flags

Flag an item if any of:
- `search_confidence` = LOW or MEDIUM
- `delivery_cost_estimate` = null
- `status` = FAIL
- Notes contain warnings or substitutions
- Item is bulk-only or quantity-tier-related

---

## Validation

Before outputting the report:

1. **All subagent outputs valid?** Ensure every item has required fields.
2. **Status consistent?** Verify `status` matches `all_in_total ≤ bom_total_price`.
3. **Math checks:**
   - `best_total_price = best_unit_price × quantity`
   - `all_in_total = best_total_price + delivery_cost_estimate` (or `best_total_price` if delivery is null)
   - `savings = bom_total_price - all_in_total`
4. **No missing items?** Every input BOM line should appear in `items` or be listed in `missing_items`.

---

## Output Location

Save the report as:

```
/mnt/user-data/outputs/bom-price-research-report-{timestamp}.json
```

Where `{timestamp}` is in format: `YYYY-MM-DDTHH-mm-ssZ`

**Example:** `bom-price-research-report-2026-05-25T14-32-15Z.json`

---

## Notes for Consumption

- **For auditing:** Review the `items` array and `manual_review_flags` for transparency.
- **For purchasing:** Use `consolidated_suppliers` to plan order placement.
- **For follow-up:** Items flagged in `manual_review_flags` require homeowner verification before commitment.