#!/bin/bash
ETH="Ξ"
BTC="฿"

PREV=0
PRICE=0
UPCOLOR="#2ECC71"
DOWNCOLOR="#EF4836"

YDAY=$(date -d "yesterday 13:00" '+%Y-%m-%d')

if [[ "$#" == "0" || "$1" == "eth" ]]; then
  LOGO=$ETH
  RESULT=$(curl -s https://api.coinbase.com/v2/prices/ETH-USD/spot)
  PREV=$(  curl -s https://api.coinbase.com/v2/prices/ETH-USD/spot?date=$YDAY)

elif [[ "$1" == "btc" ]]; then
  LOGO=$BTC
  RESULT=$(curl -s https://api.coinbase.com/v2/prices/BTC-USD/spot)
  PREV=$(  curl -s https://api.coinbase.com/v2/prices/BTC-USD/spot?date=$YDAY)
fi

# Show nothing if the API call fails (probably no internet)
if [[ $? -ne 0 ]]; then
  echo ""
  echo ""
  echo "#FF0000"
  exit 1
fi

PRICE=$(echo $RESULT | jq '.data.amount' | sed -s s/\"//g)
PREV=$( echo $PREV   | jq '.data.amount' | sed -s s/\"//g)

echo "$LOGO $PRICE"
echo "$LOGO $PRICE"

if [[ $(bc <<< "$PRICE < $PREV") -eq 1 ]]; then
  echo $DOWNCOLOR
else
  echo $UPCOLOR
fi
