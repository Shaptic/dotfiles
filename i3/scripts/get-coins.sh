#!/bin/bash
ETH="Ξ"
BTC="฿"
IOTA="ι"

PREV=0
PRICE=0
UPCOLOR="#2ECC71"
DOWNCOLOR="#EF4836"


function get_price {
  local SYMBOL=""
  if [[ "$#" == "0" || "$1" == "eth" ]]; then
    SYMBOL="ETH-USD"

  elif [[ "$1" == "btc" ]]; then
    SYMBOL="BTC-USD"
  fi

  local PARAMS=""
  if [[ "$#" == 2 && "$2" == "yday" ]]; then
    YDAY=$(date -d "yesterday 13:00" '+%Y-%m-%d')
    PARAMS="?date=$YDAY"
  fi

  RV=$(curl -s https://api.coinbase.com/v2/prices/$SYMBOL/spot$PARAMS | jq '.data.amount | tonumber')
}

if [[ "$#" == "0" || "$1" == "eth" ]]; then
  LOGO=$ETH

elif [[ "$1" == "btc" ]]; then
  LOGO=$BTC

elif [[ "$1" == "iota" ]]; then
  LOGO=$IOTA
fi

# Show nothing if the API call fails (probably no internet)
if [[ $? -ne 0 ]]; then
  echo ""
  echo ""
  echo "#FF0000"
  exit 1
fi

if [[ "$1" == "btc" || "$1" == "eth" ]]; then
  get_price $1
  PRICE=$RV
  get_price $1 "yday"
  PREV=$RV

elif [[ "$1" == "iota" ]]; then
  RESULT=$(curl -s https://api.binance.com/api/v1/ticker/24hr?symbol=IOTAETH)
  PRICE=$(echo $RESULT | jq '.lastPrice | tonumber')
  PREV=$( echo $RESULT | jq '.openPrice | tonumber')
  get_price "eth"
  PRICE=$(echo "$PRICE $RV" | awk '{printf "%0.2f\n", $1 * $2}')
fi

UP=$(bc <<< "$PRICE > $PREV")

echo "$LOGO $PRICE"
if [[ UP -eq 1 ]]; then
  echo $LOGO↑
  echo $UPCOLOR
else
  echo $LOGO↓
  echo $DOWNCOLOR
fi
