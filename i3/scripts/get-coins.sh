#!/bin/bash
ETH="Ξ"
BTC="฿"
LTC="Ł"
IOTA="ι"

PREV=0
PRICE=0
UPCOLOR="#2ECC71"
DOWNCOLOR="#EF4836"


function get_price_coinbase {
  local SYMBOL=""
  if [[ "$#" == "0" || "$1" == "eth" ]]; then
    SYMBOL="ETH-USD"

  elif [[ "$1" == "btc" ]]; then
    SYMBOL="BTC-USD"

  elif [[ "$1" == "ltc" ]]; then
    SYMBOL="LTC-USD"

  fi

  local PARAMS=""
  if [[ "$#" == 2 && "$2" == "yday" ]]; then
    YDAY=$(date -d "yesterday" '+%Y-%m-%d')
    PARAMS="?date=$YDAY"
  fi

  RV=$(curl -s https://api.coinbase.com/v2/prices/$SYMBOL/spot$PARAMS | jq '.data.amount' | sed -s s/\"//g)
}


function get_price_binance {
  if [[ "$1" == "iota" ]]; then
    SYMBOL="IOTAETH"
  fi

  local RESULT=$(curl -s https://api.binance.com/api/v1/ticker/24hr?symbol=IOTAETH)

  RV1=$(echo $RESULT | jq '.lastPrice' | sed -s s/\"//g)
  RV2=$(echo $RESULT | jq '.openPrice' | sed -s s/\"//g)
}


if [[ "$#" == "0" || "$1" == "eth" ]]; then
  LOGO=$ETH

elif [[ "$1" == "ltc" ]]; then
  LOGO=$LTC

elif [[ "$1" == "btc" ]]; then
  LOGO=$BTC

elif [[ "$1" == "iota" ]]; then
  LOGO=$IOTA

else
  echo "[invalid coin]"
  echo "n/a"
  echo $DOWNCOLOR
  exit 1
fi

# Show nothing if the API call fails (probably no internet)
if [[ $? -ne 0 ]]; then
  echo ""
  echo ""
  echo $DOWNCOLOR
  exit 1
fi

if [[ "$1" == "btc" || "$1" == "eth" || "$1" == "ltc" ]]; then
  get_price_coinbase $1
  PRICE=$RV
  get_price_coinbase $1 "yday"
  PREV=$RV

elif [[ "$1" == "iota" ]]; then
  get_price_binance "iota"
  PRICE=$RV1
  PREV=$RV2
  get_price_coinbase "eth"
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
