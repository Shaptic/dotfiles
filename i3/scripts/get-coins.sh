#!/bin/bash
ETH="Ξ"
BTC="฿"

PRICE=0
OPEN=0
UPCOLOR="#2ECC71"
DOWNCOLOR="#EF4836"

if [[ "$#" == "0" || "$1" == "eth" ]]; then
  LOGO=$ETH
  RESULT=$(curl -s https://www.bitstamp.net/api/v2/ticker/ethusd)
elif [[ "$1" == "btc" ]]; then
  LOGO=$BTC
  RESULT=$(curl -s https://www.bitstamp.net/api/v2/ticker/btcusd)
fi

# Show nothing if the API call fails (probably no internet)
if [[ $? -ne 0 ]]; then
  echo ""
  echo ""
  echo "#FF0000"
  exit 1
fi

PRICE=$(echo $RESULT | jq '.last' | sed -s s/\"//g)
OPEN=$( echo $RESULT | jq '.open' | sed -s s/\"//g)

echo "$LOGO $PRICE"
echo "$LOGO $PRICE"

if [[ $(bc <<< "$PRICE > $OPEN") ]]; then
  echo $UPCOLOR
else
  echo $DOWNCOLOR
fi
