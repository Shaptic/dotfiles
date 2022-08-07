#!/bin/bash
ETH="Ξ"
BTC="฿"
LTC="Ł"
IOTA="ι"
ARK="⟑"
XRP="Ɍ"
XLM="Ø"

PREV=0
PRICE=0
UPCOLOR="#2ECC71"
DOWNCOLOR="#EF4836"


function get_price_coinbase {
  local SYMBOL=""
  if [[ "$1" == "eth" ]]; then
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
  RV=$(printf "%0.2f" "$RV")
}


function get_price_binance {
  local SYMBOL=""
  if [[ "$1" == "eth" ]]; then
    SYMBOL="ETHUSDT"
  elif [[ "$1" == "iota" ]]; then
    SYMBOL="IOTAETH"
  elif [[ "$1" == "ark" ]]; then
    SYMBOL="ARKETH"
  elif [[ "$1" == "ripple" ]]; then
    SYMBOL="XRPETH"
  elif [[ "$1" == "stellar" ]]; then
    SYMBOL="XLMETH"
  fi

  local RESULT=$(curl -s https://api.binance.com/api/v1/ticker/24hr?symbol=$SYMBOL)

  RV1=$(echo $RESULT | jq '.lastPrice' | sed -s s/\"//g)
  RV2=$(echo $RESULT | jq '.openPrice' | sed -s s/\"//g)
}

function errorout {
  # Show nothing if the API call fails (probably no internet)
  echo ""
  echo ""
  echo $DOWNCOLOR
}

if [[ "$1" == "btc" ]]; then
  LOGO=$BTC

elif [[ "$1" == "eth" ]]; then
  LOGO=$ETH

elif [[ "$1" == "ltc" ]]; then
  LOGO=$LTC

elif [[ "$1" == "iota" ]]; then
  LOGO=$IOTA

elif [[ "$1" == "ark" ]]; then
  LOGO=$ARK

elif [[ "$1" == "ripple" ]]; then
  LOGO=$XRP

elif [[ "$1" == "stellar" ]]; then
  LOGO=$XLM

else
  echo "[invalid coin]"
  echo "n/a"
  echo $DOWNCOLOR
  exit 1
fi

if [[ "$1" == "btc" || "$1" == "eth" || "$1" == "ltc" ]]; then
  get_price_coinbase $1 || errorout

  PRICE=$RV
  get_price_coinbase $1 "yday"
  PREV=$RV

elif [[ "$1" == "iota" || "$1" == "ark" || "$1" == "ripple" || "$1" == "stellar" ]]; then
  get_price_binance $1 || errorout

  PRICE=$RV1
  PREV=$RV2
  get_price_binance "eth"
  PRICE=$(echo "$PRICE $RV1" | awk '{printf "%0.3f\n", $1 * $2}')
fi

UP=$(bc <<< "$PRICE > $PREV")

echo -n $LOGO $PRICE
if [[ UP -eq 1 ]]; then
  echo " ↑"
  echo $LOGO↑
  echo $UPCOLOR
else
  echo " ↓"
  echo $LOGO↓
  echo $DOWNCOLOR
fi
