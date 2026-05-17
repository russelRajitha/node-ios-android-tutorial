#!/usr/bin/env bash
set -euo pipefail
RESULT_PATH="${1:-}"
THRESHOLD=80
if [[ -z "$RESULT_PATH" ]]; then
  echo "Usage: $0 <path-to.xcresult>"
  exit 1
fi

GATED_FILES=(
  "CartViewModel.swift"
  "CategoryProductsViewModel.swift"
  "LoginViewModel.swift"
  "MainViewModel.swift"
  "NotificationsViewModel.swift"
  "OrderDetailViewModel.swift"
  "OrdersViewModel.swift"
  "ProductDetailViewModel.swift"
  "ProfileViewModel.swift"
  "ShopViewModel.swift"
  "NotificationRepository.swift"
  "OrderRepository.swift"
  "ProductCategoryRepository.swift"
  "ProductRepository.swift"
  "ProfileRepository.swift"
)

JSON=$(xcrun xccov view --report --json "$RESULT_PATH" 2>/dev/null)

failed=0
printf "%-45s %s\n" "File" "Coverage"
printf "%s\n" "$(printf '%.0s-' {1..55})"

for filename in "${GATED_FILES[@]}"; do
  pct=$(echo "$JSON" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for target in data.get('targets', []):
    for f in target.get('files', []):
        if f.get('name', '') == '${filename}':
            print(f\"{f['lineCoverage'] * 100:.1f}\")
            sys.exit(0)
print('0.0')
")

  int_pct=${pct%.*}
  if (( int_pct >= THRESHOLD )); then
    status="✓"
  else
    status="✗  BELOW ${THRESHOLD}%"
    failed=1
  fi

  printf "%-45s %5s%%  %s\n" "$filename" "$pct" "$status"
done

printf "%s\n" "$(printf '%.0s-' {1..55})"

if (( failed )); then
  echo ""
  echo "FAILED: One or more files are below the ${THRESHOLD}% coverage threshold."
  exit 1
else
  echo ""
  echo "PASSED: All gated files meet the ${THRESHOLD}% coverage threshold."
  exit 0
fi
