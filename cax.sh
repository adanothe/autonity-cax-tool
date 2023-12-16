#!/bin/bash

while true; do
  # Reading values from the .env file
  if [ -f .env ]; then
    source .env
  else
    echo "Error: .env file not found."
    exit 1
  fi

  # Displaying the action options
  echo "Action options:"
  echo "1. Generate API Key"
  echo "2. View Balance"
  echo "3. View Order Books"
  echo "4. orderbook information"
  echo "5. Place Order"
  echo "6. Check Open Order"
  echo "7. Cancel Order"
  echo "8. Withdraw"
  echo "9. Check Deposits & Withdraw history"
  echo "10. Exit"
  read -p "Enter your choice (1/2/3/4/5/6/7/8/9/10): " CHOICE

  case "$CHOICE" in
    "1")
      # Checking if API KEY is already present in the .env file
      if [ -n "$APIKEY" ]; then
        echo "API KEY is already registered in .env. Congratulations, you are ready for other actions!"
        continue
      fi

      # Creating a message to be signed with a timestamp as a nonce
      MESSAGE=$(jq -nc --arg nonce "$(date +%s%N)" '$ARGS.named')

      # Signing the message and saving it to a file
      aut account sign-message "$MESSAGE" message.sig

      # Making a POST request to obtain a new API key
      API_KEY_RESPONSE=$(echo -n "$MESSAGE" | https POST "https://cax.piccadilly.autonity.org/api/apikeys" "api-sig:@message.sig")

      # Obtaining the API key value from the response
      NEW_API_KEY=$(echo "$API_KEY_RESPONSE" | jq -r .apikey)

      # Saving the new API key value to the .env file
      echo "APIKEY=$NEW_API_KEY" > .env
      echo "NEW_APIKEY=$NEW_API_KEY"
      echo "Congratulations! You have successfully obtained an API KEY and it's saved in .env."
      ;;
    "2")
      # Making an HTTP GET request to check the balance
      http GET "https://cax.piccadilly.autonity.org/api/balances/" "API-Key:$APIKEY"
      ;;
    "3")
      # Asking the user to choose a pair (ATN-USD or NTN-USD) for option 3
      read -p "Choose pair (1 for ATN-USD, 2 for NTN-USD): " PAIR_CHOICE
      case "$PAIR_CHOICE" in
        "1")
          PAIR=$PAIR1
          ;;
        "2")
          PAIR=$PAIR2
          ;;
        *)
          echo "Invalid choice. 1 corresponds to ATN-USD, and 2 corresponds to NTN-USD."
          continue
          ;;
      esac

      # Making an HTTP GET request to orderbooks with the chosen pair
      http GET "https://cax.piccadilly.autonity.org/api/orderbooks/$PAIR/quote" "API-Key:$APIKEY"
      ;;
    "4")
      # Making an HTTP GET request to orderbooks without a specific pair
      http GET "https://cax.piccadilly.autonity.org/api/orderbooks/" "API-Key:$APIKEY"
      ;;
    "5")
      # Asking the user to choose a pair (ATN-USD or NTN-USD) for option 5
      read -p "Choose pair (1 for ATN-USD, 2 for NTN-USD): " PAIR_CHOICE
      case "$PAIR_CHOICE" in
        "1")
          PAIR=$PAIR1
          ;;
        "2")
          PAIR=$PAIR2
          ;;
        *)
          echo "Invalid choice. 1 corresponds to ATN-USD, and 2 corresponds to NTN-USD."
          continue
          ;;
      esac

      # Asking the user to choose a side (ask or bid)
      read -p "Choose side (ask or bid): " SIDE
      if [ "$SIDE" != "ask" ] && [ "$SIDE" != "bid" ]; then
        echo "Invalid side."
        continue
      fi

      # Asking the user to enter the price
      read -p "Enter price: " PRICE

      # Asking the user to enter the amount
      read -p "Enter amount: " AMOUNT

      # Making an HTTP POST request to place orders with the chosen parameters
      http POST "https://cax.piccadilly.autonity.org/api/orders/" "API-Key:$APIKEY" "pair=$PAIR" "side=$SIDE" "price=$PRICE" "amount=$AMOUNT"
      ;;
    "6")
      # Making an HTTP GET request to view open orders with order ID 0 and status "open"
      API_RESPONSE=$(http GET "https://cax.piccadilly.autonity.org/api/orders" "API-Key:$API" | jq 'map(select(.status == "open"))')

      if [ -n "$API_RESPONSE" ]; then
        echo "Open orders with status 'open':"
        echo "$API_RESPONSE"
      else
        echo "No open orders found."
      fi
      ;;  
    "7")
      # Asking the user whether to cancel a specific order or all orders
      read -p "Do you want to cancel a specific order or all orders? (specific/all): " CANCEL_OPTION

      case "$CANCEL_OPTION" in
        "specific")
          # Get the ID of the first open order
          SPECIFIC_ORDER_ID=$(http GET https://cax.piccadilly.autonity.org/api/orders API-Key:$API | jq -r 'first(.[] | select(.status == "open") | .order_id)')

          # Check if there is an open order
          if [ -n "$SPECIFIC_ORDER_ID" ]; then
            # Making an HTTP DELETE request to cancel the specific order
            http DELETE "https://cax.piccadilly.autonity.org/api/orders/$SPECIFIC_ORDER_ID" API-Key:$API

            if [ $? -eq 0 ]; then
              echo "Order $SPECIFIC_ORDER_ID has been canceled successfully."
            else
              echo "Failed to cancel order $SPECIFIC_ORDER_ID. Please check the order ID."
            fi
          else
            echo "No open orders to cancel."
          fi
          ;;
        "all")
          # Getting all open order IDs
          order_ids=$(http GET https://cax.piccadilly.autonity.org/api/orders API-Key:$API | jq -r '.[] | select(.status == "open") | .order_id')

          if [ -n "$order_ids" ]; then
            # Canceling each open order
            for order_id in $order_ids; do
              http DELETE "https://cax.piccadilly.autonity.org/api/orders/$order_id" API-Key:$API
              echo "Order $order_id has been canceled successfully."
            done

            echo "All open orders have been canceled successfully."
          else
            echo "No open orders to cancel."
          fi
          ;;
        *)
          echo "Invalid option. No orders canceled."
          ;;
      esac
      ;;
    "8")
      # Asking the user to choose a symbol (ATN or NTN)
      read -p "Choose symbol (ATN or NTN): " SYMBOL
      if [ "$SYMBOL" != "ATN" ] && [ "$SYMBOL" != "NTN" ]; then
        echo "Invalid symbol."
        continue
      fi

      # Asking the user to enter the withdrawal amount
      read -p "Enter withdrawal amount: " AMOUNT

      # Making an HTTP POST request to withdraw with the chosen symbol and amount
      http POST "https://cax.piccadilly.autonity.org/api/withdraws/" "API-Key:$APIKEY" "symbol=$SYMBOL" "amount=$AMOUNT"
      ;;
    "9")
      # Making an HTTP GET request to view deposit history
      DEPOSIT_HISTORY=$(http GET "https://cax.piccadilly.autonity.org/api/deposits" "API-Key:$API")

      if [ -n "$DEPOSIT_HISTORY" ]; then
        echo "Deposit History:"
        echo "$DEPOSIT_HISTORY"
      else
        echo "No deposit history found."
      fi

      # Making an HTTP GET request to view withdraw history
      WITHDRAW_HISTORY=$(http GET "https://cax.piccadilly.autonity.org/api/withdraws" "API-Key:$API")

      if [ -n "$WITHDRAW_HISTORY" ]; then
        echo "Withdraw History:"
        echo "$WITHDRAW_HISTORY"
      else
        echo "No withdraw history found."
      fi
      ;;
    "10")
      echo "Exiting the script."
      exit 0
      ;;
    *)
      echo "Invalid choice."
      continue
      ;;
  esac

  # Asking the user if they want to go back to the menu or exit
  read -p "Do you want to go back to the menu or exit? (back/exit): " CONTINUE
  case "$CONTINUE" in
    "back")
      continue
      ;;
    "exit")
      echo "Exiting the script."
      exit 0
      ;;
    *)
      echo "Invalid choice. Exiting the script."
      exit 1
      ;;
  esac
done
