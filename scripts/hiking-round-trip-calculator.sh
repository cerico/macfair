#!/usr/bin/env bash
#
# Hiking Round Trip Calculator
#
# Estimates round-trip hiking time using Naismith's Rule:
#   - 1 hour per 3 miles of horizontal distance
#   - 1 hour per 2,000 ft of elevation gain
# Descent is estimated at 60% of ascent time for the elevation component.
#
# Usage: ./hiking-round-trip-calculator.sh <elevation_ft> [trail_distance_miles]
#
# If trail distance is not provided, it is estimated from elevation gain
# using a typical trail grade of ~15% (moderate hiking trail).

set -euo pipefail

usage() {
    echo "Usage: $0 <elevation_gain_ft> [one_way_trail_distance_miles]"
    echo ""
    echo "Estimates round-trip hiking time for a peak."
    echo ""
    echo "Arguments:"
    echo "  elevation_gain_ft              Elevation gain to the summit in feet"
    echo "  one_way_trail_distance_miles   One-way trail distance in miles (optional)"
    echo ""
    echo "If trail distance is omitted, it is estimated from elevation"
    echo "assuming a moderate trail grade (~15%)."
    echo ""
    echo "Examples:"
    echo "  $0 3000"
    echo "  $0 3000 5"
    exit 1
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
    usage
fi

ELEVATION_FT="$1"

if ! [[ "$ELEVATION_FT" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: elevation_gain_ft must be a positive number" >&2
    exit 1
fi

if [[ $# -eq 2 ]]; then
    TRAIL_MILES="$2"
    if ! [[ "$TRAIL_MILES" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: trail_distance_miles must be a positive number" >&2
        exit 1
    fi
else
    # Estimate trail distance from elevation assuming ~15% average grade
    # grade = elevation / horizontal_distance => horiz = elev / 0.15
    # Convert feet to miles (5280 ft/mile)
    TRAIL_MILES=$(awk "BEGIN { printf \"%.1f\", ($ELEVATION_FT / 0.15) / 5280 }")
fi

# Naismith's Rule calculations
ASCENT_TIME_DISTANCE=$(awk "BEGIN { printf \"%.2f\", $TRAIL_MILES / 3 }")
ASCENT_TIME_ELEVATION=$(awk "BEGIN { printf \"%.2f\", $ELEVATION_FT / 2000 }")
ASCENT_TOTAL=$(awk "BEGIN { printf \"%.2f\", $ASCENT_TIME_DISTANCE + $ASCENT_TIME_ELEVATION }")

# Descent: same distance time, but elevation component is ~60% of ascent
DESCENT_TIME_DISTANCE="$ASCENT_TIME_DISTANCE"
DESCENT_TIME_ELEVATION=$(awk "BEGIN { printf \"%.2f\", $ASCENT_TIME_ELEVATION * 0.6 }")
DESCENT_TOTAL=$(awk "BEGIN { printf \"%.2f\", $DESCENT_TIME_DISTANCE + $DESCENT_TIME_ELEVATION }")

ROUND_TRIP=$(awk "BEGIN { printf \"%.2f\", $ASCENT_TOTAL + $DESCENT_TOTAL }")

# Convert to hours and minutes
ROUND_TRIP_HRS=$(awk "BEGIN { printf \"%d\", int($ROUND_TRIP) }")
ROUND_TRIP_MIN=$(awk "BEGIN { printf \"%d\", ($ROUND_TRIP - int($ROUND_TRIP)) * 60 }")

echo "========================================="
echo "  Hiking Round Trip Calculator"
echo "========================================="
echo ""
echo "  Elevation gain:    ${ELEVATION_FT} ft"
echo "  Trail distance:    ${TRAIL_MILES} mi (one way)"
echo ""
echo "  --- Ascent ---"
echo "  Distance time:     ${ASCENT_TIME_DISTANCE} hrs"
echo "  Elevation time:    ${ASCENT_TIME_ELEVATION} hrs"
echo "  Ascent total:      ${ASCENT_TOTAL} hrs"
echo ""
echo "  --- Descent ---"
echo "  Distance time:     ${DESCENT_TIME_DISTANCE} hrs"
echo "  Elevation time:    ${DESCENT_TIME_ELEVATION} hrs"
echo "  Descent total:     ${DESCENT_TOTAL} hrs"
echo ""
echo "  --- Round Trip ---"
echo "  Estimated time:    ${ROUND_TRIP_HRS}h ${ROUND_TRIP_MIN}m (${ROUND_TRIP} hrs)"
echo ""
echo "  Note: Add 10-20% for breaks, water, photos, etc."
echo "========================================="
