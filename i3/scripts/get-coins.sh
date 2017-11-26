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
  PREV=$(curl -s https://api.coinbase.com/v2/prices/ETH-USD/spot?date=$YDAY)
  RESULT=$(curl -s https://api.coinbase.com/v2/prices/ETH-USD/spot)

elif [[ "$1" == "btc" ]]; then
  LOGO=$BTC
  PREV=$(curl -s https://api.coinbase.com/v2/prices/BTC-USD/spot?date=$YDAY)
  RESULT=$(curl -s https://api.coinbase.com/v2/prices/BTC-USD/spot)
fi

# Show nothing if the API call fails (probably no internet)
if [[ $? -ne 0 ]]; then
  echo ""
  echo ""
  echo "#FF0000"
  exit 1
fi

PRICE=$(echo $RESULT | jq '.data.amount' | sed -s s/\"//g)
PREV=$(echo $PREV | jq '.data.amount' | sed -s s/\"//g)

echo "$LOGO $PRICE"
echo "$LOGO $PRICE"

if [[ $(bc <<< "$PRICE < $PREV") -eq 1 ]]; then
  echo $UPCOLOR
else
  echo $DOWNCOLOR
fi
