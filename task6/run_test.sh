for i in {1..15}; do 
    echo -n "Request $i: "
    curl -s -o /dev/null -w "%{http_code} - %{time_total}s\n" http://127.0.0.1
    sleep 1
done
